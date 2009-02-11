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
		window.hidePreview = function() {
			if( window.documentPreview ) {
				document.body.removeChild( window.documentPreview );
				window.documentPreview = false;
			}
		}

		window.showPreview = function() {
			var url = "<%= preview_admin_page_url( :id => @page, :language => @language ) %>";
			new Ajax.Request( url, {
				method:     'post',
				parameters: Form.serialize( 'page-form', true ),
				onSuccess: function( transport ) {
					hidePreview();
					window.documentPreview = document.createElement( "div" );
					window.documentPreview.id = "documentPreview";
					window.documentPreview.innerHTML = transport.responseText;
					document.body.appendChild( window.documentPreview );
					Element.hide( window.documentPreview );
					Effect.Appear( window.documentPreview, { duration: 0.6 } );
				}
			});
		}

		Element.hide( 'new-image' );
		if( $('new-file') ) {
			Element.hide( 'new-file' );
		}

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
	}
}