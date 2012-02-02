# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# Yo ean use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ = jQuery

jQuery -> 
  $(document).ready -> 
    content = $('#comment_content');
    title = content.attr('title');
    content.val(title);

    content.focus -> 
      if (!$.data(this, 'edited'))
        this.value = "";
    content.change -> 
      $.data(this, 'edited', this.value != "");
    content.blur -> 
      if (!$.data(this, 'edited')) 
        content.val(title);

