// Gem assets
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.cookie
//= require jquery.Jcrop
//= require underscore
//= require react
//= require react_ujs
//= require reflux.min

// Vendored assets
//= require jquery.dimscreen
//= require jquery.fieldselection
//= require_self
//= require pages/login_form
//= require_tree ./admin/lib

//= require pages/admin/components
//= require pages/admin/controllers/base_controller
//= require pages/admin/controllers/pages_controller
//= require pages/admin/controllers/users_controller
//= require pages/admin/features/content_tabs
//= require pages/admin/features/editable_image
//= require pages/admin/features/modal
//= require pages/admin/features/page_images
//= require pages/admin/features/rich_text
//= require pages/admin/features/tag_editor

window.Admin = {
  Controllers: {},

  locale: function() {
    return $('body').data('locale');
  },

  controllerName: function() {
    return $('body').data('controller').replace(/^Admin::/, '');
  },

  actionName: function() {
    return $('body').data('action');
  },

  getController: function() {
    if (this.Controllers.hasOwnProperty(this.controllerName())) {
      return new this.Controllers[this.controllerName()]();
    }
  },

  init: function() {
    var controller;
    if (controller = this.getController()) {
      return controller.dispatch(this.actionName());
    }
  }
};

$(function() {
  return Admin.init();
});
