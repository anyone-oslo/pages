Admin.PagesController = {
	init : function() {
	},

	applyAutopublishCheck : function() {
		window.checkAutopublishOptions = function(elmnt) {
			if($('page_status').value == 2) {
				Element.show('page_autopublish_field');
			} else {
				Element.hide('page_autopublish_field');
			}
			if($('page_autopublish').checked) {
				Element.show($('page_autopublish_options'));
			} else {
				Element.hide($('page_autopublish_options'));
			}
		}
		checkAutopublishOptions();

		$('page_autopublish').observe('click', function(e){ checkAutopublishOptions(); });
		$('page_status').observe('change', function(e){ checkAutopublishOptions(); });
	},

	index_action : function() {

		(function($){
			$('ul.reorderable').each(function(){
				var list = this;
				$(list).sortable({
					axis: "y",
					cursor: "move",
					distance: 10,
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
		}
		jQuery('#new-category').hide();

	},
	
	new_action : function() {
		this.applyAutopublishCheck();
	},

	new_news_action : function() {
		this.applyAutopublishCheck();
	},

	show_action : function() {
		this.edit_action();
	},

	edit_action : function() {
		this.applyAutopublishCheck();

		(function($){
			
			$('#new-image').hide();

			window.showAdditionalImageModal = function(){
				Modal.show('<div class="uploadImages">'+$('#new-image').html()+'</div>');
			}

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
}