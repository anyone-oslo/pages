import { Fragment, useRef } from "react";

import * as Tree from "./tree";

import {
  State,
  Action,
  addChild,
  updatePage,
  visibleChildNodes
} from "./usePageTree";
import Button from "./Button";
import CollapseArrow from "./CollapseArrow";
import CollapsedLabel from "./CollapsedLabel";
import PageName from "./PageName";
import StatusLabel from "./StatusLabel";
import EditPageName from "./EditPageName";

type Props = {
  id: Tree.Id;
  state: State;
  dispatch: (action: Action) => void;

  dragging?: Tree.Id;
  onDragStart?: (
    id: number,
    element: HTMLDivElement,
    evt: React.MouseEvent | React.TouchEvent
  ) => void;
};

export const paddingLeft = 20;

export default function Node(props: Props) {
  const { id, state, dispatch, dragging, onDragStart } = props;
  const { dir, locale } = state;
  const node = state.nodes[id];
  const page = node.record;
  const name = page.blocks.name[locale];

  const innerRef = useRef<HTMLDivElement>();

  const classNames = ["node"];
  if (id === dragging) {
    classNames.push("placeholder");
  }

  const pageClassNames = ["page"];
  let iconClass = "fa-regular fa-file icon";

  if (!("root" in page)) {
    pageClassNames.push(`status-${page.status}`);
    if (page.news_page) {
      iconClass = "fa-regular fa-file-lines page-icon";
    } else if (page.pinned) {
      iconClass = "fa-regular fa-flag page-icon";
    }
  }

  const permitted = (action: string): boolean => {
    return page.permissions && page.permissions.indexOf(action) !== -1;
  };

  const handleAddChild = () => {
    addChild(state, id, dispatch);
  };

  const handleDragStart = (evt: React.MouseEvent | React.TouchEvent) => {
    if (permitted("edit") && !page.editing && onDragStart) {
      onDragStart(id, innerRef.current, evt);
    }
  };

  const handleDelete = () => {
    if (confirm("Are you sure you want to delete this page?")) {
      updatePage(state, id, dispatch, { status: 4 });
    }
  };

  const handleEdit = () => {
    dispatch({ type: "update", id: id, payload: { editing: true } });
  };

  const handleToggleStatus = () => {
    if ("status" in page && page.status != 2) {
      updatePage(state, id, dispatch, { status: 2 });
    } else {
      updatePage(state, id, dispatch, { status: 3 });
    }
  };

  return (
    <div className={classNames.join(" ")}>
      <div className="inner" ref={innerRef} onMouseDown={handleDragStart}>
        <CollapseArrow {...props} />

        {!page.editing && (
          <div className={pageClassNames.join(" ")}>
            <i className={iconClass}></i>
            <PageName
              name={name}
              dir={dir}
              locale={locale}
              editUrl={
                "id" in page &&
                permitted("edit") &&
                `/admin/${locale}/pages/${page.id}/edit`
              }
            />
            {"status" in page && <StatusLabel status={page.status} />}
            <CollapsedLabel {...props} />
            <span className="actions">
              {!("root" in page) && (
                <Fragment>
                  {permitted("edit") && (
                    <Button
                      label={page.status != 2 ? "Publish" : "Hide"}
                      className="toggle-status"
                      icon={page.status != 2 ? "check" : "ban"}
                      onClick={handleToggleStatus}
                    />
                  )}

                  {permitted("edit") && (
                    <Button
                      label="Rename"
                      className="edit"
                      icon="pencil"
                      onClick={handleEdit}
                    />
                  )}

                  {permitted("edit") && (
                    <Button
                      label="Delete"
                      className="delete"
                      icon="trash"
                      onClick={handleDelete}
                    />
                  )}
                </Fragment>
              )}
              {permitted("create") && (
                <Button
                  label="Add child"
                  className="add"
                  icon="plus"
                  onClick={handleAddChild}
                />
              )}
            </span>
          </div>
        )}

        {page.editing && <EditPageName {...props} />}
      </div>

      {!node.collapsed && visibleChildNodes(state, id).length > 0 && (
        <Fragment>
          <div className="children" style={{ paddingLeft: `${paddingLeft}px` }}>
            {visibleChildNodes(state, id).map((childId) => {
              return <Node {...props} id={childId} key={childId} />;
            })}
          </div>
          {permitted("create") && (
            <Button
              label="Add page here"
              className="add add-inline transparent"
              icon="plus"
              onClick={handleAddChild}
            />
          )}
        </Fragment>
      )}
    </div>
  );
}
