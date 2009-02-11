/*
 * jQuery plugin: fieldSelection - v0.1.0 - last change: 2006-12-16
 * (c) 2006 Alex Brem <alex@0xab.cd> - http://blog.0xab.cd
 */
(function() {
	var fieldSelection = {
		getSelection: function() {
			var e = this.jquery ? this[0] : this;
			return (
				/* mozilla / dom 3.0 */
				('selectionStart' in e && function() {
					var l = e.selectionEnd - e.selectionStart;
					return { start: e.selectionStart, end: e.selectionEnd, length: l, text: e.value.substr(e.selectionStart, l) };
				}) ||
				/* exploder */
				(document.selection && function() {
					e.focus();
					var r = document.selection.createRange();
					if (r == null) {
						return { start: 0, end: e.value.length, length: 0 }
					}
					var re = e.createTextRange();
					var rc = re.duplicate();
					re.moveToBookmark(r.getBookmark());
					rc.setEndPoint('EndToStart', re);
					return { start: rc.text.length, end: rc.text.length + r.text.length, length: r.text.length, text: r.text };
				}) ||
				/* browser not supported */
				function() {
					return { start: 0, end: e.value.length, length: 0 };
				}
			)();
		},

		replaceSelection: function() {
			var e = this.jquery ? this[0] : this;
			var text = arguments[0] || '';
			return (
				/* mozilla / dom 3.0 */
				('selectionStart' in e && function() {
					e.value = e.value.substr(0, e.selectionStart) + text + e.value.substr(e.selectionEnd, e.value.length);
					return this;
				}) ||
				/* exploder */
				(document.selection && function() {
					e.focus();
					document.selection.createRange().text = text;
					return this;
				}) ||
				/* browser not supported */
				function() {
					e.value += text;
					return this;
				}
			)();
		}
	};
	jQuery.each(fieldSelection, function(i) { jQuery.fn[i] = this; });
})();

function jRichTextArea(textArea, options){
	this.textArea = textArea;

	// Default options
	settings = jQuery.extend({
	     class: "richTextToolbar"
	}, options);
	
	this.toolbar = {
		settings : settings,
		textArea : textArea,
		listElement : false,
		buttons : new Array(),
		addButton : function(name, callback, options) {
			// Default options
			settings = jQuery.extend({
			     class: name.replace(/[\s]+/, '')+"Button"
			}, options);
			var li = document.createElement("li");
			var a = document.createElement("a");
			a.title = name;
			a.textArea = this.textArea;
			callback.this = this;
			jQuery(a).click(callback);
			jQuery(a).addClass(settings.class);
			jQuery(li).append(a).appendTo(this.listElement);
			this.buttons.push(li);
			return this;
		},
		create : function() {
			if(!this.listElement) {
				this.listElement = document.createElement("ul");
				jQuery(this.listElement).addClass(this.settings.class);
				jQuery(this.listElement).insertBefore(this.textArea);
			}
		}
	}
	
	this.textArea.selectedText = function() {
		return jQuery(this).getSelection().text;
	}
	this.textArea.replaceSelection = function(replacement) {
		return jQuery(this).replaceSelection(replacement);
	}
	this.textArea.wrapSelection = function() {
		var prepend = arguments[0];
		var append = (arguments.length > 1) ? arguments[1] : prepend
		return this.replaceSelection(prepend + this.selectedText() + append);
	}

	// Delegates
	this.textArea.toolbar = this.toolbar;
	this.toolbar.create();
}

var PagesAdmin = {

	controller : false,
	action : false,

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

	applyTextAreas : function() {
		jQuery('textarea.rich').each(function(){
			var ta = new jRichTextArea(this);

			// Add buttons to the field
			ta.toolbar
				// Bold
				.addButton("Bold", function(){ this.textArea.wrapSelection('*'); })
				// Italic
				.addButton("Italics", function(){ this.textArea.wrapSelection('_'); })
				// Headings
				.addButton("Heading 2", function(){ this.textArea.wrapSelection('h2. ',''); })
				.addButton("Heading 3", function(){ this.textArea.wrapSelection('h3. ',''); })
				.addButton("Heading 4", function(){ this.textArea.wrapSelection('h4. ',''); })
				// Links
				.addButton("Link", function(){
				    var selection = this.textArea.selectedText();
				    var response = prompt('Enter link URL','');  
				    this.textArea.replaceSelection(
						'"' + (selection == '' ? "Link text" : selection) + '":' + 
						(response == '' ? 'http://link_url/' : response).replace(/^(?!(f|ht)tps?:\/\/)/,'http://')
					);
				})
				// Email links
				.addButton("Email", function(){
				    var selection = this.textArea.selectedText();
				    var response = prompt('Enter mail address','');  
				    this.textArea.replaceSelection(
						'"' + (selection == '' ? "Link text" : selection) + '":mailto:' + 
						(response == '' ? 'support@manualdesign.no' : response)
					);
				})
				// Image tag
				.addButton("Image", function(){
				    var selection = this.textArea.selectedText();
					if( selection == '') {
					    var response = prompt('Enter image URL',''); 
					    if(response == null)  
					        return;  
						this.textArea.replaceSelection('!'+response+'!');
					} else {
						this.textArea.replaceSelection('!'+selection+'!');
					}
				})
			;
		});
	},
	
	applyEditableImages : function() {
		jQuery('img.editable').each(function(){
			console.log(this.src);
		});
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
		PagesAdmin.applyEditableImages();
		PagesAdmin.applyTextAreas();
		if(PagesAdmin.contentTabs) {
			PagesAdmin.contentTabs.init();
		}
		
		// Call the controller action
		if(PagesAdmin.controller) {
			if(PagesAdmin.controller.init){
				PagesAdmin.controller.init();
			}
			if(PagesAdmin.action && PagesAdmin.controller[PagesAdmin.action]) {
				PagesAdmin.controller[PagesAdmin.action]();
			}
		}
	}
}
var Admin = PagesAdmin;

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