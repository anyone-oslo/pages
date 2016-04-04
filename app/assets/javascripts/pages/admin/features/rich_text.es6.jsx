(function () {
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

    list(str) {
      return ["", ((() => {
        let iterable = str.split("\n");
        var result = [];
        for (var i = 0, line; i < iterable.length; i++) {
          line = iterable[i];
          result.push("* " + line);
        }
        return result;
      })()).join("\n"), ""];
    }

    orderedList(str) {
      return ["", ((() => {
        let iterable = str.split("\n");
        var result = [];
        for (var i = 0, line; i < iterable.length; i++) {
          line = iterable[i];
          result.push("# " + line);
        }
        return result;
      })()).join("\n"), ""];
    }
  }

  // Gets the selected text from an element
  let getSelection = elem => $(elem).getSelection().text

  // Gets the selected range from an element
  let getSelectionRange = function(elem) {
    if (typeof elem.selectionStart !== "undefined") {
      return [elem.selectionStart, elem.selectionEnd];
    } else {
      return [0, 0];
    }
  };

  // Sets a new selection range for object
  let setSelectionRange = function(elem, start, end) {
    if (typeof elem.setSelectionRange !== "undefined") {
      return elem.setSelectionRange(start, end);
    }
  };

  let adjustSelection = function(elem, callback) {
    let length = getSelection(elem).length;
    let [start, end] = getSelectionRange(elem);
    let [replacementLength, prefixLength] = callback();
    let newEnd = (end + (replacementLength - length) + prefixLength);
    let newStart = start === end ? newEnd : (start + prefixLength);
    return setSelectionRange(elem, newStart, newEnd);
  };

  let replaceSelection = function(elem, prefix, replacement, postfix) {
    return adjustSelection(elem, function() {
      $(elem).replaceSelection(prefix + replacement + postfix);
      $(elem).focus();
      return [replacement.length, prefix.length];
    });
  };

  let RichTextArea = function(textarea) {
    // Only apply it once
    if (textarea.richtext) { return this; }
    textarea.richtext = true;

    let toolbar = $("<ul class=\"rich-text-toolbar\"></ul>")
                    .insertBefore(textarea);

    let decorator = () => new TextileDecorator();

    var addButton = function(name, className, callback) {
      var link = $(
        `<a title=\"${name}\" class=\"${className}\">` +
        `<i class=\"fa fa-${className}\"></i></a>`
      );

      link.click(function() {
        let [prefix, replacement, postfix] = callback(getSelection(textarea));
        return replaceSelection(textarea, prefix, replacement, postfix);
      });

      return $("<li class=\"button\"></li>").append(link).appendTo(toolbar);
    };

    // Bold button
    addButton("Bold", "bold", s => decorator().bold(s));

    // Italic button
    addButton("Italics", "italic", s => decorator().emphasis(s));

    // Heading buttons
    addButton("Heading 2", "header h2", s => decorator().h2(s));
    addButton("Heading 3", "header h3", s => decorator().h3(s));
    addButton("Heading 4", "header h4", s => decorator().h4(s));

    // Block Quote
    addButton("Block Quote", "quote-left", s => decorator().blockquote(s))

    // List
    addButton("List", "list-ul", s => decorator().list(s));

    // Ordered list
    addButton("Ordered list", "list-ol", s => decorator().orderedList(s));

    // Link button
    addButton("Link", "link", function(selection) {
      let name = selection.length > 0 ? selection : "Link text";
      var url = prompt("Enter link URL", "");
      url = url.length > 0 ? url : "http://example.com/";
      url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://');
      return decorator().link(url, name);
    });

    // Email button
    return addButton("Email link", "envelope", function(selection) {
      let name = selection.length > 0 ? selection : "Link text";
      var address = prompt("Enter email address", "");
      address = address.length > 0 ? address : "example@example.com";
      return decorator().email(address, name);
    });
  };

  $(function() {
    $('textarea.rich').each(function() { return new RichTextArea(this); });
  });
})();
