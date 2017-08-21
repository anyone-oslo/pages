var ContentTabs = {
  tabs: [],
  ids: [],

  show: function(id) {
    let tabs = ContentTabs.tabs;
    let tab = tabs[id];
    if (tab) {
      $.each(ContentTabs.ids, function(i) {
        if (tabs[this]) {
          $(tabs[this]).hide();
        }
        $("#content-tab-link-" + this).removeClass("current");
      });
      $(tab).show();
      $("#content-tab-link-" + id).addClass("current");
    }
  },

  showFromURL: function(url) {
    let tab_expression = /#(.*)$/;
    if (url.toString().match(tab_expression)) {
      let id = url.toString().match(tab_expression)[1];
      if (ContentTabs.tabs[id]) {
        ContentTabs.show(id);
      }
    }
  },

  enable: function(ids) {
    let tabs = ContentTabs.tabs;
    ContentTabs.ids = ids;
    $.each(ids, function(i) {
      let id = this;
      return $("#content-tab-" + this).each(function(i) {
        this.id = id;
        return tabs[id] = this;
      });
    });
    ContentTabs.show(ids[0]);
    ContentTabs.showFromURL(document.location);
  },

  init: function() {
    if ($("#content-tabs").length > 0) {
      let tabNames = $("#content-tabs li").map(function() {
        return $(this).data("tab-name");
      }).get();
      ContentTabs.enable(tabNames);
      $("#content-tabs a").each(function() {
        $(this).click(function() {
          ContentTabs.showFromURL(this.href);
          return false;
        });
      });
    }
    window.showContentTab = ContentTabs.show;
  }
};

$(function() {
  ContentTabs.init();
});
