import * as Tombolo from "tombolo";
import Rails from "@rails/ujs";

import * as Components from "./components";
import RichText from "./features/RichText";
import contentTabs from "./features/contentTabs";

/** @deprecated Import tombolo directly and use Tombolo.start() instead. */
export function registerComponent(name: string, component: React.ComponentType) {
  Tombolo.start({ [name]: component });
}

export default function startPages() {
  Rails.start();
  Tombolo.start(Components);
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
