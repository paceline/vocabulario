// Controller-specific JavaScript functions and classes for Wiki Pages

document.observe("dom:loaded", function() {
  
  // Enable tag editor
  if ($('taglist') != undefined) {
    enableTagListEditor();
  }
  
  // Make printable
  enablePrinting();
  
  // Watch path (to add prefix when appropriate)
  startObserving('page_language_id', '/wiki/prefix', 'path', 'language_id');
  
})


// Append or replace language prefix when adding a new wiki page

function appendOrReplace(dom_id, text, delimiter) {
  var old_value = $(dom_id).getValue();
  var pattern = new RegExp('^.*' + delimiter);
  if (old_value.match(pattern)) {
    if (text.length > 0) {
      $(dom_id).setValue(old_value.replace(pattern, text + delimiter)); 
    }
    else {
      $(dom_id).setValue(old_value.replace(pattern, '')); 
    }
  }
  else {
    $(dom_id).setValue(text + delimiter + old_value); 
  }
}