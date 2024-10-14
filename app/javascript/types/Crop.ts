import * as Images from "./Images";

export type Position = {
  x: number;
  y: number;
};

export type Ratio = number | null;

export type Size = {
  width: number;
  height: number;
};

export type Params = {
  crop_start_x: number;
  crop_start_y: number;
  crop_width: number;
  crop_height: number;
  crop_gravity_x: number;
  crop_gravity_y: number;
};

export type State = Params & {
  aspect: number | null;
  cropping: boolean;
  image: Images.Resource;
};

export type CropSize = Position &
  Size & {
    aspect?: number;
  };

export type Action =
  | { type: "completeCrop" | "startCrop" | "toggleFocal" }
  | { type: "setCrop"; payload: CropSize }
  | { type: "setAspect"; payload: Ratio }
  | { type: "setFocal"; payload: Position };
