(function ($) {
	$(function () {
		$('.page_images').each(function () {
			var container = this;
			var $editor = $(container).find('.editor');

			$editor.hide();

			var baseURL = $editor.closest('form').attr('action');

			var selectedImage = false;
			var images = [];
			var imagesData = false;

			function loadImagesData () {
				$.getJSON(baseURL + '/page_images.json', function (json) {
					imagesData = json;
				});
			}
			loadImagesData();

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

				// Delay execution if imageData hasn't yet been loaded.
				if (imagesData === false) {
					setTimeout(function () {
						showImage(image);
					}, 100);
					return false;
				}

				if (image) {
					var maxSize   = [600, 600];
					var imageId   = $(image).data('page-image-id');
					var imageData = getImageData(imageId);

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

					$(images).removeClass('selected');
					$(image).addClass('selected');
					selectedImage = image;
					$editor.slideDown(400);
				}
			}

			function closeEditor () {
				$(images).removeClass('selected');
				selectedImage = false;
				$editor.slideUp(400);
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

			$editor.find('a.next').click(showNextImage);
			$editor.find('a.previous').click(showPreviousImage);
			$editor.find('a.close').click(closeEditor);

			// Apply to images
			$(container).find('.image').each(function () {
				images.push(this);
				$(this).click(function () {
					showImage(this);
				});
			});
		});
	});
})(jQuery);