// Gem assets
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require jquery.cookie
//= require jcrop
//= require underscore

// Vendored assets
//= require jquery.dimscreen
//= require jquery.fieldselection

//= require_self
//= require_tree "./admin"

var Admin = {

  controller : false,
  action : false,

  init : function() {
    // Call the controller action
    if(Admin.controller) {
      if(Admin.action && Admin.controller[Admin.action]) {
        Admin.controller[Admin.action]();
      }
    }
  }
}


$(function () {

  // Detect the sidebar and add the appropriate class to the document element.
  if($('#sidebar').length > 0){
    $(document.body).addClass('with_sidebar');
  }

  Admin.init();
});
