import Rails from "@rails/ujs";
import { Application } from "stimulus";
require("react_ujs");

import * as Components from "./components";

import EditPageController from "./controllers/EditPageController";
import MainController from "./controllers/MainController";
import LoginController from "./controllers/LoginController";
import PageOptionsController from "./controllers/PageOptionsController";

import RichText from "./features/RichText";

export function registerComponent(name, component) {
  window[name] = component;
}

export default function startPages () {
  Rails.start();
  for (var name in Components) {
    registerComponent(name, Components[name]);
  }
  RichText.start();

  const application = Application.start();
  application.register("edit-page", EditPageController);
  application.register("main", MainController);
  application.register("login", LoginController);
  application.register("page-options", PageOptionsController);
}

export * from "./components";
export * from "./hooks";
