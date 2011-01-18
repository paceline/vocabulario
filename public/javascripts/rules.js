// Controller-specific JavaScript functions and classes for Rules

document.observe("dom:loaded", function() {
  
  // Start default observers
  startObservingFrequently('rule_test_string','modified_verb',2,'/rules/test','verb',"'rule[find]=' + $('rule_find').getValue() + '&rule[replace]=' + $('rule_replace').getValue()");
  
  // Start autocompleter
  if ($('find_lookup_auto_complete') != undefined) {
    new Ajax.Autocompleter('rule_find', 'find_lookup_auto_complete', '/rules/autocomplete', {frequency: 0, minChars: 2, paramName: 'find', afterUpdateElement: getSelectionId});
  }
    
});