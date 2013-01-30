(function ($) {
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
        $.getJSON(baseURL + '/page_images.json', function (json) {
          imagesData = json;
        });
      }
      loadImagesData();

      function updateImageData(data) {
        for (var a = 0; a < imagesData.length; a++) {
          if (imagesData[a].id == data.id) {
            imagesData[a] = data;
          } else if (data.primary) {
            imagesData[a].primary = false;
          }
        }
      }

      function getImageData (imageId) {
        var data = false;
        for (var a = 0; a < imagesData.length; a++) {
          if (imagesData[a].id == parseInt(imageId, 10)) {
            data = imagesData[a];
          }
        }
        return data;
      }

      function parseSizeString (size) {
        size = size.split('x');
        var width  = parseInt(size[0], 10);
        var height = parseInt(size[1], 10);
        return [width, height];
      }

      function getImageSize (imageId) {
        return parseSizeString(getImageData(imageId).image.original_size);
      }

      function getImageURL (imageId, maxWidth, maxHeight) {
        var originalSize = parseSizeString(imageData.image.original_size);
        return imageData;
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
          var imageData = getImageData(imageId);

          // Show the editor
          $('.page_images .uploadButton').hide();
          $editor.find('#page_image_byline').val(imageData.image.byline);
          if (imageData.primary) {
            $editor.find('#page_image_primary').attr('checked', 'checked');
          } else {
            $editor.find('#page_image_primary').attr('checked', false);
          }
          $(container).find('.image').removeClass('selected');
          $(image).addClass('selected');
          selectedImage = image;
          selectedImageId = imageId;
          $editor.slideDown(400);

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
          var imageURL = '/dynamic_image/' +
            imageData.image.id +
            '/original/' +
            resizedSize[0] + 'x' + resizedSize[1] +
            '/' + imageData.image.filename;

          $editor.find('.edit_image').html(
            '<img src="' +
            imageURL + '" width="' + resizedSize[0] +
            '" height="' + resizedSize[1] + '" />'
          );

          // Handle cropping
          var cropStart = parseSizeString(imageData.image.crop_start);
          var cropSize  = parseSizeString(imageData.image.crop_size);

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
            $editor.find('#page_image_crop_start').val(
              start[0] + 'x' + start[1]
            );
            $editor.find('#page_image_crop_size').val(
              size[0] + 'x' + size[1]
            );
          };

          $editor.find('.edit_image img').Jcrop({
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

      function reloadThumbnail () {
        if (selectedImage && selectedImageId) {
          // Changes the image URL to include the timestamp, which forces a reload
          var imageData = getImageData(selectedImageId);
          var timestamp = imageData.image.updated_at.replace(/[^\d]/g, '');
          var imageUrl = $(selectedImage).find('img').attr('src').split('?')[0];
          $(selectedImage).find('img').attr('src', imageUrl + '?' + timestamp);
        }
      }

      // Sorting images
      var saveImageOrder = function () {
        var ids = [];
        images = [];
        $('.page_images .images .image').each(function () {
          images.push(this);
          ids.push(parseInt($(this).data('page-image-id'), 10));
        });
        $('.page_images .images').animate({opacity: 0.8}, 300);
        var url = baseURL + '/page_images/reorder.json';
        var data = {ids: ids};
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
          'page_image[byline]':     $editor.find('#page_image_byline').val(),
          'page_image[primary]':    $editor.find('#page_image_primary').is(':checked'),
          'page_image[crop_start]': $editor.find('#page_image_crop_start').val(),
          'page_image[crop_size]':  $editor.find('#page_image_crop_size').val()
        };
        var url = baseURL + '/page_images/' + savedId + '.json';
        $.put(url, data, function (json) {
          updateImageData(json);
          reloadThumbnail();

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
            var url = baseURL + '/page_images/' + selectedImageId + '.json';
            $.ajax(url, {
              type: 'DELETE',
              success: function () {
                var deletedImage = selectedImage;
                if (images.length > 1) {
                  showNextImage();
                } else {
                  $(container).find('.no_images').slideDown();
                  closeEditor();
                }
                images = _.reject(images, function (i) {
                  return i == deletedImage;
                });
                $(deletedImage).remove();
              }
            });
          }
        }
        return false;
      }

      $editor.find('a.next').click(showNextImage);
      $editor.find('a.previous').click(showPreviousImage);
      $editor.find('a.close').click(closeEditor);
      $editor.find('button.save').click(saveImage);
      $editor.find('a.delete').click(deleteImage);

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
      });

      $('.page_images .images').sortable({
        forcePlaceholderSize: true,
        update:               saveImageOrder,
        distance:             5
      });
      $('.page_images .image').disableSelection();

    });
  });
})(jQuery);
