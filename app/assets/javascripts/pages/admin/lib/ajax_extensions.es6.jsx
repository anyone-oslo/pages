(function () {
  let _ajax_request = function(url, data, callback, type, method) {
    if ($.isFunction(data)) {
      callback = data;
      data = {};
    }
    return $.ajax({
      type: method,
      url: url,
      data: data,
      success: callback,
      dataType: type
    });
  };

  jQuery.extend({
    put: function(url, data, callback, type) {
      return _ajax_request(url, data, callback, type, "PUT");
    }
  });
})();
