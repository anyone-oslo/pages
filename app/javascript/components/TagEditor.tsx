import React from "react";

import useTags from "./TagEditor/useTags";
import Editor from "./TagEditor/Editor";

interface Props extends TagEditor.State {
  name: string;
}

export default function TagEditor(props: Props) {
  const [state, dispatch] = useTags(props.tags, props.enabled);

  return <Editor name={props.name} state={state} dispatch={dispatch} />;
}
