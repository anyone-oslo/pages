Admin.PagesController = {
	init : function() {
	},

	index : function() {

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
	
	edit : function() {
	}
}