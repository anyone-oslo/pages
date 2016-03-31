class PagesController extends BaseController {
  index() {}

  new() {
    this.edit();
  }

  new_news() {
    this.edit();
  }

  show() {
    this.edit();
  }

  edit() {
    $(".advanced-options").hide();
    $(".advanced-toggle").click(function() {
      return $(".advanced-options").slideToggle();
    });

    let checkStatus = function() {
      var pageStatus = $("#page-form-sidebar #page_status").val();
      if (pageStatus === "2") {
        return $("#page-form-sidebar .published-date").fadeIn();
      } else {
        return $("#page-form-sidebar .published-date").hide();
      }
    };

    $("#page-form-sidebar #page_status").change(checkStatus);
    checkStatus();
    $(".autopublish-notice").hide();

    let publishedAt = function(i) {
      return $(`#page-form-sidebar select[name="page[published_at(${i}i)]"]`)
               .val();
    }

    let checkDate = function() {
      var year = publishedAt(1);
      var month = publishedAt(2);
      var day = publishedAt(3);
      var hour = publishedAt(4);
      var minute = publishedAt(5);
      var publishDate = new Date(year, (month - 1), day, hour, minute);
      var now = new Date();
      if (publishDate > now) {
        return $(".autopublish-notice").fadeIn();
      } else {
        return $(".autopublish-notice").fadeOut();
      }
    };

    $(".published-date").find("select").change(checkDate);
    checkDate();

    let replicateFormElement = function() {
      var newValue = this;
      $("#page-form").find("[name=\"" + newValue.name + "\"]")
                     .each(function() {
                       if (newValue.type === "checkbox") {
                         $(this).prop("checked", $(newValue).prop("checked"));
                       } else {
                         $(this).val($(newValue).val());
                       }
                     });
    };

    $("#page-form-sidebar")
      .find("input,textarea,select")
      .change(replicateFormElement);

    $("#new-image").hide();

    $(".upload-images-button").click(function() {
      return Modal.show(
        "<div class=\"uploadImages\">" + $("#new-image").html() + "</div>"
      );
    });

    $(".upload-file-button").click(function() {
      return Modal.show(
        "<div class=\"uploadImages\">" + $("#new-file").html() + "</div>"
      );
    });

    // Reordering files
    $(".file-list").each(function() {
      var list = this;
      return $(list).sortable({
        axis: "y",
        cursor: "move",
        distance: 10,
        handle: ".drag-handle",
        placeholder: "placeholder",

        update(event, ui) {
          return $.post( $(list).data('url'), { ids: ((() => {
            var result = [];
            var iterable = $(list).find('li').get();
            for (var i = 0, item; i < iterable.length; i++) {
              item = iterable[i];
              result.push($(item).data('file-id'));
            }
            return result;
          })()) }, function(response) {
            return $(list).effect("highlight", {}, 500);
            }
          );
        }
      });
    });

    // Previewing
    $("#previewButton").click(function() {
      var button = this;
      var form = $(button).closest("form").get(0);
      var previewUrl = $(this).data('url');

      // Rewrite the form and submit
      form.oldAction = form.action;
      form.target = "_blank";
      form.action = previewUrl;
      $(form).submit();

      // Undo rewrite
      form.action = form.oldAction;
      return form.target = "";
    });

    return $("#new-file").hide();
  }
}

Admin.Controllers.PagesController = PagesController;
