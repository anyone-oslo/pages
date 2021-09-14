import Rails from "@rails/ujs";
// import * as ActiveStorage from "@rails/activestorage";
// import "channels";
Rails.start();

require("react_ujs");

import EditableImage from "./components/EditableImage";
import ImageUploader from "./components/ImageUploader";
import Modal from "./components/Modal";
import PageDates from "./components/PageDates";
import PageFiles from "./components/PageFiles";
import PageImages from "./components/PageImages";
import PageTree from "./components/PageTree";
import RichTextArea from "./components/RichTextArea";
import TagEditor from "./components/TagEditor";
import Toast from "./components/Toast";

window["EditableImage"] = EditableImage;
window["ImageUploader"] = ImageUploader;
window["Modal"] = Modal;
window["PageDates"] = PageDates;
window["PageFiles"] = PageFiles;
window["PageImages"] = PageImages;
window["PageTree"] = PageTree;
window["RichTextArea"] = RichTextArea;
window["TagEditor"] = TagEditor;
window["Toast"] = Toast;

import RichText from "./features/RichText";
RichText.start();

import { Application } from "stimulus";

import EditPageController from "./controllers/EditPageController";
import MainController from "./controllers/MainController";
import LoginController from "./controllers/LoginController";
import PageOptionsController from "./controllers/PageOptionsController";

const application = Application.start();
application.register("edit-page", EditPageController);
application.register("main", MainController);
application.register("login", LoginController);
application.register("page-options", PageOptionsController);
