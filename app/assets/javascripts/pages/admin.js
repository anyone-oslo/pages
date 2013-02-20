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

var PagesAdmin = {

  controller : false,
  action : false,

  sniffBrowser : function() {
  },

  init : function() {
    PagesAdmin.sniffBrowser();
    if(PagesAdmin.contentTabs) {
      PagesAdmin.contentTabs.init();
    }

    // Call the controller action
    if(PagesAdmin.controller) {
      if(PagesAdmin.controller.init){
        PagesAdmin.controller.init();
      }
      if(PagesAdmin.action && PagesAdmin.controller[PagesAdmin.action+"_action"]) {
        PagesAdmin.controller[PagesAdmin.action+"_action"]();
      }
    }
  }
}

var Admin = PagesAdmin;

PagesAdmin.contentTabs = {

  tabs : new Array(),
  ids : new Array(),

  show : function(tab_id) {
    var tabs = PagesAdmin.contentTabs.tabs;
    var tab = tabs[tab_id];
    if(tab) {
      $.each(PagesAdmin.contentTabs.ids, function(i){
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
      if(PagesAdmin.contentTabs.tabs[tab_id]){
        PagesAdmin.contentTabs.show(tab_id);
      }
    }
  },

  enable : function(tab_ids) {
    var tabs = PagesAdmin.contentTabs.tabs;
    PagesAdmin.contentTabs.ids = tab_ids;
    $.each(tab_ids, function(i) {
      var tab_id = this;
      $("#content-tab-"+this).each(function(i){
        this.tab_id = tab_id;
        tabs[tab_id] = this;
      });
    });
    PagesAdmin.contentTabs.show(tab_ids[0]);
    PagesAdmin.contentTabs.showFromURL(document.location);
  },

  init : function() {
    if($('#content-tabs').length > 0) {
      $('#content-tabs a').each(function(){
        $(this).click(function(){
          PagesAdmin.contentTabs.showFromURL(this.href);
          return false;
        });
      });
    }
    window.showContentTab = PagesAdmin.contentTabs.show;
  }
}

$(function () {

  // Sniff browser and add classes
  if (navigator) {
    $.each(Array("WebKit","Gecko","Firefox"), function(){
      if( navigator.userAgent.match( new RegExp(this+"\\/[\\d]+", 'i'))) {
        $(document.body).addClass(this.toLowerCase());
      }
    });
    if(navigator.userAgent.match("MSIE")) {
      $(document.body).addClass('msie')
    };
    if( navigator.userAgent.match("MSIE 7") ) {
      $(document.body).addClass('msie7');
    }
  }

  // Detect the sidebar and add the appropriate class to the document element.
  if($('#sidebar').length > 0){
    $(document.body).addClass('with_sidebar');
  }

  PagesAdmin.init();
});
