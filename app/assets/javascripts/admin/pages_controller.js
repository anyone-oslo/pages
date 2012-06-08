Admin.PagesController = {
	init : function() {
	},

	index_action : function() {

		(function($){
			$('#reorder_link').click(function(){
				var link = this;
				var list = $('.pagelist').get(0);
				if($(list).hasClass('reorder')){
					$(link).html('Reorder pages');
					$(list).removeClass('reorder');
				} else {
					$(link).html('Done reordering');
					$(list).addClass('reorder');
				}
			});

			$('ul.reorderable').each(function(){
				var list = this;
				$(list).sortable({
					axis:     "y",
					cursor:   "move",
					distance: 10,
					handle:   '.drag_handle',
					update: function(event, ui){
						var new_order = [];
						var parent_page_id = $(list).attr('parent_page_id');
						$(list).children('li').each(function(){
							new_order.push($(this).attr('page_id'));
						});

						var reorder_url = '/admin/'+Admin.language+'/pages/reorder_pages';
						$.get(reorder_url, {ids: new_order}, function(data){
							$(list).effect("highlight", {}, 1500);
						});
					}
				});
			});
		})(jQuery);

		// Hover actions on .page .actions
		jQuery('.page').hover(
			function(){
				jQuery(this).addClass('hover');
				jQuery(this).children('.actions').css('visibility', 'visible');
			},
			function(){
				jQuery(this).removeClass('hover');
				jQuery(this).children('.actions').css('visibility', 'hidden');
			}
		);
		jQuery('.page .actions').css('visibility', 'hidden');

		// Toggling of the new category input
		window.toggleNewCategory = function(){
			jQuery('#new-category').toggle();
			jQuery('#new-category-button').toggle();
		};
		jQuery('#new-category').hide();

	},

	new_action : function() {
	},

	new_news_action : function() {
	},

	show_action : function () {
		this.edit_action();
	},

	edit_action : function() {

		(function($){

			$('.advanced_options').hide();
			$('.advanced_toggle').click(function () {
				$('.advanced_options').slideToggle();
			});

			var checkStatus = function () {
				var pageStatus = $('#page-form-sidebar #page_status').val();
				if (pageStatus == 2) {
					$('#page-form-sidebar .published_date').fadeIn();
				} else {
					$('#page-form-sidebar .published_date').hide();
				}
			};
			$('#page-form-sidebar #page_status').change(checkStatus);
			checkStatus();

			$('.autopublish_notice').hide();
			var checkDate = function () {

				var year   = $('#page-form-sidebar select[name="page[published_at(1i)]"]').val();
				var month  = $('#page-form-sidebar select[name="page[published_at(2i)]"]').val();
				var day    = $('#page-form-sidebar select[name="page[published_at(3i)]"]').val();
				var hour   = $('#page-form-sidebar select[name="page[published_at(4i)]"]').val();
				var minute = $('#page-form-sidebar select[name="page[published_at(5i)]"]').val();

				var publishDate = new Date(year, (month-1), day, hour, minute);
				var now = new Date();

				if (publishDate > now) {
					$('.autopublish_notice').fadeIn();
				} else {
					$('.autopublish_notice').fadeOut();
				}
			};
			$('.published_date').find('select').change(checkDate);
			checkDate();

			var replicateFormElement = function () {
				var newValue = this;
				$('#page-form').find('[name="' + newValue.name + '"]').each(function () {
					if (newValue.type == 'checkbox') {
						$(this).attr('checked', $(newValue).attr('checked') ? true : false);
					} else {
						$(this).val($(newValue).val());
					}
				});
			};

			$('#page-form-sidebar').find('input,textarea,select').change(replicateFormElement);

			$('#new-image').hide();

			window.showAdditionalImageModal = function () {
				Modal.show('<div class="uploadImages">'+$('#new-image').html()+'</div>');
			};

			// Previewing
			$('#previewButton').click(function(){
				var button = this;
				var form = $(button).closest('form').get(0);
				var previewUrl = '/'+Admin.language+'/pages/preview';

				// Rewrite the form and submit
				form.oldAction = form.action;
				form.target = "_blank";
				form.action = previewUrl;
				$(form).submit();

				// Undo rewrite
				form.action = form.oldAction;
				form.target = "";

				/*
				button.originalValue = $(button).html();
				$(button).html("Loading..").attr('disabled', true);
				$.post(previewUrl, $(form).serialize(), function(html){
					previewWindow = window.open('', 'pages_preview', "status=0,toolbar=0,location=0,menubar=0,resizable=1,scrollbars=1");
					var output = previewWindow.document;
					output.title = "Preview";
					output.write(html);
					output.close();
					$(button).html(button.originalValue).attr('disabled', false);
				});
				*/
			});

			$('#new-file').hide();
		})(jQuery);

	}
};