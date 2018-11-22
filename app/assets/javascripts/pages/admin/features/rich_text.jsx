class TextileDecorator {
  blockquote(str) { return ["bq. ", str, ""]; }
  bold(str) { return ["<b>", str, "</b>"]; }
  emphasis(str) { return ["<i>", str, "</i>"]; }
  h1(str) { return ["h1. ", str, ""]; }
  h2(str) { return ["h2. ", str, ""]; }
  h3(str) { return ["h3. ", str, ""]; }
  h4(str) { return ["h4. ", str, ""]; }
  h5(str) { return ["h5. ", str, ""]; }
  h6(str) { return ["h6. ", str, ""]; }
  link(url, name) { return ["\"", name, `\":${url}`]; }
  email(address, name) { return ["\"", name, `\":mailto:${address}`]; }

  strToList(str, prefix) {
    return str.split("\n").map(l => prefix +  " " + l).join("\n");
  }

  list(str) {
    return ["", this.strToList(str, "*"), ""];
    return ["", str.split("\n").map(l => "* " + l).join("\n"), ""];
  }

  orderedList(str) {
    return ["", this.strToList(str, "#"), ""];
  }
}

class RichTextArea {
  constructor(textarea) {
    this.textarea = textarea;
    this.decorator = new TextileDecorator();
    this.toolbar = $("<div class=\"rich-text toolbar\"></div>")
                      .insertBefore(this.textarea);
    this.addButtons();
  }

  adjustSelection(callback) {
    let length = this.getSelection().length;
    let [start, end] = this.getSelectionRange();
    let [replacementLength, prefixLength] = callback();
    let newEnd = (end + (replacementLength - length) + prefixLength);
    let newStart = start === end ? newEnd : (start + prefixLength);
    return this.setSelectionRange(newStart, newEnd);
  };

  getSelection() {
    return $(this.textarea).getSelection().text;
  }

  getSelectionRange() {
    if (typeof this.textarea.selectionStart !== "undefined") {
      return [this.textarea.selectionStart, this.textarea.selectionEnd];
    } else {
      return [0, 0];
    }
  };

  replaceSelection(prefix, replacement, postfix) {
    return this.adjustSelection(() => {
      $(this.textarea).replaceSelection(prefix + replacement + postfix);
      if (typeof this.textarea.focus !== "undefined") {
        this.textarea.focus({ preventScroll: true });
      }
      return [replacement.length, prefix.length];
    });
  };

  // Sets a new selection range for object
  setSelectionRange(start, end) {
    if (typeof this.textarea.setSelectionRange !== "undefined") {
      return this.textarea.setSelectionRange(start, end);
    }
  };

  addButton(name, className, callback) {
    var link = $(
      `<a title=\"${name}\" class=\"button ${className}\">` +
      `<i class=\"fa fa-${className}\"></i></a>`
    );

    link.click((evt) => {
      evt.preventDefault();
      let [prefix, replacement, postfix] = callback(this.getSelection());
      this.replaceSelection(prefix, replacement, postfix);
    });

    //$("<li class=\"button\"></li>").append(link).appendTo(this.toolbar);
    $(this.toolbar).append(link);
  };

  addButtons() {
    // Bold button
    this.addButton("Bold", "bold", s => this.decorator.bold(s));

    // Italic button
    this.addButton("Italics", "italic", s => this.decorator.emphasis(s));

    // Heading buttons
    this.addButton("Heading 2", "header h2", s => this.decorator.h2(s));
    this.addButton("Heading 3", "header h3", s => this.decorator.h3(s));
    this.addButton("Heading 4", "header h4", s => this.decorator.h4(s));

    // Block Quote
    this.addButton("Block Quote", "quote-left", s => this.decorator.blockquote(s))

    // List
    this.addButton("List", "list-ul", s => this.decorator.list(s));

    // Ordered list
    this.addButton("Ordered list", "list-ol", s => this.decorator.orderedList(s));

    // Link button
    this.addButton("Link", "link", selection => {
      let name = selection.length > 0 ? selection : "Link text";
      var url = prompt("Enter link URL", "");
      url = url.length > 0 ? url : "http://example.com/";
      url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://');
      return this.decorator.link(url, name);
    });

    // Email button
    this.addButton("Email link", "envelope", selection => {
      let name = selection.length > 0 ? selection : "Link text";
      var address = prompt("Enter email address", "");
      address = address.length > 0 ? address : "example@example.com";
      return this.decorator.email(address, name);
    });
  }
}

$(function() {
  $('textarea.rich').each(function() { new RichTextArea(this); });
});
