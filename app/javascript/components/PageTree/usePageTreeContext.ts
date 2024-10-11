import { createContext, useContext } from "react";
import { State, Action } from "./usePageTree";

type Context = {
  state: State;
  dispatch: React.Dispatch<Action>;
};

export const PageTreeContext = createContext<Context>(null);

export default function usePageTreeContext() {
  return useContext(PageTreeContext);
}
