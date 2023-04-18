import { createStore } from "redux";

export interface Toast {
  type: string,
  message: string
}

type ToastState = Toast[];

interface ToastAction {
  type: string,
  message?: string
}

export default createStore((state: ToastState = [], action: ToastAction) => {
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
