export type Action =
  | { type: "addTag" | "toggleTag"; payload: string }
  | { type: "update"; payload: State };

export type State = {
  enabled: string[];
  tags: string[];
};
