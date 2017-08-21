var EditableImage = function(link, options) {
  let settings = $.extend({
    resourceURL: link.href,
    width: 800
  }, options);

  this.editableImage = {
    settings: settings,
    link: link,
    linkedImage: $(link).children("img")[0],
    resourceURL: settings.resourceURL,
    editorDialog: false,
    imageData: false,
    previewURL: false,
    cropStartX: false,
    cropStartY: false,
    cropWidth: false,
    cropHeight: false,

    getScale: function() {
      return this.settings.width / this.imageData.real_width;
    },

    openEditor: function() {
      $.dimScreen(200, 0.90);
      $("body").append(
        "<div id=\"modalLoadingNotice\">" +
        "<img src=\"<%= image_path('pages/admin/loading-modal.gif') %>\" /> " +
        "Loading image editor&hellip;</div>"
      );
      $("#modalLoadingNotice").centerOnScreen().hide().fadeIn(200);
      $("#editableImageEditor").remove();
      $("body").append(
        "<div id=\"editableImageEditor\" class=\"modal-window\"></div>"
      );

      let binding = this;
      if (!this.imageData) {
        $.getJSON(this.resourceURL + ".js", function(json) {
          binding.imageData = json;
          binding.populateEditor();
        });
      } else {
        this.populateEditor();
      }
    },

    populateEditor: function() {
      let binding = this;

      let onCrop = function(coords) {
        binding.cropStartX = coords.x;
        binding.cropStartY = coords.y;
        binding.cropWidth = coords.w;
        return binding.cropHeight = coords.h;
      };

      $("#editableImageEditor").empty().append(
        "<img id=\"editableImageEditorImage\" />"
      ).append(
        "<div id=\"editableImageEditorControls\" class=\"controls\" />"
      ).hide();

      $("#editableImageEditorControls").append(
        "<input type=\"button\" id=\"editableImageEditorSubmit\" " +
        "value=\"Save\" />"
      ).append(
        "<input type=\"button\" id=\"editableImageEditorClose\" " +
        "value=\"Cancel\" />"
      );

      this.previewURL = $(link).data('preview-url');

      $("#editableImageEditorImage").each(function() {
        return this.src = binding.previewURL;
      });
      $("#editableImageEditorSubmit").click(function() {
        return binding.submit();
      });
      $("#editableImageEditorClose").click(function() {
        return binding.closeEditor();
      });

      $("#editableImageEditorImage").load(function() {
        let imageData = binding.imageData;
        let cropStartX = Math.round(imageData.cropStartX * binding.getScale());
        let cropStartY = Math.round(imageData.cropStartY * binding.getScale());

        var cropEndX, cropEndY;
        var jCropOptions = {
          onChange: onCrop,
          onSelect: onCrop
        };

        $("#modalLoadingNotice").fadeOut(100);
        $("#editableImageEditor").show().centerOnScreen();

        if (imageData.crop_width && imageData.crop_height) {
          cropEndX = cropStartX +
                     Math.round(imageData.crop_width * binding.getScale());
          cropEndY = cropStartY +
                     Math.round(imageData.crop_height * binding.getScale());
        } else {
          cropEndX = Math.round(imageData.real_width * binding.getScale());
          cropEndY = Math.round(imageData.real_height * binding.getScale());
        }

        jCropOptions["setSelect"] = [cropStartX, cropStartY, cropEndX, cropEndY];
        return $("#editableImageEditorImage").Jcrop(jCropOptions);
      });
    },

    closeEditor: function() {
      $("#modalLoadingNotice").remove();
      $("#editableImageEditor").remove();
      this.imageData = false;
      $.dimScreenStop();
    },

    submit: function() {
      let binding = this;
      let data = {
        "image[crop_start_x]": Math.floor(this.cropStartX / this.getScale()),
        "image[crop_start_y]": Math.floor(this.cropStartY / this.getScale()),
        "image[crop_width]":   Math.floor(this.cropWidth / this.getScale()),
        "image[crop_height]":  Math.floor(this.cropHeight / this.getScale())
      };
      $.put(this.resourceURL + ".json", data, function(json) {
        binding.closeEditor();
      });
    }
  };

  link.editableImage = this.editableImage;
  $(link).click(function() {
    this.editableImage.openEditor();
    return false;
  });
};

$(function() {
  $("a.editableImage").each(function() {
    new EditableImage(this);
  });
});
