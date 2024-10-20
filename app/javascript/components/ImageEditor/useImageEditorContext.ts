import { createContext, useContext } from "react";
import { State, Action, Options } from "./useImageEditor";

type Context = {
  state: State;
  dispatch: React.Dispatch<Action>;
  options: Options;
};

export const ImageEditorContext = createContext<Context>(null);

export default function useImageEditorContext() {
  return useContext(ImageEditorContext);
}
