import * as Tree from "./tree";
import { visibleChildNodes } from "./usePageTree";
import usePageTreeContext from "./usePageTreeContext";

type Props = {
  id: Tree.Id;
};

export default function CollapsedLabel({ id }: Props) {
  const { state } = usePageTreeContext();
  const node = state.nodes[id];
  const count = visibleChildNodes(state, id).length;

  if (node.collapsed && count > 0) {
    return (
      <span className="collapsed-label">
        ({count} {count == 1 ? "item" : "items"})
      </span>
    );
  }
}
