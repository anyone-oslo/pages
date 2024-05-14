import React from "react";

import useTags from "./TagEditor/useTags";
import Editor from "./TagEditor/Editor";
import * as Tags from "../types/Tags";

interface Props extends Tags.State {
  name: string;
}

export default function TagEditor(props: Props) {
  const [state, dispatch] = useTags(props.tags, props.enabled);

  return <Editor name={props.name} state={state} dispatch={dispatch} />;
}
