// Gem assets
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.Jcrop
//= require underscore
//= require react
//= require react_ujs
//= require reflux.min

// Vendored assets
//= require jquery.dimscreen
//= require jquery.fieldselection
//= require ReactCrop.min

//= require_self
//= require pages/login_form
//= require_tree ./admin/lib

//= require pages/admin/components
//= require_tree ./admin/features

function mergeObject(obj1, obj2) {
  let merge = function(target, source) {
    for (var prop in source) {
      if (source.hasOwnProperty(prop)) {
        target[prop] = source[prop];
      }
    }
    return target;
  }
  return merge(merge({}, obj1), obj2);
}
