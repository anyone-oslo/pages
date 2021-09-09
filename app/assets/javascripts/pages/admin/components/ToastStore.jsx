var ToastStore = Redux.createStore((state = [], action) => {
  switch(action.type) {
  case "ERROR":
    return [...state, { message: action.message, type: "error" }];
  case "NOTICE":
    return [...state, { message: action.message, type: "notice" }];
  case "NEXT":
    return state.slice(1);
  default:
    return state;
  }
});
