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
  
  if ($('vocabulary_csv') != undefined) {
    enableCsvObserver();
  }
});


// Default observers (collection)
 
function observeDefault() {
  discoverEditables();
  if ($('vocabulary_word') != undefined && $('vocabulary_results') != undefined) {
    startObservingFrequently('vocabulary_word','vocabulary_results',2,'/vocabularies/live','word');
    enableResetInputBox();
  }
  enableEndlessPage('vocabulary_results','vocabulary');
}


// Changes view after preview for import is loaded

function resetImportForm() {
  $('preview').innerHTML = "";
  $('vocabulary_csv').show();
  $('import').setAttribute('disabled','disabled');
}


function enableCsvObserver() {
  // Refresh on switching language
  startObserving('vocabulary_csv','/vocabularies/preview','preview','csv');
  
  // Enable remote form hooks
  document.on('ajax:before', 'form[data-remote]', function(event) { $('vocabulary_csv').value = ''; $('back').remove(); });
  document.on('ajax:complete', 'form[data-remote]', function(event) { resetImportForm(); highlightNotice(); });
}