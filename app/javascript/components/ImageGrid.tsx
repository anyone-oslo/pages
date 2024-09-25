import * as Images from "../types/Images";
import useImageGrid from "./ImageGrid/useImageGrid";
import Grid from "./ImageGrid/Grid";

interface Props extends Images.GridOptions {
  records: Images.Record[];
}

export default function ImageGrid(props: Props) {
  const state = useImageGrid(props.records, props.showEmbed);

  return <Grid state={state} {...props} />;
}
