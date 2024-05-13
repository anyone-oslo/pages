import { start as startRails } from "@rails/ujs";
import "react_ujs";
import { FC } from "react";

import * as Components from "./components";

import RichText from "./features/RichText";
import contentTabs from "./features/contentTabs";

export function registerComponent(name: string, component: FC) {
  window[name] = component;
}

export default function startPages() {
  startRails();
  for (const name in Components) {
    registerComponent(name, Components[name] as FC);
  }

  RichText.start();
  contentTabs();
}

export * from "./components";
export * from "./hooks";
export * from "./stores";

export * from "./lib/request";
export {
  default as copyToClipboard,
  copySupported
} from "./lib/copyToClipboard";
