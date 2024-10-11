import { allTags, isEnabled } from "./useTags";

import AddTagForm from "./AddTagForm";
import Tag from "./Tag";
import * as Tags from "../../types/Tags";

type Props = {
  name: string;
  state: Tags.State;
  dispatch: React.Dispatch<Tags.Action>;
};

export default function Editor(props: Props) {
  const { name, state, dispatch } = props;

  return (
    <div className="tag-editor">
      <input type="hidden" name={name} value={JSON.stringify(state.enabled)} />
      {allTags(state).map((t) => (
        <Tag
          key={t}
          tag={t}
          enabled={isEnabled(t, state)}
          dispatch={dispatch}
        />
      ))}
      <AddTagForm dispatch={dispatch} />
    </div>
  );
}
