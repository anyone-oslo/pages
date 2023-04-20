import { createStore } from "redux";

export interface ModalState {
  component: JSX.Element | null
}

interface ModalAction {
  type: string,
  payload?: JSX.Element
}

export default createStore((state: ModalState = {}, action: ModalAction): ModalState => {
  switch(action.type) {
  case "OPEN":
    return {...state, component: action.payload };
  case "CLOSE":
    return {...state, component: null };
  default:
    return state;
  }
});
