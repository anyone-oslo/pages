(function ($) {
	$(function () {
		$('.page_images').each(function () {
			var container = this;
			var $editor = $(container).find('.editor');

			$editor.hide();

			var selectedImage = false;
			var images = [];

			function showImage(image) {
				if (image) {
					$(images).removeClass('selected');
					$(image).addClass('selected');
					selectedImage = image;
					console.log(image)
					$editor.slideDown(400);
				}
			}
			
			function showNextImage() {
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
			
			function showPreviousImage() {
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