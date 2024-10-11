import useTags from "./TagEditor/useTags";
import Editor from "./TagEditor/Editor";
import * as Tags from "../types/Tags";

type Props = Tags.State & {
  name: string;
};

export default function TagEditor(props: Props) {
  const [state, dispatch] = useTags(props.tags, props.enabled);

  return <Editor name={props.name} state={state} dispatch={dispatch} />;
}
