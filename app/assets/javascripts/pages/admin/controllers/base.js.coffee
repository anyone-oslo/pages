class Admin.Controllers.Base
  dispatch: (action) ->
    if @[action]
      @[action]()