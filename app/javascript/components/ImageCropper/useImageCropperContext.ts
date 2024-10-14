import { createContext, useContext } from "react";
import * as Crop from "../../types/Crop";

type Context = {
  state: Crop.State;
  dispatch: React.Dispatch<Crop.Action>;
};

export const ImageCropperContext = createContext<Context>(null);

export default function useImageCropperContext() {
  return useContext(ImageCropperContext);
}
