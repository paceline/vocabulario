// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// Highlight flash[:notice] and hide after a few seconds

function highlight() {
  Element.show('notice')
  new Effect.Highlight('notice');
  setTimeout("Element.hide('notice')",5000);
}


// Exit out of tag edit menu with ESC key

function keyPressHandler(e) {
  var kC  = (window.event) ?    // MSIE or Firefox?
    event.keyCode : e.keyCode;
  var Esc = (window.event) ?   
    27 : e.DOM_VK_ESCAPE // MSIE : Firefox
  if(kC==Esc)
    $('taglist','tag_form').invoke('toggle')
}


