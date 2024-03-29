import { start as startRails } from "@rails/ujs";
import { Application } from "@hotwired/stimulus";
import "react_ujs";
import { FC } from "react";

import * as Components from "./components";

import EditPageController from "./controllers/EditPageController";
import MainController from "./controllers/MainController";
import PageOptionsController from "./controllers/PageOptionsController";

import RichText from "./features/RichText";

export function registerComponent(name: string, component: FC) {
  window[name] = component;
}

export default function startPages() {
  startRails();
  for (const name in Components) {
    registerComponent(name, Components[name] as FC);
  }
  RichText.start();

  const application = Application.start();
  application.register("edit-page", EditPageController);
  application.register("main", MainController);
  application.register("page-options", PageOptionsController);
}

export * from "./components";
export * from "./hooks";
export * from "./stores";

export * from "./lib/request";
export {
  default as copyToClipboard,
  copySupported
} from "./lib/copyToClipboard";
