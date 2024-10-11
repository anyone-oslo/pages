import * as Tree from "./tree";
import { visibleChildNodes } from "./usePageTree";
import usePageTreeContext from "./usePageTreeContext";

type Props = {
  id: Tree.Id;
};

export default function CollapseArrow({ id }: Props) {
  const { state, dispatch } = usePageTreeContext();
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
