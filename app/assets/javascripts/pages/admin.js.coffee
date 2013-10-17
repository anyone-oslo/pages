# Gem assets
#= require jquery
#= require jquery_ujs
#= require jquery.ui.all
#= require jquery.cookie
#= require jcrop
#= require underscore

# Vendored assets
#= require jquery.dimscreen
#= require jquery.fieldselection

#= require_self
#= require pages/admin/controllers/base
#= require pages/admin/controllers/pages_controller
#= require pages/admin/controllers/users_controller
#= require pages/admin/features/content_tabs
#= require pages/admin/features/editable_image
#= require pages/admin/features/modal
#= require pages/admin/features/page_images
#= require pages/admin/features/rich_text
#= require pages/admin/features/tag_editor
#= require pages/admin/lib/ajax_extensions
#= require pages/admin/lib/center_on_screen
#= require pages/admin/lib/jrichtextarea

window.Admin =
  Controllers: {}

  locale: ->
    $('body').data('locale')

  controllerName: ->
    $('body').data('controller').replace(/^Admin::/, '')

  actionName: ->
    $('body').data('action')

  getController: ->
    if @Controllers.hasOwnProperty(@controllerName())
      new @Controllers[@controllerName()]()

  init: ->
    if controller = @getController()
      controller.dispatch @actionName()


$ ->
  # Detect the sidebar and add the appropriate class to the document element.
  if $("#sidebar").length > 0
    $(document.body).addClass "with_sidebar"

  Admin.init()
