$ ->
  $("textarea.rich").each ->
    ta = new jRichTextArea(this)

    ta.toolbar.addButton("Bold", ->
      @textArea.wrapSelection "*"

    ).addButton("Italics", ->
      @textArea.wrapSelection "_"

    ).addButton("Heading 2", ->
      @textArea.wrapSelection "h2. ", ""

    ).addButton("Heading 3", ->
      @textArea.wrapSelection "h3. ", ""

    ).addButton("Heading 4", ->
      @textArea.wrapSelection "h4. ", ""

    ).addButton("Link", ->
      selection = @textArea.selectedText()
      selection = prompt("Link text", "")  if selection is ""
      response = prompt("Enter link URL", "http://")
      if response
        @textArea.replaceSelection "\"" + ((if selection is "" then "Link text" else selection)) + "\":" + ((if response is "" then "http://link_url/" else response)).replace(/^(?!(f|ht)tps?:\/\/)/, "http://")

    ).addButton("Email", ->
      selection = @textArea.selectedText()
      response = prompt("Enter mail address", "")
      if response
        @textArea.replaceSelection "\"" + ((if selection is "" then response else selection)) + "\":mailto:" + ((if response is "" then "" else response))

    ).addButton "Image", ->
      selection = @textArea.selectedText()
      if selection is ""
        response = prompt("Enter image URL", "")
        return  unless response?
        @textArea.replaceSelection "!" + response + "!"
      else
        @textArea.replaceSelection "!" + selection + "!"

