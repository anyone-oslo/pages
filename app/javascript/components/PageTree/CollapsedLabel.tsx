import * as Tree from "./tree";
import { State, visibleChildNodes } from "./usePageTree";

type Props = {
  id: Tree.Id;
  state: State;
}

export default function CollapsedLabel({ id, state }: Props) {
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
