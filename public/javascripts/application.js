// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function highlight() {
  Element.show('notice')
  new Effect.Highlight('notice');
  setTimeout("Element.hide('notice')",5000);
}