class Admin.Controllers.PagesController extends Admin.Controllers.Base

  index: ->
    $("#reorder_link").click ->
      link = this
      list = $(".pagelist").get(0)
      if $(list).hasClass("reorder")
        $(link).html "Reorder pages"
        $(list).removeClass "reorder"
      else
        $(link).html "Done reordering"
        $(list).addClass "reorder"

    $("ul.reorderable").each ->
      list = this
      $(list).sortable
        axis: "y"
        cursor: "move"
        distance: 10
        handle: ".drag_handle"
        update: (event, ui) ->
          new_order = []
          parent_page_id = $(list).attr("parent_page_id")
          $(list).children("li").each ->
            new_order.push $(this).attr("page_id")

          reorder_url = "/admin/" + Admin.locale() + "/pages/reorder_pages"
          $.get reorder_url,
            ids: new_order
          , (data) ->
            $(list).effect "highlight", {}, 1500

    # Hover actions on .page .actions
    $(".page").hover (->
      $(this).addClass "hover"
      $(this).children(".actions").css "visibility", "visible"
    ), ->
      $(this).removeClass "hover"
      $(this).children(".actions").css "visibility", "hidden"

    $(".page .actions").css "visibility", "hidden"

    # Toggling of the new category input
    window.toggleNewCategory = ->
      $("#new-category").toggle()
      $("#new-category-button").toggle()

    $("#new-category").hide()

  new: ->

  new_news: ->

  show: ->
    @edit()

  edit: ->
    $(".advanced_options").hide()
    $(".advanced_toggle").click ->
      $(".advanced_options").slideToggle()

    checkStatus = ->
      pageStatus = $("#page-form-sidebar #page_status").val()
      if pageStatus is 2
        $("#page-form-sidebar .published_date").fadeIn()
      else
        $("#page-form-sidebar .published_date").hide()

    $("#page-form-sidebar #page_status").change checkStatus
    checkStatus()
    $(".autopublish_notice").hide()

    checkDate = ->
      year = $("#page-form-sidebar select[name=\"page[published_at(1i)]\"]").val()
      month = $("#page-form-sidebar select[name=\"page[published_at(2i)]\"]").val()
      day = $("#page-form-sidebar select[name=\"page[published_at(3i)]\"]").val()
      hour = $("#page-form-sidebar select[name=\"page[published_at(4i)]\"]").val()
      minute = $("#page-form-sidebar select[name=\"page[published_at(5i)]\"]").val()
      publishDate = new Date(year, (month - 1), day, hour, minute)
      now = new Date()
      if publishDate > now
        $(".autopublish_notice").fadeIn()
      else
        $(".autopublish_notice").fadeOut()

    $(".published_date").find("select").change checkDate
    checkDate()

    replicateFormElement = ->
      newValue = this
      $("#page-form").find("[name=\"" + newValue.name + "\"]").each ->
        if newValue.type is "checkbox"
          $(this).attr "checked", $(newValue).attr("checked")
        else
          $(this).val $(newValue).val()

    $("#page-form-sidebar").find("input,textarea,select").change replicateFormElement
    $("#new-image").hide()
    window.showAdditionalImageModal = ->
      Modal.show "<div class=\"uploadImages\">" + $("#new-image").html() + "</div>"


    # Previewing
    $("#previewButton").click ->
      button = this
      form = $(button).closest("form").get(0)
      previewUrl = "/" + Admin.locale() + "/pages/preview"

      # Rewrite the form and submit
      form.oldAction = form.action
      form.target = "_blank"
      form.action = previewUrl
      $(form).submit()

      # Undo rewrite
      form.action = form.oldAction
      form.target = ""

    $("#new-file").hide()