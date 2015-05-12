# Gem assets
#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require jquery.cookie
#= require jquery.Jcrop
#= require underscore
#= require react
#= require react_ujs

# Vendored assets
#= require jquery.dimscreen
#= require jquery.fieldselection

#= require_self
#= require pages/login_form
#= require pages/admin/components
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
  Admin.init()
