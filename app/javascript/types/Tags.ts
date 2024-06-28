export type Action =
  | { type: "addTag" | "toggleTag"; payload: string }
  | { type: "update"; payload: State };

export interface State {
  enabled: string[];
  tags: string[];
}
