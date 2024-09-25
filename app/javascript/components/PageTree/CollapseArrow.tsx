import * as Tree from "./tree";
import { State, Action, visibleChildNodes } from "./usePageTree";

interface Props {
  id: Tree.Id;
  state: State;
  dispatch: (action: Action) => void;
}

export default function CollapseArrow({ id, state, dispatch }: Props) {
  const node = state.nodes[id];
  const classNames = ["collapse fa-solid fa-caret-right"];

  classNames.push(node.collapsed ? "collapsed" : "open");

  const handleClick = (evt: React.MouseEvent) => {
    evt.stopPropagation();
    dispatch({ type: "setCollapsed", id: id, payload: !node.collapsed });
  };

  const preventDrag = (evt: React.MouseEvent | React.TouchEvent) => {
    evt.stopPropagation();
  };

  if (!("root" in node) && visibleChildNodes(state, id).length > 0) {
    return (
      <i
        className={classNames.join(" ")}
        onMouseDown={preventDrag}
        onClick={handleClick}
      />
    );
  }
}
