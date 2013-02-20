_ajax_request = (url, data, callback, type, method) ->
  if $.isFunction(data)
    callback = data
    data = {}
  $.ajax
    type: method
    url: url
    data: data
    success: callback
    dataType: type

jQuery.extend
  put: (url, data, callback, type) ->
    _ajax_request url, data, callback, type, "PUT"

  #delete_: (url, data, callback, type) ->
  #  _ajax_request url, data, callback, type, "DELETE"
