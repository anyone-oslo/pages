$ ->
  $('.login-form').each ->
    container = this

    showTab = (tabName) ->
      $(container).find('.login-tab').hide()
      $(container).find(".login-tab.#{tabName}").show()
      false

    $(container).find('.show-password').click ->
      $.cookie "login-mode", "password", expires: 1095
      showTab('password')

    $(container).find('.show-password-reset').click ->
      showTab('password-reset')

    showTab('password')