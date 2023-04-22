import React, { useState } from "react";
import useModalStore from "../stores/useModalStore";
import { putJson } from "../lib/request";

import { Locale, ImageResource } from "../types";
import ImageCropper, { useCrop, cropParams } from "./ImageCropper";
import Form from "./ImageEditor/Form";

interface ImageEditorProps {
  image: ImageResource,
  caption: boolean,
  locale: string,
  locales: Record<string, Locale>,
  onUpdate?: (data: ImageResource, croppedImage: string | null) => void
}

export default function ImageEditor(props: ImageEditorProps) {
  const [cropState, dispatch, croppedImage] = useCrop(props.image);
  const [locale, setLocale] = useState(props.locale);
  const [localizations, setLocalizations] = useState({
    caption:     props.image.caption || {},
    alternative: props.image.alternative || {},
  });

  const closeModal = useModalStore((state) => state.close);

  const updateLocalization = (name: "alternative" | "caption", value: string) => {
    setLocalizations({
      ...localizations,
      [name]: { ...localizations[name], [locale]: value }
    });
  };

  const save = (evt: Event) => {
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
      <ImageCropper croppedImage={croppedImage}
                    cropState={cropState}
                    dispatch={dispatch} />
      {!cropState.cropping &&
       <Form alternative={localizations.alternative}
             caption={localizations.caption}
             image={props.image}
             locale={locale}
             locales={props.locales}
             setLocale={setLocale}
             save={save}
             showCaption={props.caption}
             updateLocalization={updateLocalization} />}
    </div>
  );
}
