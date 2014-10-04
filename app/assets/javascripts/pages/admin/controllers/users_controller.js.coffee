class Admin.Controllers.UsersController extends Admin.Controllers.Base

  # New action
  new: ->
    controller = this

  # Welcome action
  welcome: ->
    @new()

  # Edit action
  edit: ->
    controller = this
