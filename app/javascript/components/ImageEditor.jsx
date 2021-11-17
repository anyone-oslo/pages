import React, { useState } from "react";
import PropTypes from "prop-types";
import ModalStore from "./ModalStore";
import { putJson } from "../lib/request";

import ImageCropper, { useCrop, cropParams } from "./ImageCropper";
import Form from "./ImageEditor/Form";

export default function ImageEditor(props) {
  const [cropState, dispatch, croppedImage] = useCrop(props.image);
  const [locale, setLocale] = useState(props.locale);
  const [localizations, setLocalizations] = useState({
    caption:     props.image.caption || {},
    alternative: props.image.alternative || {},
  });

  const updateLocalization = (name, value) => {
    setLocalizations({
      ...localizations,
      [name]: { ...localizations[name], [locale]: value }
    });
  };

  const save = (evt) => {
    evt.preventDefault();
    evt.stopPropagation();

    const data = { ...localizations, ...cropParams(cropState) };
    putJson(`/admin/images/${props.image.id}`, { image: data });

    if (props.onUpdate) {
      props.onUpdate(data, croppedImage);
    }
    ModalStore.dispatch({ type: "CLOSE" });
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

ImageEditor.propTypes = {
  image: PropTypes.object,
  locale: PropTypes.string,
  locales: PropTypes.object,
  caption: PropTypes.bool,
  onUpdate: PropTypes.func
};
