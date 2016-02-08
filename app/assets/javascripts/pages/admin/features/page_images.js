$(function () {
  $('.page_images').each(function () {
    var container = this;
    var $editor = $(container).find('.editor');

    $editor.hide();

    var baseURL = $editor.closest('form').attr('action');

    var selectedImage = false;
    var selectedImageId = false;
    var images = [];
    var imagesData = false;

    function loadImagesData () {
      $.getJSON(baseURL + '/images.json', function (json) {
        imagesData = json["page_images"];
      });
    }
    loadImagesData();

    function updateImageData(data) {
      for (var a = 0; a < imagesData.length; a++) {
        if (imagesData[a].id === data.id) {
          imagesData[a] = data;
        } else if (data.primary) {
          imagesData[a].primary = false;
        }
      }
    }

    function getImageData (imageId) {
      var data = false;
      for (var a = 0; a < imagesData.length; a++) {
        if (imagesData[a].id === parseInt(imageId, 10)) {
          data = imagesData[a];
        }
      }
      return data;
    }

    function getImageSize (imageId) {
      var imageData = getImageData(imageId).image;
      return [imageData.real_width, imageData.real_height];
    }

    function getImageURL (imageId, maxWidth, maxHeight) {
      return imageData;
    }

    function showEditor (image, imageData) {
      // Show the editor
      $('.page_images .uploadButton').hide();
      $editor.find('.caption').val(imageData.image.caption);
      $editor.find('.alternative').val(imageData.image.alternative);
      $editor.find('.embed').val("[image:" + imageData.image.id + "]");
      $editor.find('.image_id').val(imageData.image.id);

      if (imageData.primary) {
        $editor.find('#page_image_primary').attr('checked', 'checked');
      } else {
        $editor.find('#page_image_primary').attr('checked', false);
      }
      $(container).find('.image').removeClass('selected');
      $(image).addClass('selected');
      $editor.slideDown(400);
    }

    function cropImage (imageData, imageSize, scaleFactor) {
      // Handle cropping
      var cropStart = [
        imageData.image.crop_start_x,
        imageData.image.crop_start_y
      ];

      var cropSize = [
        (imageSize[0] - cropStart[0]),
        (imageSize[1] - cropStart[1])
      ]

      if (imageData.image.crop_width && imageData.image.crop_height) {
        cropSize = [
          imageData.image.crop_width,
          imageData.image.crop_height
        ];
      }

      var updateCrop = function (crop) {
        var start = [0, 0];
        var size = imageSize;
        if (crop.w > 0 && crop.h > 0) {
          start = [
            Math.floor(crop.x / scaleFactor),
            Math.floor(crop.y / scaleFactor)
          ];
          size = [
            Math.floor(crop.w / scaleFactor),
            Math.floor(crop.h / scaleFactor)
          ];
        }
        $editor.find('.crop_start_x').val(start[0]);
        $editor.find('.crop_start_y').val(start[1]);
        $editor.find('.crop_width').val(size[0]);
        $editor.find('.crop_height').val(size[1]);
      };

      $editor.find('.edit-image img').Jcrop({
        setSelect: [
          Math.floor(cropStart[0] * scaleFactor),
          Math.floor(cropStart[1] * scaleFactor),
          Math.floor(cropStart[0] * scaleFactor) + Math.floor(cropSize[0] * scaleFactor),
          Math.floor(cropStart[1] * scaleFactor) + Math.floor(cropSize[1] * scaleFactor)
        ],
        onSelect: updateCrop,
        onChange: updateCrop
      });
    }

    function showImage (image) {
      // Delay execution if imageData is unavailable
      if (imagesData === false) {
        setTimeout(function () {
          showImage(image);
        }, 100);
        return false;
      }

      if (image) {
        var imageId   = parseInt($(image).data('page-image-id'), 10);
        var imageURL  = $(image).data('uncropped-url');
        var imageData = getImageData(imageId);

        showEditor(image, imageData);
        selectedImage = image;
        selectedImageId = imageId;

        // Determine resized size
        var maxSize   = [($editor.width() - 40), ($(window).height() - 200)];
        var imageSize = getImageSize(imageId);
        var scaleFactor = maxSize[1] / imageSize[1];
        if ((imageSize[0] * scaleFactor) > maxSize[0]) {
          scaleFactor = maxSize[0] / imageSize[0];
        }
        if (scaleFactor > 1.0) {
          scaleFactor = 1.0;
        }
        var resizedSize = [
          Math.floor(imageSize[0] * scaleFactor),
          Math.floor(imageSize[1] * scaleFactor)
        ];

        // Load the image
        $editor.find('.edit-image').html(
          '<img src="' +
          imageURL + '" width="' + resizedSize[0] +
          '" height="' + resizedSize[1] + '" />'
        );

        cropImage(imageData, imageSize, scaleFactor);
      }
    }

    function closeEditor () {
      $(container).find('.image').removeClass('selected');
      selectedImage = false;
      selectedImageId = false;
      $editor.slideUp(400);
      $('.page_images .uploadButton').slideDown(400);
      return false;
    }

    function showNextImage () {
      var nextIndex = false;
      if (selectedImage) {
        nextIndex = $.inArray(selectedImage, images) + 1;
      }
      if (nextIndex !== false) {
        if (images[nextIndex]) {
          showImage(images[nextIndex]);
        } else {
          showImage(images[0]);
        }
      }
      return false;
    }

    function showPreviousImage () {
      var nextIndex = false;
      if (selectedImage) {
        nextIndex = $.inArray(selectedImage, images) - 1;
      }
      if (nextIndex !== false) {
        if (nextIndex < 0) {
          nextIndex = images.length - 1;
        }
        if (images[nextIndex]) {
          showImage(images[nextIndex]);
        } else {
          showImage(images[0]);
        }
      }
      return false;
    }

    // Sorting images
    function saveImageOrder () {
      var ids = [];
      images = [];
      $('.page_images .images .image').each(function () {
        images.push(this);
        ids.push(parseInt($(this).data('page-image-id'), 10));
      });
      $('.page_images .images').animate({opacity: 0.8}, 300);
      var url = baseURL + '/images/reorder.json';
      var data = {
        ids: ids,
        authenticity_token: $("input[name=authenticity_token]").val()
      };
      $.put(url, data, function (json) {
        $('.page_images .images').animate({opacity: 1.0}, 300);
      });
    };

    function setPrimaryImage (newPrimary) {
      var $previousPrimary = $(container).find('.primary');
      if ($previousPrimary.length > 0) {
        var thumbURL = $previousPrimary.find('img').attr('src').replace('220x220', '100x100');
        $previousPrimary.find('img').attr('src', thumbURL);
        $previousPrimary
            .removeClass('primary')
            .remove()
            .appendTo($(container).find('.images'));
        $previousPrimary.hide().fadeIn(400);
      }

      if (newPrimary) {
        $(newPrimary)
            .addClass('primary')
            .remove()
            .appendTo($(container).find('.primary_container'));
        var bigURL = $(newPrimary).find('img').attr('src').replace('100x100', '220x220');
        $(newPrimary).find('img').attr('src', bigURL);
        $(newPrimary).hide().fadeIn(400);
      }
      saveImageOrder();
    }

    function saveImage () {
      var savedId = selectedImageId;
      var savedImage = selectedImage;
      $editor.animate({opacity: 0.8}, 300);
      var data = {
        'page_image[primary]': $editor.find('#page_image_primary').is(':checked'),
        'page_image[image_attributes][id]': $editor.find('.image_id').val(),
        'page_image[image_attributes][caption]': $editor.find('.caption').val(),
        'page_image[image_attributes][alternative]': $editor.find('.alternative').val(),
        'page_image[image_attributes][crop_start_x]': $editor.find('.crop_start_x').val(),
        'page_image[image_attributes][crop_start_y]': $editor.find('.crop_start_y').val(),
        'page_image[image_attributes][crop_width]': $editor.find('.crop_width').val(),
        'page_image[image_attributes][crop_height]': $editor.find('.crop_height').val(),
        authenticity_token: $("input[name=authenticity_token]").val()
      };
      var url = baseURL + '/images/' + savedId + '.json';
      $.put(url, data, function (json) {
        updateImageData(json);

        // Shuffle primary image around
        if (json.primary && !$(savedImage).hasClass('primary')) {
          setPrimaryImage(savedImage);
        } else if (!json.primary && $(savedImage).hasClass('primary')) {
          setPrimaryImage(false);
        }

        $editor.animate({opacity: 1.0}, 300);
      });
      return false;
    }

    function deleteImage () {
      if (selectedImage && selectedImageId) {
        if (confirm('Are you sure you want to delete this image?')) {
          var url = baseURL + '/images/' + selectedImageId + '.json';
          $.ajax(url, {
            type: 'DELETE',
            authenticity_token: $("input[name=authenticity_token]").val(),
            success: function () {
              var deletedImage = selectedImage;
              if (images.length > 1) {
                showNextImage();
              } else {
                $(container).find('.no_images').slideDown();
                closeEditor();
              }
              images = _.reject(images, function (i) {
                return i === deletedImage;
              });
              $(deletedImage).remove();
            }
          });
        }
      }
      return false;
    }

    function applyButtonActions (container) {
      container.find('a.next').click(showNextImage);
      container.find('a.previous').click(showPreviousImage);
      container.find('a.close').click(closeEditor);
      container.find('button.save').click(saveImage);
      container.find('a.delete').click(deleteImage);
    }

    applyButtonActions($editor);

    // Find images
    $(container).find('.image').each(function () {
      images.push(this);
      $(this).find('img').removeAttr('width').removeAttr('height');
    });
    if (images.length > 0) {
      $(container).find('.no_images').hide();
    }

    $(container).on('click', '.image', function () {
      showImage(this);
      return false;
    });

    $('.page_images .images').sortable({
      forcePlaceholderSize: true,
      update:               saveImageOrder,
      distance:             5
    });
    $('.page_images .image').disableSelection();

  });
});
