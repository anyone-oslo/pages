import React from "react";
import useImageGrid from "./ImageGrid/useImageGrid";
import Grid from "./ImageGrid/Grid";

interface Props extends ImageGrid.Options {
  records: ImageRecord[];
}

export default function ImageGrid(props: Props) {
  const state = useImageGrid(props.records, props.showEmbed);

  return <Grid state={state} {...props} />;
}
