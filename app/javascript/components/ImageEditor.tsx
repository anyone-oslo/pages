import useModalStore from "../stores/useModalStore";
import { putJson } from "../lib/request";
import * as Images from "../types/Images";
import { Locale } from "../types";

import ImageCropper, { useCrop, cropParams } from "./ImageCropper";
import Form from "./ImageEditor/Form";
import useImageEditor from "./ImageEditor/useImageEditor";
import { ImageEditorContext } from "./ImageEditor/useImageEditorContext";

type Props = {
  image: Images.Resource;
  caption: boolean;
  locale: string;
  locales: Record<string, Locale>;
  onUpdate?: (
    data: Partial<Images.Resource>,
    croppedImage: string | null
  ) => void;
};

export default function ImageEditor(props: Props) {
  const [cropState, cropDispatch, croppedImage] = useCrop(props.image);

  const [state, dispatch, options] = useImageEditor(props);

  const closeModal = useModalStore((state) => state.close);

  const handleSave = async (evt: React.MouseEvent) => {
    evt.preventDefault();
    evt.stopPropagation();

    const data = {
      ...cropParams(cropState),
      alternative: state.alternative,
      caption: state.caption
    };
    await putJson(`/admin/images/${props.image.id}`, { image: data });

    if (props.onUpdate) {
      props.onUpdate(data, croppedImage);
    }
    closeModal();
  };

  return (
    <ImageEditorContext.Provider
      value={{
        state: state,
        dispatch: dispatch,
        options: options
      }}>
      <div className="image-editor">
        <ImageCropper
          croppedImage={croppedImage}
          state={cropState}
          dispatch={cropDispatch}
        />
        {!cropState.cropping && <Form onSave={handleSave} />}
      </div>
    </ImageEditorContext.Provider>
  );
}
