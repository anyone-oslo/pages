window.jRichTextArea = function(textArea, options){
  this.textArea = textArea;

  // Default options
  settings = $.extend({
       className: "richTextToolbar"
  }, options);

  this.toolbar = {
    settings : settings,
    textArea : textArea,
    listElement : false,
    buttons : new Array(),
    addButton : function(name, callback, options) {
      // Default options
      settings = $.extend({
           className: name.replace(/[\s]+/, '')+"Button"
      }, options);
      var li = document.createElement("li");
      var a = document.createElement("a");
      a.title = name;
      a.textArea = this.textArea;
      //callback.this = this;
      $(a).mousedown(callback);
      $(a).addClass(settings.className);
      $(li).append(a).appendTo(this.listElement);
      this.buttons.push(li);
      return this;
    },
    create : function() {
      if(!this.listElement) {
        this.listElement = document.createElement("ul");
        $(this.listElement).addClass(this.settings.className);
        $(this.listElement).insertBefore(this.textArea);
      }
    }
  }

  this.textArea.selectedText = function() {
    return $(this).getSelection().text;
  }
  this.textArea.replaceSelection = function(replacement) {
    return $(this).replaceSelection(replacement);
  }
  this.textArea.wrapSelection = function() {
    var prepend = arguments[0];
    var append = (arguments.length > 1) ? arguments[1] : prepend
    var selectedText = this.selectedText();
    var trailingSpace = selectedText.match(/(\s)*$/)[0];
    selectedText = selectedText.replace(/(\s)*$/, '');
    return this.replaceSelection(prepend + selectedText + append + trailingSpace);
  }

  // Delegates
  this.textArea.toolbar = this.toolbar;
  this.toolbar.create();
}
