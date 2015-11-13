class TextileDecorator
  blockquote: (str) -> ["bq. ", str, ""]
  bold: (str) -> ["*", str, "*"]
  emphasis: (str) -> ["_", str, "_"]
  h1: (str) -> ["h1. ", str, ""]
  h2: (str) -> ["h2. ", str, ""]
  h3: (str) -> ["h3. ", str, ""]
  h4: (str) -> ["h4. ", str, ""]
  h5: (str) -> ["h5. ", str, ""]
  h6: (str) -> ["h6. ", str, ""]
  link: (url, name) -> ["\"", name, "\":#{url}"]
  email: (address, name) -> ["\"", name, "\":mailto:#{address}"]
  list: (str) ->
    ["", ("* " + line for line in str.split("\n")).join("\n"), ""]
  orderedList: (str) ->
    ["", ("#{i + 1}. " + line for line, i in str.split("\n")).join("\n"), ""]

# Gets the selected text from an element
getSelection = (elem) -> $(elem).getSelection().text

# Gets the selected range from an element
getSelectionRange = (elem) ->
  if typeof elem.selectionStart != "undefined"
    [elem.selectionStart, elem.selectionEnd]
  else
    [0, 0]

# Sets a new selection range for object
setSelectionRange = (elem, start, end) ->
  if typeof elem.setSelectionRange != "undefined"
    elem.setSelectionRange(start, end)

adjustSelection = (elem, callback) ->
  selectionLength = getSelection(elem).length
  [start, end] = getSelectionRange(elem)
  [replacementLength, prefixLength] = callback()
  newEnd = (end + (replacementLength - selectionLength) + prefixLength)
  newStart = if start == end then newEnd else (start + prefixLength)
  setSelectionRange(elem, newStart, newEnd)

replaceSelection = (elem, prefix, replacement, postfix) ->
  adjustSelection elem, ->
    $(elem).replaceSelection(prefix + replacement + postfix)
    $(elem).focus()
    [replacement.length, prefix.length]

RichTextArea = (textarea, options) ->
  # Only apply it once
  return this if textarea.richtext
  textarea.richtext = true

  toolbar = $("<ul class=\"rich-text-toolbar\"></ul>").insertBefore(textarea)

  decorator = -> new TextileDecorator

  addButton = (name, className, callback) ->
    link = $(
      "<a title=\"#{name}\" class=\"#{className}\">" +
      "<i class=\"fa fa-#{className}\"></i></a>"
      )

    link.click ->
      [prefix, replacement, postfix] = callback(getSelection(textarea))
      replaceSelection(textarea, prefix, replacement, postfix)

    $("<li class=\"button\"></li>").append(link).appendTo(toolbar)

  # Bold button
  addButton "Bold", "bold", (selection) -> decorator().bold(selection)

  # Italic button
  addButton "Italics", "italic", (selection) -> decorator().emphasis(selection)

  # Heading buttons
  addButton "Heading 2", "header h2", (selection) -> decorator().h2(selection)
  addButton "Heading 3", "header h3", (selection) -> decorator().h2(selection)
  addButton "Heading 4", "header h4", (selection) -> decorator().h2(selection)

  # Block Quote
  addButton "Block Quote", "quote-left", (selection) ->
    decorator().blockquote(selection)

  # List
  addButton "List", "list-ul", (selection) ->
    decorator().list(selection)

  # Ordered list
  addButton "Ordered list", "list-ol", (selection) ->
    decorator().orderedList(selection)

  # Link button
  addButton "Link", "link", (selection) ->
    url = prompt("Enter link URL", "")
    name = if selection.length > 0 then selection else "Link text"
    url = if url.length > 0 then url else "http://example.com/"
    url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://')
    decorator().link(url, name)

  # Email button
  addButton "Email link", "envelope", (selection) ->
    address = prompt("Enter email address", "")
    name = if selection.length > 0 then selection else "Link text"
    address = if address.length > 0 then address else "example@example.com"
    decorator().email(address, name)

$ ->
  $('textarea.rich').each -> new RichTextArea(this)
