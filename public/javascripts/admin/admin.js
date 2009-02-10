var PagesAdmin = {

	sniffBrowser : function() {
		if(navigator) {
			jQuery.each(Array("WebKit","Gecko","Firefox"), function(){
				if( navigator.userAgent.match( new RegExp(this+"\\/[\\d]+", 'i'))) {
					jQuery(document.body).addClass(this.toLowerCase());
				}
			});
			if(navigator.userAgent.match("MSIE")) { 
				jQuery(document.body).addClass('msie') 
			};
			if( navigator.userAgent.match("MSIE 7") ) {
				jQuery(document.body).addClass('msie7');
			}
		}
	},

	applyStyles : function() {
		// Detect the sidebar and add the appropriate class to the document element.
		if(jQuery('#sidebar').length > 0){
			jQuery(document.body).addClass('with_sidebar');
		}

		// Add input_$type class to inputs.
		jQuery('input').each(function(i){jQuery(this).addClass("input_"+this.type);});

		// Inject buttons with <div class="inner">
		jQuery('button').wrapInner('<div class="inner"></div>');
	},
	
	init : function() {
		PagesAdmin.sniffBrowser();
		PagesAdmin.applyStyles();
		if(PagesAdmin.contentTabs) {
			PagesAdmin.contentTabs.init();
		}
	}
}

PagesAdmin.contentTabs = {

	tabs : new Array(),
	ids : new Array(),
	default : false,

	show : function(tab_id) {
		var tabs = PagesAdmin.contentTabs.tabs;
		var tab = tabs[tab_id];
		if(tab) {
			jQuery.each(PagesAdmin.contentTabs.ids, function(i){
				if(tabs[this]) {
					jQuery(tabs[this]).hide();
				} else {
					console.log("Could not hide tab: "+this);
				}
				jQuery("#content-tab-link-"+this).removeClass('current');
			});
			jQuery(tab).show();
			jQuery("#content-tab-link-"+tab_id).addClass('current');
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
		//PagesAdmin.contentTabs.tabs = new Array();
		var tabs = PagesAdmin.contentTabs.tabs;
		PagesAdmin.contentTabs.ids = tab_ids;
		jQuery.each(tab_ids, function(i) {
			var tab_id = this;
			jQuery("#content-tab-"+this).each(function(i){
				this.tab_id = tab_id;
				tabs[tab_id] = this;
			});
		});
		PagesAdmin.contentTabs.show(tab_ids[0]);
		PagesAdmin.contentTabs.showFromURL(document.location);
	},

	init : function() {
		if(jQuery('#content-tabs').length > 0) {
			jQuery('#content-tabs a').each(function(){
				jQuery(this).click(function(){
					PagesAdmin.contentTabs.showFromURL(this.href);
				});
			});
		}
		window.showContentTab = PagesAdmin.contentTabs.show;
	}
}

FastInit.addOnLoad(PagesAdmin.init);