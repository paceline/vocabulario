// Controller-specific JavaScript functions and classes for Scores

document.observe("dom:loaded", function() {
  
  // Initialize tabs
  document.on('ajax:before', '#tab_0', function(event) { deactivateTab(3); });
  document.on('ajax:complete', '#tab_0', function(event) { activateTab(0,''); observeDefault(); });
  document.on('ajax:before', '#tab_1', function(event) { deactivateTab(3); });
  document.on('ajax:complete', '#tab_1', function(event) { activateTab(1,''); observeConjugationTestTab(); });
  document.on('ajax:before', '#tab_2', function(event) { deactivateTab(3); });
  document.on('ajax:complete', '#tab_2', function(event) { activateTab(2,''); observeListTestTab(); });

  // Start default observers
  observeDefault();
});


// Default observers
 
function observeDefault() {
  startObserving('test_from','/scores/update_languages','test_tags','language_from_id',$H({test_to:'language_to_id'}));
  startObserving('test_to','/scores/update_tags','test_tags','language_to_id',$H({test_from:'language_from_id'}));
}


// Observer for conjugation test

function observeConjugationTestTab() {
  startObserving('test_tense_id','/scores/update_tags','test_tags','conjugation_time_id');
}


// Observer for list-based test

function observeListTestTab() {
  startObserving('test_list_id','/scores/options_for_list','test_options_input','list_id');
}

