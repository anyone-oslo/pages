import React, { useRef, useState } from "react";
import PropTypes from "prop-types";
import FileUploadButton from "./FileUploadButton";
import DragElement from "./ImageGrid/DragElement";
import FilePlaceholder from "./ImageGrid/FilePlaceholder";
import GridImage from "./ImageGrid/GridImage";
import ToastStore from "../stores/ToastStore";
import { post } from "../lib/request";

import { createDraggable,
         collectionOrder,
         useDragCollection,
         useDragUploader } from "./drag";

function filterFiles(files) {
  const validMimeTypes = ["image/gif",
                          "image/jpeg",
                          "image/pjpeg",
                          "image/png",
                          "image/tiff"];
  return files.filter(f => (validMimeTypes.indexOf(f.type) !== -1));
}

function draggedImageOrder(primaryCollection, imagesCollection, dragState) {
  const [primary, ...rest] = collectionOrder(primaryCollection, dragState);
  let images = [...rest, ...collectionOrder(imagesCollection, dragState)];

  if (dragState.dragging && [primary, ...images].indexOf(dragState.dragging) === -1) {
    if (dragState.y < imagesCollection.ref.current.getBoundingClientRect().top) {
      images = [dragState.dragging, ...images];
    } else {
      images.push(dragState.dragging);
    }
  }

  return [primary, images];
}

function initRecords(props) {
  const primary = props.enablePrimary ?
        props.records.filter(r => r.primary).slice(0, 1) :
        [];

  return [primary, props.records.filter(r => primary.indexOf(r) === -1)];
}

export default function ImageGrid(props) {
  const [initPrimary, initImages] = initRecords(props);
  const primary = useDragCollection(initPrimary);
  const images = useDragCollection(initImages);
  const [deleted, setDeleted] = useState([]);

  const containerRef = useRef();

  const dispatchAll = (action) => {
    primary.dispatch(action);
    images.dispatch(action);
  };

  const dragEnd = (dragState, files) => {
    const [draggedPrimary,
           draggedImages] = draggedImageOrder(primary, images, dragState);

    primary.dispatch({
      type: "reorder",
      payload: draggedPrimary ? [draggedPrimary] : []
    });
    images.dispatch({ type: "reorder", payload: draggedImages });

    if (files) {
      const uploads = filterFiles(files).map(f => uploadImage(f));
      dispatchAll({ type: "insertFiles", payload: uploads });
    }
  };

  const [dragState,
         dragStart,
         listeners] = useDragUploader([primary, images], dragEnd);

  const position = (record) => {
    return [...primary.draggables.map(d => d.record),
            ...images.draggables.map(d => d.record),
            ...deleted].indexOf(record) + 1;
  };

  const attrName = (record) => {
    return `${props.attribute}[${position(record)}]`;
  };

  const uploadImage = (file) => {
    const draggable = createDraggable(
      { image: null, file: file }
    );

    let data = new FormData();

    data.append("image[file]", file);

    post("/admin/images.json", data)
      .then(json => {
        if (json.status === "error") {
          ToastStore.dispatch({
            type: "ERROR", message: "Error uploading image: " + json.error
          });
          dispatchAll({ type: "remove", payload: draggable });
        } else {
          dispatchAll({
            type: "update",
            payload: { ...draggable, record: { image: json } }
          });
        }
      });

    return draggable;
  };

  const update = (draggable) => (image) => {
    const { record } = draggable;
    const updated = {
      ...draggable,
      record: {
        ...record,
        image: { ...record.image, ...image }
      }
    };
    dispatchAll({ type: "update", payload: updated });
  };

  const remove = (draggable) => () => {
    dispatchAll({ type: "remove", payload: draggable });
    if (draggable.record.id) {
      setDeleted([...deleted, draggable.record]);
    }
  };

  const renderImage = (draggable, isPrimary) => {
    const { dragging } = dragState;

    if (draggable === "Files") {
      return (<FilePlaceholder key="placeholder" />);
    }

    return (
      <GridImage key={draggable.handle}
                 draggable={draggable}
                 locale={props.locale}
                 locales={props.locales}
                 showEmbed={props.showEmbed}
                 startDrag={dragStart}
                 position={position(draggable.record)}
                 primary={isPrimary}
                 onUpdate={update(draggable)}
                 enablePrimary={props.enablePrimary}
                 deleteImage={remove(draggable)}
                 attributeName={attrName(draggable.record)}
                 placeholder={dragging && dragging == draggable} />
    );
  };

  const uploadPrimary = (files) => {
    const [first, ...rest] = filterFiles(files).map(f => uploadImage(f));
    if (first) {
      images.dispatch({
        type: "prepend",
        payload: [...primary.draggables, ...rest]
      });
      primary.dispatch({ type: "replace", payload: [first] });
    }
  };

  const uploadAdditional = (files) => {
    images.dispatch({
      type: "append",
      payload: filterFiles(files).map(f => uploadImage(f))
    });
  };

  let classNames = ["image-grid"];
  if (props.enablePrimary) {
    classNames.push("with-primary-image");
  }

  const [draggedPrimary,
         draggedImages] = draggedImageOrder(primary, images, dragState);

  return (
    <div className={classNames.join(" ")}
         ref={containerRef}
         {...listeners}>
      {dragState.dragging &&
       <DragElement draggable={dragState.dragging}
                    dragState={dragState}
                    container={containerRef} />}
      {props.enablePrimary && (
        <div className="primary-image" ref={primary.ref}>
          <h3>
            Main image
          </h3>
          {draggedPrimary &&
           <>
             {renderImage(draggedPrimary, true)}
             {props.primaryAttribute && (
               <input type="hidden" name={props.primaryAttribute}
                      value={(draggedPrimary.record &&
                              draggedPrimary.record.image &&
                              draggedPrimary.record.image.id) || ""} />
             )}
           </>}
          {!draggedPrimary && (
            <div className="drop-target">
              <FileUploadButton multiple={true}
                                type="image"
                                multiline={true}
                                callback={uploadPrimary} />
            </div>)}
        </div>
      )}
      <div className="grid" ref={images.ref}>
        <h3>
          {props.enablePrimary ? "More images" : "Images"}
        </h3>
        <div className="drop-target">
          <FileUploadButton multiple={true}
                            type="image"
                            callback={uploadAdditional} />
        </div>
        <div className="images">
          {draggedImages.map(r => renderImage(r, false))}
        </div>
      </div>
      <div className="deleted">
        {deleted.map(r =>
          <span className="deleted-image" key={r.id}>
            <input name={`${attrName(r)}[id]`}
                   type="hidden"
                   value={r.id} />
            <input name={`${attrName(r)}[attachment_id]`}
                   type="hidden"
                   value={(r.image && r.image.id) || ""} />
            <input name={`${attrName(r)}[_destroy]`}
                   type="hidden"
                   value={true} />
          </span>)}
      </div>
    </div>
  );
}

ImageGrid.propTypes = {
  attribute: PropTypes.string,
  locale: PropTypes.string,
  locales: PropTypes.array,
  records: PropTypes.array,
  enablePrimary: PropTypes.bool,
  primaryAttribute: PropTypes.string,
  showEmbed: PropTypes.bool
};
