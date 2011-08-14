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

function appendOrReplace(dom_id, index, choices) {
  var old_value = $(dom_id).getValue().toLowerCase().replace(/ /g, '-');
  var pattern = new RegExp('^(' + choices.join('|') + ')-');
  if (pattern.test(old_value)) {
    $(dom_id).setValue(old_value.replace(pattern, (index == '') ? '' : choices[index] + '-'));
  }
  else {
    $(dom_id).setValue(choices[index] + '-' + old_value);
  }
}