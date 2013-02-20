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
    if(Admin.contentTabs) {
      Admin.contentTabs.init();
    }

    // Call the controller action
    if(Admin.controller) {
      if(Admin.action && Admin.controller[Admin.action]) {
        Admin.controller[Admin.action]();
      }
    }
  }
}

Admin.contentTabs = {

  tabs : new Array(),
  ids : new Array(),

  show : function(tab_id) {
    var tabs = Admin.contentTabs.tabs;
    var tab = tabs[tab_id];
    if(tab) {
      $.each(Admin.contentTabs.ids, function(i){
        if(tabs[this]) {
          $(tabs[this]).hide();
        } else {
          // console.log("Could not hide tab: "+this);
        }
        $("#content-tab-link-"+this).removeClass('current');
      });
      $(tab).show();
      $("#content-tab-link-"+tab_id).addClass('current');
    }
  },

  showFromURL : function(url) {
    var tab_expression = /#(.*)$/
    if(url.toString().match(tab_expression)){
      var tab_id = url.toString().match(tab_expression)[1];
      if(Admin.contentTabs.tabs[tab_id]){
        Admin.contentTabs.show(tab_id);
      }
    }
  },

  enable : function(tab_ids) {
    var tabs = Admin.contentTabs.tabs;
    Admin.contentTabs.ids = tab_ids;
    $.each(tab_ids, function(i) {
      var tab_id = this;
      $("#content-tab-"+this).each(function(i){
        this.tab_id = tab_id;
        tabs[tab_id] = this;
      });
    });
    Admin.contentTabs.show(tab_ids[0]);
    Admin.contentTabs.showFromURL(document.location);
  },

  init : function() {
    if($('#content-tabs').length > 0) {
      $('#content-tabs a').each(function(){
        $(this).click(function(){
          Admin.contentTabs.showFromURL(this.href);
          return false;
        });
      });
    }
    window.showContentTab = Admin.contentTabs.show;
  }
}

$(function () {

  // Detect the sidebar and add the appropriate class to the document element.
  if($('#sidebar').length > 0){
    $(document.body).addClass('with_sidebar');
  }

  Admin.init();
});
