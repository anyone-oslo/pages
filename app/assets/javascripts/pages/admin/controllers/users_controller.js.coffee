class Admin.Controllers.UsersController extends Admin.Controllers.Base

  # New action
  new: ->
    controller = this

    # Automatically generate a username from the email address
    $("#user_username").focus ->
      if $("#user_email").val() and not $(this).val()
        new_username = $("#user_email").val()
        new_username = new_username.match(/(.*)@/)[1]  if new_username.match(/@/)
        $(this).val new_username

  # Welcome action
  welcome: ->
    @new()

  # Edit action
  edit: ->
    controller = this
