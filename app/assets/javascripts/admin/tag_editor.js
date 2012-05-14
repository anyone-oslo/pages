(function($){

	var TagEditor = function(container){
		this.initialize(container);
	}

	$.extend(TagEditor.prototype, {
		initialize: function(container){
			var tagEditor = this;
			tagEditor.container = container;
			tagEditor.tags = Array();
			tagEditor.serializeField = $(tagEditor.container).find('.serialized_tags').get(0);
			tagEditor.findTags(true);

			tagEditor.inputField = $(tagEditor.container).find('.add_tag').get(0);
			$(tagEditor.container).find('.add_tag_button').click(function(){
				tagEditor.addTag();
				$(tagEditor.container).find('.add_tag').blur();
				return false;
			});
			$(tagEditor.container).find('.add_tag').keydown(function(event){
				if(event.which == 13){
					tagEditor.addTag();
					return false;
				}
			});

			$(tagEditor.container).find('.add_tag').each(function(){
				var field = this;
				field.exampleText = $(field).val();
				$(field).addClass('example');
				$(field).focus(function(event){
					$(tagEditor.container).find('.add_tag_button').fadeIn('fast');
					$(field).removeClass('example');
					if($(field).val() == field.exampleText){
						$(field).val('');
					}
				});
				$(field).blur(function(event){
					$(tagEditor.container).find('.add_tag_button').fadeOut('fast');
					if(!$(field).val() || $(field).val() == field.exampleText){
						$(field).addClass('example').val(field.exampleText);
					}
				});
			});
			$(tagEditor.container).find('.add_tag_button').hide();
		},

		addTag: function(){
			var tagEditor = this;
			var tagName = $(tagEditor.inputField).val().replace(/^\s\s*/, '').replace(/\s\s*$/, '');
			if(tagName){
				if(this.hasTag(tagName)){
					this.enable(this.getTagByName(tagName));
				} else {
					$(tagEditor.container).find('.tags').append('<span class="tag"><input type="checkbox" name="tag-'+tagName+'" value="1" checked="checked"><span class="name">'+tagName+'</span></span>');
					tagEditor.findTags();
				}
			}
			$(tagEditor.inputField).val('');
		},

		findTags: function(permanentize){
			var tagEditor = this;
			$(this.container).find('.tag').each(function(){
				var tag = this;
				if(!tag.tagEditorApplied){
					tag.checkBox = $(tag).find('input[type=checkbox]').get(0);
					tag.name = $(tag).find('.name').text();
					if(tagEditor.isChecked(tag)){
						tag.enabled = true;
						$(tag).addClass('enabled');
					} else {
						tag.enabled = false;
					}
					$(tag).click(function(){
						tagEditor.toggle(tag);
					});
					tagEditor.tags[tagEditor.tags.length] = tag;
					tag.tagEditorApplied = true;
				}
			});
			tagEditor.serializeTags();
		},

		hasTag: function(tagName){
			var hasTag = false;
			$(this.tags).each(function(){
				if(tagName.toLowerCase() == this.name.toLowerCase()){
					hasTag = true;
				}
			});
			return hasTag;
		},

		toggle: function(tag){
			if(tag.enabled){
				this.disable(tag);
			} else {
				this.enable(tag);
			}
		},

		enable: function(tag){
			tag.enabled = true;
			$(tag).addClass('enabled');
			$(tag.checkBox).attr('checked', tag.enabled);
			this.serializeTags();
		},

		disable: function(tag){
			tag.enabled = false;
			$(tag).removeClass('enabled');
			$(tag.checkBox).attr('checked', tag.enabled);
			this.serializeTags();
		},

		getTagByName: function(tagName){
			var tag = null;
			$(this.tags).each(function(){
				if(this.name.toLowerCase() == tagName.toLowerCase()){
					tag = this;
				}
			});
			return tag;
		},

		isChecked: function(tag){
			return $(tag.checkBox).attr('checked');
		},

		enabledTags: function(){
			var enabledTags = Array();
			$(this.tags).each(function(){
				if(this.enabled){
					enabledTags[enabledTags.length] = this;
				}
			});
			return enabledTags;
		},

		serializeTags: function(){
			var tagNames = Array();
			$(this.enabledTags()).each(function(){
				tagNames[tagNames.length] = '"' + this.name.replace('"', '\\"') + '"';
			})
			$(this.serializeField).val('['+tagNames.join(', ')+']');
			$(this.container).find('.add_tag').attr('disabled', false);
		}
	});

	// Apply the tag editor to each instance
	$(function(){
		$('.tag_editor').each(function(){
			this.tagEditor = new TagEditor(this);
		});
	});

})(jQuery);