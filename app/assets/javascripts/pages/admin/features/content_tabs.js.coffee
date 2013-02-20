ContentTabs =
  tabs: []
  ids: []

  show: (tab_id) ->
    tabs = ContentTabs.tabs
    tab = tabs[tab_id]
    if tab
      $.each ContentTabs.ids, (i) ->
        $(tabs[this]).hide()  if tabs[this]
        $("#content-tab-link-" + this).removeClass "current"
      $(tab).show()
      $("#content-tab-link-" + tab_id).addClass "current"

  showFromURL: (url) ->
    tab_expression = /#(.*)$/
    if url.toString().match(tab_expression)
      tab_id = url.toString().match(tab_expression)[1]
      ContentTabs.show tab_id  if ContentTabs.tabs[tab_id]

  enable: (tab_ids) ->
    tabs = ContentTabs.tabs
    ContentTabs.ids = tab_ids
    $.each tab_ids, (i) ->
      tab_id = this
      $("#content-tab-" + this).each (i) ->
        @tab_id = tab_id
        tabs[tab_id] = this

    ContentTabs.show tab_ids[0]
    ContentTabs.showFromURL document.location

  init: ->
    if $("#content-tabs").length > 0
      tabNames = $("#content-tabs li").map(->
        $(this).data "tab-name"
      ).get()
      ContentTabs.enable tabNames
      $("#content-tabs a").each ->
        $(this).click ->
          ContentTabs.showFromURL @href
          false

    window.showContentTab = ContentTabs.show

$ ->
  ContentTabs.init()
