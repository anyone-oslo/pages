import Rails from "@rails/ujs";
// import * as ActiveStorage from "@rails/activestorage";
// import "channels";
Rails.start();

import EditableImage from "./components/EditableImage";
import ImageUploader from "./components/ImageUploader";
import Modal from "./components/Modal";
import PageDates from "./components/PageDates";
import PageFiles from "./components/PageFiles";
import PageImages from "./components/PageImages";
import PageTree from "./components/PageTree";
import RichTextArea from "./components/RichTextArea";
import Toast from "./components/Toast";

window["EditableImage"] = EditableImage;
window["ImageUploader"] = ImageUploader;
window["Modal"] = Modal;
window["PageDates"] = PageDates;
window["PageFiles"] = PageFiles;
window["PageImages"] = PageImages;
window["PageTree"] = PageTree;
window["RichTextArea"] = RichTextArea;
window["Toast"] = Toast;

require("react_ujs");

import RichText from "./features/RichText";
RichText.start();

import "@stimulus/polyfills";
import { Application } from "stimulus";

import MainController from "./controllers/MainController";

const application = Application.start();
application.register("main", MainController);
