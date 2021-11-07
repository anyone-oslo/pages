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
