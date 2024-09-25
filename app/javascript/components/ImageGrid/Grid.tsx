import { useRef } from "react";
import FileUploadButton from "../FileUploadButton";
import DragElement from "./DragElement";
import FilePlaceholder from "./FilePlaceholder";
import GridImage from "./GridImage";
import useToastStore from "../../stores/useToastStore";
import { post } from "../../lib/request";
import * as Drag from "../../types/Drag";
import * as Images from "../../types/Images";

import { createDraggable, collectionOrder, useDragUploader } from "../drag";

interface Props extends Images.GridOptions {
  state: Images.GridState;
}

function filterFiles(files: File[]): File[] {
  const validMimeTypes = [
    "image/gif",
    "image/jpeg",
    "image/pjpeg",
    "image/png",
    "image/tiff"
  ];
  return files.filter((f) => validMimeTypes.indexOf(f.type) !== -1);
}

function draggedImageOrder(
  primaryCollection: Drag.Collection<Images.Record>,
  imagesCollection: Drag.Collection<Images.Record>,
  dragState: Drag.State<Images.Record>
): [Drag.Item<Images.Record>, Drag.Item<Images.Record>[]] {
  const [primary, ...rest] = collectionOrder(primaryCollection, dragState);
  let images = [...rest, ...collectionOrder(imagesCollection, dragState)];

  if (
    dragState.dragging &&
    [primary, ...images].indexOf(dragState.dragging) === -1
  ) {
    if (
      dragState.y < imagesCollection.ref.current.getBoundingClientRect().top
    ) {
      images = [dragState.dragging, ...images];
    } else {
      images.push(dragState.dragging);
    }
  }

  return [primary, images];
}

export default function Grid(props: Props) {
  const { primary, images, deleted, setDeleted } = props.state;

  const containerRef = useRef();
  const error = useToastStore((state) => state.error);

  const dispatchAll = (action) => {
    primary.dispatch(action);
    images.dispatch(action);
  };

  const dragEnd = (dragState: Drag.State<Images.Record>, files: File[]) => {
    const [draggedPrimary, draggedImages] = draggedImageOrder(
      primary,
      images,
      dragState
    );

    primary.dispatch({
      type: "reorder",
      payload: draggedPrimary ? [draggedPrimary] : []
    });
    images.dispatch({ type: "reorder", payload: draggedImages });

    if (files) {
      const uploads = filterFiles(files).map((f) => uploadImage(f));
      dispatchAll({ type: "insertFiles", payload: uploads });
    }
  };

  const [dragState, dragStart, listeners] = useDragUploader<Images.Record>(
    [primary, images],
    dragEnd
  );

  const position = (record: Images.Record) => {
    return (
      [
        ...primary.draggables.map(
          (d: Drag.Draggable<Images.Record>) => d.record
        ),
        ...images.draggables.map(
          (d: Drag.Draggable<Images.Record>) => d.record
        ),
        ...deleted
      ].indexOf(record) + 1
    );
  };

  const attrName = (record: Images.Record) => {
    return `${props.attribute}[${position(record)}]`;
  };

  const uploadImage = (file: File) => {
    const draggable = createDraggable({ image: null, file: file });

    const data = new FormData();

    data.append("image[file]", file);

    void post("/admin/images.json", data).then((json: Images.Response) => {
      if ("status" in json && json.status === "error") {
        error(`Error uploading image: ${json.error}`);
        dispatchAll({ type: "remove", payload: draggable });
      } else {
        dispatchAll({
          type: "update",
          payload: { ...draggable, record: { image: json } } as Drag.Draggable
        });
      }
    });

    return draggable;
  };

  const update =
    (draggable: Drag.Draggable<Images.Record>) => (image: Images.Resource) => {
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

  const remove = (draggable: Drag.Draggable<Images.Record>) => () => {
    dispatchAll({ type: "remove", payload: draggable });
    if (draggable.record.id) {
      setDeleted([...deleted, draggable.record]);
    }
  };

  const renderImage = (
    draggable: Drag.Item<Images.Record>,
    isPrimary: boolean
  ) => {
    const { dragging } = dragState;

    if (draggable === "Files") {
      return <FilePlaceholder key="placeholder" />;
    }

    return (
      <GridImage
        key={draggable.handle}
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
        placeholder={dragging && dragging == draggable}
      />
    );
  };

  const uploadPrimary = (files: File[]) => {
    const [first, ...rest] = filterFiles(files).map((f) => uploadImage(f));
    if (first) {
      images.dispatch({
        type: "prepend",
        payload: [...primary.draggables, ...rest]
      });
      primary.dispatch({ type: "replace", payload: [first] });
    }
  };

  const uploadAdditional = (files: File[]) => {
    images.dispatch({
      type: "append",
      payload: filterFiles(files).map((f) => uploadImage(f))
    });
  };

  const classNames = ["image-grid"];
  if (props.enablePrimary) {
    classNames.push("with-primary-image");
  }

  const [draggedPrimary, draggedImages] = draggedImageOrder(
    primary,
    images,
    dragState
  );

  return (
    <div className={classNames.join(" ")} ref={containerRef} {...listeners}>
      {dragState.dragging && (
        <DragElement
          draggable={dragState.dragging}
          dragState={dragState}
          container={containerRef}
        />
      )}
      {props.enablePrimary && (
        <div className="primary-image" ref={primary.ref}>
          <h3>Main image</h3>
          {draggedPrimary && (
            <>
              {renderImage(draggedPrimary, true)}
              {props.primaryAttribute && (
                <input
                  type="hidden"
                  name={props.primaryAttribute}
                  value={
                    (draggedPrimary !== "Files" &&
                      draggedPrimary.record.image &&
                      draggedPrimary.record.image.id) ||
                    ""
                  }
                />
              )}
            </>
          )}
          {!draggedPrimary && (
            <div className="drop-target">
              <FileUploadButton
                multiple={true}
                type="image"
                multiline={true}
                callback={uploadPrimary}
              />
            </div>
          )}
        </div>
      )}
      <div className="grid" ref={images.ref}>
        <h3>{props.enablePrimary ? "More images" : "Images"}</h3>
        <div className="drop-target">
          <FileUploadButton
            multiple={true}
            type="image"
            callback={uploadAdditional}
          />
        </div>
        <div className="images">
          {draggedImages.map((r) => renderImage(r, false))}
        </div>
      </div>
      <div className="deleted">
        {deleted.map((r) => (
          <span className="deleted-image" key={r.id}>
            <input name={`${attrName(r)}[id]`} type="hidden" value={r.id} />
            <input
              name={`${attrName(r)}[attachment_id]`}
              type="hidden"
              value={(r.image && r.image.id) || ""}
            />
            <input
              name={`${attrName(r)}[_destroy]`}
              type="hidden"
              value={"true"}
            />
          </span>
        ))}
      </div>
    </div>
  );
}
