jQuery.fn.centerOnScreen = ->
  win_width = $(window).width()
  scrollToLeft = $(window).scrollLeft()
  win_height = $(window).height()
  scrollToBottom = $(window).scrollTop()
  box_width = 200
  box_height = 200

  @css "position", "absolute"
  @css "z-index", (1000 + (Math.round(Math.random() * 5000)))

  x = (($(window).width() / 2) - (@width() / 2)) + $(window).scrollLeft()
  y = (($(window).height() / 2) - (@height() / 2)) + $(window).scrollTop()
  x = 0  if x < 0
  y = 0  if y < 0

  @css
    left: x + "px"
    top: y + "px"

  this