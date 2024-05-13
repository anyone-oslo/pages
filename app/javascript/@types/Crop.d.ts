declare namespace Crop {
  interface Position {
    x: number;
    y: number;
  }

  interface Size {
    width: number;
    height: number;
  }

  interface Params {
    crop_start_x: number;
    crop_start_y: number;
    crop_width: number;
    crop_height: number;
    crop_gravity_x: number;
    crop_gravity_y: number;
  }

  interface State extends Params {
    aspect: number | null;
    cropping: boolean;
    image: ImageResource;
  }

  interface CropSize extends Position, Size {
    aspect?: number;
  }

  type Action =
    | { type: "completeCrop" | "startCrop" | "toggleFocal" }
    | { type: "setCrop"; payload: CropSize }
    | { type: "setAspect"; payload: number }
    | { type: "setFocal"; payload: Position };
}
