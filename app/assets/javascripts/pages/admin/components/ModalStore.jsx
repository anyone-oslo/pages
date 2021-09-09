var ModalStore = Redux.createStore((state = {}, action) => {
  switch(action.type) {
  case "OPEN":
    return {...state, component: action.payload };
  case "CLOSE":
    return {...state, component: null };
  default:
    return state;
  }
});
