# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# Yo ean use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ = jQuery

$.fn.addImageTag = ->
  article = $('#article_content').get(0);
  value = article.value;
  n = article.selectionStart;
  url = $('#image_url').val();
  imageText = $('#image_text').val();
  newValue = value.substr(0, n) + "[" + imageText + "](" + url + ") " + value.substr(n);
  article.value = newValue;
  $('#image_url').val('');
  $('#image_text').val('');

  
    

#jQuery -> 
#  $(document).ready -> 
#    content = $('#comment_content');
#    title = content.attr('title');
#    content.val(title);
#
#    content.focus -> 
#      if (!$.data(this, 'edited'))
#        this.value = "";
#    content.change -> 
#      $.data(this, 'edited', this.value != "");
#    content.blur -> 
#      if (!$.data(this, 'edited')) 
#        content.val(title);

