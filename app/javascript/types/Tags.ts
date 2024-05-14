export interface Action {
  type: "addTag" | "toggleTag";
  payload: string;
}

export interface State {
  enabled: string[];
  tags: string[];
}
