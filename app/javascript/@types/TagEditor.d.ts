declare namespace TagEditor {
  interface Action {
    type: string;
    payload: string;
  }

  interface State {
    enabled: string[];
    tags: string[];
  }
}
