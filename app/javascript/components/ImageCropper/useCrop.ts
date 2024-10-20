import { useEffect, useReducer, useState } from "react";

import * as Crop from "../../types/Crop";
import * as Images from "../../types/Images";

function focalPoint(state: Crop.State): Crop.Position {
  if (state.crop_gravity_x === null || state.crop_gravity_y === null) {
    return null;
  } else {
    return {
      x: ((state.crop_gravity_x - state.crop_start_x) / state.crop_width) * 100,
      y: ((state.crop_gravity_y - state.crop_start_y) / state.crop_height) * 100
    };
  }
}

function applyAspect(state: Crop.State, aspect: number | null) {
  const crop = cropSize(state);
  const image = state.image;
  const imageAspect = image.real_width / image.real_height;

  // Maximize and center crop area
  if (aspect) {
    crop.aspect = aspect;
    crop.width = 100;
    crop.height = (100 / aspect) * imageAspect;

    if (crop.height > 100) {
      crop.height = 100;
      crop.width = (100 * aspect) / imageAspect;
    }

    crop.x = (100 - crop.width) / 2;
    crop.y = (100 - crop.height) / 2;
  } else {
    delete crop.aspect;
  }

  return applyCrop(state, crop);
}

function applyCrop(state: Crop.State, crop: Crop.CropSize) {
  const { image } = state;

  // Don't crop if dimensions are below the threshold
  if (crop.width < 5 || crop.height < 5) {
    crop = { x: 0, y: 0, width: 100, height: 100 };
  }

  if (crop.aspect === null) {
    delete crop.aspect;
  }

  return {
    aspect: crop.aspect,
    crop_start_x: image.real_width * (crop.x / 100),
    crop_start_y: image.real_height * (crop.y / 100),
    crop_width: image.real_width * (crop.width / 100),
    crop_height: image.real_height * (crop.height / 100)
  };
}

function setFocal(state: Crop.State, position: Crop.Position) {
  return {
    crop_gravity_x: state.crop_width * (position.x / 100) + state.crop_start_x,
    crop_gravity_y: state.crop_height * (position.y / 100) + state.crop_start_y
  };
}

function reducer(state: Crop.State, action: Crop.Action): Crop.State {
  const {
    crop_start_x,
    crop_start_y,
    crop_width,
    crop_height,
    crop_gravity_x,
    crop_gravity_y
  } = state;

  switch (action.type) {
    case "completeCrop":
      // Disable focal point if it's out of bounds.
      if (
        crop_gravity_x < crop_start_x ||
        crop_gravity_x > crop_start_x + crop_width ||
        crop_gravity_y < crop_start_y ||
        crop_gravity_y > crop_start_y + crop_height
      ) {
        return {
          ...state,
          cropping: false,
          crop_gravity_x: null,
          crop_gravity_y: null
        };
      } else {
        return { ...state, cropping: false };
      }
    case "setCrop":
      return { ...state, ...applyCrop(state, action.payload) };
    case "setAspect":
      return { ...state, ...applyAspect(state, action.payload) };
    case "setFocal":
      return { ...state, ...setFocal(state, action.payload) };
    case "startCrop":
      return { ...state, cropping: true };
    case "toggleFocal":
      if (crop_gravity_x === null) {
        return reducer(state, {
          type: "setFocal",
          payload: { x: 50, y: 50 }
        });
      } else {
        return { ...state, crop_gravity_x: null, crop_gravity_y: null };
      }
    default:
      return state;
  }
}

function croppedImageCanvas(
  img: HTMLImageElement,
  crop: Crop.CropSize
): [HTMLCanvasElement, CanvasRenderingContext2D] {
  const canvas = document.createElement("canvas");
  canvas.width = img.naturalWidth * (crop.width / 100);
  canvas.height = img.naturalHeight * (crop.height / 100);
  const ctx = canvas.getContext("2d");
  ctx.drawImage(
    img,
    img.naturalWidth * (crop.x / 100),
    img.naturalHeight * (crop.y / 100),
    img.naturalWidth * (crop.width / 100),
    img.naturalHeight * (crop.height / 100),
    0,
    0,
    img.naturalWidth * (crop.width / 100),
    img.naturalHeight * (crop.height / 100)
  );
  return [canvas, ctx];
}

function imageDataUrl(
  canvas: HTMLCanvasElement,
  ctx: CanvasRenderingContext2D
): string {
  const pixels = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
  for (let i = 0; i < pixels.length / 4; i++) {
    if (pixels[i * 4 + 3] !== 255) {
      return canvas.toDataURL("image/png");
    }
  }
  return canvas.toDataURL("image/jpeg");
}

export function cropParams(state: Crop.State): Crop.Params {
  const maybe = (func: (number) => number) => (val: number | null) =>
    val === null ? val : func(val);
  const maybeRound = maybe(Math.round);
  const maybeCeil = maybe(Math.ceil);

  const crop: Crop.Params = {
    crop_start_x: maybeRound(state.crop_start_x),
    crop_start_y: maybeRound(state.crop_start_y),
    crop_width: maybeCeil(state.crop_width),
    crop_height: maybeCeil(state.crop_height),
    crop_gravity_x: maybeRound(state.crop_gravity_x),
    crop_gravity_y: maybeRound(state.crop_gravity_y)
  };

  if (crop.crop_start_x + crop.crop_width > state.image.real_width) {
    crop.crop_width = state.image.real_width - crop.crop_start_x;
  }

  if (crop.crop_start_y + crop.crop_height > state.image.real_height) {
    crop.crop_height = state.image.real_height - crop.crop_start_y;
  }

  return crop;
}

export function cropSize(state: Crop.State): Crop.CropSize {
  const { image, aspect, crop_start_x, crop_start_y, crop_width, crop_height } =
    state;
  const imageAspect = image.real_width / image.real_height;
  const x = (crop_start_x / image.real_width) * 100;
  const y = (crop_start_y / image.real_height) * 100;

  let width = (crop_width / image.real_width) * 100;
  let height = (crop_height / image.real_height) * 100;

  if (aspect && width) {
    height = (width / aspect) * imageAspect;
  } else if (aspect && height) {
    width = (height * aspect) / imageAspect;
  }

  if (aspect === null) {
    return { x: x, y: y, width: width, height: height };
  } else {
    return { x: x, y: y, width: width, height: height, aspect: aspect };
  }
}

function derivedState(state: Crop.State): Crop.State {
  return { ...state, focalPoint: focalPoint(state) };
}

export default function useCrop(
  image: Images.Resource
): [Crop.State, (action: Crop.Action) => void, string] {
  const initialState: Crop.State = {
    aspect: null,
    cropping: false,
    crop_start_x: image.crop_start_x || 0,
    crop_start_y: image.crop_start_y || 0,
    crop_width: image.crop_width || image.real_width,
    crop_height: image.crop_height || image.real_height,
    crop_gravity_x: image.crop_gravity_x,
    crop_gravity_y: image.crop_gravity_y,
    image: image
  };

  const [state, dispatch] = useReducer(reducer, initialState);

  const [croppedImage, setCroppedImage] = useState<string | null>(null);

  useEffect(() => {
    async function updateCroppedImage() {
      const img: HTMLImageElement = new Image();
      img.src = state.image.uncropped_url;
      await img.decode();
      const [canvas, ctx] = croppedImageCanvas(img, cropSize(state));
      setCroppedImage(imageDataUrl(canvas, ctx));
    }

    if (!state.cropping) {
      void updateCroppedImage();
    }
  }, [state]);

  return [derivedState(state), dispatch, croppedImage];
}
