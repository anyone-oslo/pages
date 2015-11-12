window.Modal =
  container: false

  makeContainer: ->
    modal = this
    unless @container
      $(document.body).append "<div id=\"modal-container\"/>"
      @container = $("#modal-container").get(0)
      $(@container).hide()
      $(window).scroll ->
        modal.position()
      $(window).resize ->
        modal.position()

  clear: ->
    $(@container).fadeOut 150, ->
      $(this).html()
      $("#modalOverlay").fadeOut 50

  draw: (options) ->
    modal = this
    @makeContainer()
    $(@container).show()
    $(@container).html "<div class=\"container\">" + options.text + "</div>"
    @position()
    $(document.body).append "<div id=\"modalOverlay\"/>"
    $("#modalOverlay").show().click(->
      Modal.clear()
    ).css(
      position: "absolute"
      top: 0
      left: 0
      width: $(document).width() + "px"
      height: $(document).height() + "px"
      "z-index": 19
      "background-color": "#000000"
      opacity: 0
    ).animate
      opacity: 0.6
    , 100
    $(@container).find(".clear-modal").click ->
      Modal.clear()

  position: ->
    width = $(@container).width()
    height = $(@container).height()
    scrollTop = $(window).scrollTop()
    viewportWidth = (if window.innerWidth then window.innerWidth else $(window).width())
    viewportHeight = (if window.innerHeight then window.innerHeight else $(window).height())
    left = Math.round(viewportWidth / 2) - (width / 2)
    top = (Math.round(viewportHeight / 2) - (height / 2)) + scrollTop
    top = 5  if top < 5
    left = 5  if left < 5
    $("#modalOverlay").css
      top: 0
      left: 0
      width: $(document).width() + "px"
      height: $(document).height() + "px"

    $(@container).css("left", left).css "top", top

  alert: (string) ->
    @draw text: string

  show: (string) ->
    @draw text: string
