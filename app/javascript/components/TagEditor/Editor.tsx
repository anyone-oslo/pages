import React from "react";

import { allTags, isEnabled } from "./useTags";

import AddTagForm from "./AddTagForm";
import Tag from "./Tag";

interface Props {
  name: string;
  state: TagEditor.State;
  dispatch: (action: TagEditor.Action) => void;
}

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
