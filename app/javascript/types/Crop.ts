import * as Images from "./Images";

export interface Position {
  x: number;
  y: number;
}

export interface Size {
  width: number;
  height: number;
}

export interface Params {
  crop_start_x: number;
  crop_start_y: number;
  crop_width: number;
  crop_height: number;
  crop_gravity_x: number;
  crop_gravity_y: number;
}

export interface State extends Params {
  aspect: number | null;
  cropping: boolean;
  image: Images.Resource;
}

export interface CropSize extends Position, Size {
  aspect?: number;
}

export type Action =
  | { type: "completeCrop" | "startCrop" | "toggleFocal" }
  | { type: "setCrop"; payload: CropSize }
  | { type: "setAspect"; payload: number }
  | { type: "setFocal"; payload: Position };
