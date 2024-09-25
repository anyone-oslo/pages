import { MouseEvent, useState } from "react";

import useModalStore from "../stores/useModalStore";
import { putJson } from "../lib/request";
import * as Images from "../types/Images";
import { Locale } from "../types";

import ImageCropper, { useCrop, cropParams } from "./ImageCropper";
import Form from "./ImageEditor/Form";

interface Props {
  image: Images.Resource;
  caption: boolean;
  locale: string;
  locales: Record<string, Locale>;
  onUpdate?: (
    data: Partial<Images.Resource>,
    croppedImage: string | null
  ) => void;
}

export default function ImageEditor(props: Props) {
  const [cropState, dispatch, croppedImage] = useCrop(props.image);
  const [locale, setLocale] = useState(props.locale);
  const [localizations, setLocalizations] = useState({
    caption: props.image.caption || {},
    alternative: props.image.alternative || {}
  });

  const closeModal = useModalStore((state) => state.close);

  const updateLocalization = (
    name: "alternative" | "caption",
    value: string
  ) => {
    setLocalizations({
      ...localizations,
      [name]: { ...localizations[name], [locale]: value }
    });
  };

  const save = (evt: MouseEvent) => {
    evt.preventDefault();
    evt.stopPropagation();

    const data = { ...localizations, ...cropParams(cropState) };
    void putJson(`/admin/images/${props.image.id}`, { image: data });

    if (props.onUpdate) {
      props.onUpdate(data, croppedImage);
    }
    closeModal();
  };

  return (
    <div className="image-editor">
      <ImageCropper
        croppedImage={croppedImage}
        cropState={cropState}
        dispatch={dispatch}
      />
      {!cropState.cropping && (
        <Form
          alternative={localizations.alternative}
          caption={localizations.caption}
          image={props.image}
          locale={locale}
          locales={props.locales}
          setLocale={setLocale}
          save={save}
          showCaption={props.caption}
          updateLocalization={updateLocalization}
        />
      )}
    </div>
  );
}
