class Admin.Controllers.PagesController extends Admin.Controllers.Base

  index: ->

  new: ->
    @edit()

  new_news: ->
    @edit()

  show: ->
    @edit()

  edit: ->
    $(".advanced-options").hide()
    $(".advanced-toggle").click ->
      $(".advanced-options").slideToggle()

    checkStatus = ->
      pageStatus = $("#page-form-sidebar #page_status").val()
      if pageStatus == "2"
        $("#page-form-sidebar .published-date").fadeIn()
      else
        $("#page-form-sidebar .published-date").hide()

    $("#page-form-sidebar #page_status").change checkStatus
    checkStatus()
    $(".autopublish-notice").hide()

    checkDate = ->
      year = $("#page-form-sidebar select[name=\"page[published_at(1i)]\"]").val()
      month = $("#page-form-sidebar select[name=\"page[published_at(2i)]\"]").val()
      day = $("#page-form-sidebar select[name=\"page[published_at(3i)]\"]").val()
      hour = $("#page-form-sidebar select[name=\"page[published_at(4i)]\"]").val()
      minute = $("#page-form-sidebar select[name=\"page[published_at(5i)]\"]").val()
      publishDate = new Date(year, (month - 1), day, hour, minute)
      now = new Date()
      if publishDate > now
        $(".autopublish-notice").fadeIn()
      else
        $(".autopublish-notice").fadeOut()

    $(".published-date").find("select").change checkDate
    checkDate()

    replicateFormElement = ->
      newValue = this
      $("#page-form").find("[name=\"" + newValue.name + "\"]").each ->
        if newValue.type is "checkbox"
          $(this).prop "checked", $(newValue).prop("checked")
        else
          $(this).val $(newValue).val()

    $("#page-form-sidebar").find("input,textarea,select").change replicateFormElement
    $("#new-image").hide()

    $(".upload-images-button").click ->
      Modal.show "<div class=\"uploadImages\">" + $("#new-image").html() + "</div>"

    $(".upload-file-button").click ->
      Modal.show "<div class=\"uploadImages\">" + $("#new-file").html() + "</div>"

    # Reordering files
    $(".file-list").each ->
      list = this
      $(list).sortable
        axis: "y"
        cursor: "move"
        distance: 10
        handle: ".drag-handle"
        placeholder: "placeholder"
        update: (event, ui) ->
          $.post $(list).data('url'),
            ids: ($(item).data('file-id') for item in $(list).find('li').get())
          , (response) ->
            $(list).effect "highlight", {}, 500

    # Previewing
    $("#previewButton").click ->
      button = this
      form = $(button).closest("form").get(0)
      previewUrl = $(this).data('url')

      # Rewrite the form and submit
      form.oldAction = form.action
      form.target = "_blank"
      form.action = previewUrl
      $(form).submit()

      # Undo rewrite
      form.action = form.oldAction
      form.target = ""

    $("#new-file").hide()
