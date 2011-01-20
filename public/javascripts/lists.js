// Controller-specific JavaScript functions and classes for Vocabularies

document.observe("dom:loaded", function() {
  
  // Parse url
  var id_or_action = window.location.href.split('/').last();
  
  // Start observering form
  if ($('list_type') != undefined) {
    startObserving('list_type','/lists/switch','test_to','selected');
  }
  
  // Start observing tense selector
  if ($('your_lists') != undefined) {
    startObserving('your_lists','/lists/' + id_or_action + '/tense',null,'tense_id');
  }
  
  // Start observering search and drag
  if ($('vocabulary_word') != undefined) {
    startObservingFrequently('vocabulary_word','search_and_drag',0.5,'/lists/' + id_or_action + '/live','word');
  }

});