import Rails from "@rails/ujs";
// import * as ActiveStorage from "@rails/activestorage";
// import "channels";
Rails.start();

require("./components");
require("./controllers");

import RichText from "./features/RichText";
RichText.start();
