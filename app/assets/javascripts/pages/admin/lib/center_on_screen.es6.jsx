jQuery.fn.centerOnScreen = function() {
  this.css("position", "absolute");
  this.css("z-index", 1000 + (Math.round(Math.random() * 5000)));

  var x = ((($(window).width() / 2) - (this.width() / 2)) +
          $(window).scrollLeft()),
      y = ((($(window).height() / 2) - (this.height() / 2)) +
          $(window).scrollTop());

  if (x < 0) {
    x = 0;
  }

  if (y < 0) {
    y = 0;
  }

  this.css({left: x + "px", top: y + "px"});

  return this;
};
