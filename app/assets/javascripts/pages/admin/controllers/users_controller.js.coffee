class Admin.Controllers.UsersController extends Admin.Controllers.Base

  # Login action
  login: ->

    # Toggle regular/OpenID link
    $('.toggle_login').click ->
      if $.cookie("login_mode") is "openid"
        $("#loginOpenID").hide()
        $("#loginRegular").show()
        $.cookie "login_mode", "regular",
          expires: 1095
      else
        $("#loginOpenID").show()
        $("#loginRegular").hide()
        $.cookie "login_mode", "openid",
          expires: 1095

    # Show password recovery
    $('.forgot_password').click ->
      $("#forgotPasswordForm").show()
      $("#loginForm").hide()

    $("#forgotPasswordForm").hide()
    if $.cookie("login_mode") is "openid"
      $("#loginRegular").hide()
    else
      $("#loginOpenID").hide()

  # New action
  new: ->
    controller = this

    # Set a random password
    $("#user_password").val @random_password()

    $('.generate_password').click ->
      $("#user_password").val controller.random_password()

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

    $('.generate_password').click ->
      $("#user_password").val controller.random_password()

  # Generates a random password
  random_password: ->
    password = ""
    pool = "23456789abcdefghjkmnpqrstuvwxyz1234567890ABCDEFGHJKLMNPQRSTUVWXYZ1234567890!@+=?"
    len = 10
    a = 0

    while a < len
      password += pool[Math.floor(Math.random() * pool.length)]
      a++
    password
