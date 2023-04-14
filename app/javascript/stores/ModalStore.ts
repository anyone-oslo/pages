import { createStore } from "redux";

interface ModalState {
  component: HTMLElement | null
}

interface ModalAction {
  type: string,
  payload?: HTMLElement
}

export default createStore((state: ModalState = {}, action: ModalAction) => {
  switch(action.type) {
  case "OPEN":
    return {...state, component: action.payload };
  case "CLOSE":
    return {...state, component: null };
  default:
    return state;
  }
});
