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
#= require_tree "./admin"

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
