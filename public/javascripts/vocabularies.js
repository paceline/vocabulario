// Controller-specific JavaScript functions and classes for Vocabularies

document.observe("dom:loaded", function() {
  
  // Initialize tabs
  document.on('ajax:before', '#tab_0', function(event) { deactivateTab(4); });
  document.on('ajax:complete', '#tab_0', function(event) { activateTab(0); observeDefault(); });
  document.on('ajax:before', '#tab_1', function(event) { deactivateTab(4); });
  document.on('ajax:complete', '#tab_1', function(event) { activateTab(1); });
  document.on('ajax:before', '#tab_2', function(event) { deactivateTab(4); });
  document.on('ajax:complete', '#tab_2', function(event) { activateTab(2); });
  document.on('ajax:before', '#tab_3', function(event) { deactivateTab(4); });
  document.on('ajax:complete', '#tab_3', function(event) { activateTab(3); if($('comments') != undefined) { enableHiddenOptions('.strong','.delete'); }; });
  
  // Start default observers
  observeDefault();
  
  if ($('taglist') != undefined) {
    enableTagListEditor();
  }
  
  if ($('vocabulary_lookup_auto_complete') != undefined) {
    // Autocomplete for translation dialog
    new Autocompleter.Local('vocabulary_word','vocabulary_lookup_auto_complete', vocabularies, {frequency: 0, minChars: 1});
    // Re-populate form after autocomplete
    startObservingFrequently('vocabulary_word','',0.5,'/vocabularies/refresh_language','word');
  }
  
  if ($('vocabulary_csv') != undefined) {
    // Refresh on switching language
    startObserving('vocabulary_csv','/vocabularies/preview','preview','csv');
    
    // Enable remote form hooks
    document.on('ajax:before', 'form[data-remote]', function(event) { $('vocabulary_csv').value = ''; $('back').remove(); });
    document.on('ajax:complete', 'form[data-remote]', function(event) { resetImportForm(); highlightNotice(); });
  }
   
});


// Default observers (collection)
 
function observeDefault() {
  discoverEditables();
  if ($('vocabulary_word') != undefined && $('vocabulary_results') != undefined) {
    startObservingFrequently('vocabulary_word','vocabulary_results',0.5,'/vocabularies/live','word');
  }
  enableEndlessPage('vocabulary_results','vocabulary');
}

// Changes view after preview for import is loaded

function resetImportForm() {
  $('preview').innerHTML = "";
  $('vocabulary_csv').show();
}