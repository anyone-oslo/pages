window.jQueryModal = {
  container: false,

  makeContainer: function() {
    let modal = this;
    if (!this.container) {
      $(document.body).append("<div id=\"modal-container\"/>");
      this.container = $("#modal-container").get(0);
      $(this.container).hide();
      $(window).scroll(function() {
        return modal.position();
      });
      return $(window).resize(function() {
        return modal.position();
      });
    }
  },

  clear: function() {
    return $(this.container).fadeOut(150, function() {
      $(this).html();
      return $("#modalOverlay").fadeOut(50);
    });
  },

  draw: function(options) {
    this.makeContainer();
    $(this.container).show();
    $(this.container).html(
      "<div class=\"container\">" + options.text + "</div>"
    );
    this.position();
    $(document.body).append("<div id=\"modalOverlay\"/>");
    $("#modalOverlay").show().click(function() {
      return jQueryModal.clear();
    }).css({
      position: "absolute",
      top: 0,
      left: 0,
      width: $(document).width() + "px",
      height: $(document).height() + "px",
      "z-index": 19,
      "background-color": "#000000",
      opacity: 0
    }).animate({
      opacity: 0.6
    }, 100);
    return $(this.container).find(".clear-modal").click(function() {
      return jQueryModal.clear();
    });
  },

  position: function() {
    let width = $(this.container).width();
    let height = $(this.container).height();
    let scrollTop = $(window).scrollTop();
    let viewportWidth = (
      window.innerWidth ? window.innerWidth : $(window).width()
    );
    let viewportHeight = (
      window.innerHeight ? window.innerHeight : $(window).height()
    );

    var left = Math.round(viewportWidth / 2) - (width / 2);
    var top = (Math.round(viewportHeight / 2) - (height / 2)) + scrollTop;

    if (top < 5) {
      top = 5;
    }
    if (left < 5) {
      left = 5;
    }

    $("#modalOverlay").css({
      top: 0,
      left: 0,
      width: $(document).width() + "px",
      height: $(document).height() + "px"
    });
    return $(this.container).css("left", left).css("top", top);
  },

  alert: function(string) {
    return this.draw({text: string});
  },

  show: function(string) {
    return this.draw({text: string});
  }
};
