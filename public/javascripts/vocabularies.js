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
    // Listen to click action to enter tag edit mode
    document.on('click', '#taglist', function(event) { $('taglist','tag_form').invoke('toggle'); $('tag_list').focus(); });
    
    // Listen to Esc to exit out of tag edit mode
    document.on('keydown', '#tag_list', function(event) { toggleElementsOnEscape(event, ['tag_form','taglist']) });
  }
  
  if ($('vocabulary_lookup_auto_complete') != undefined) {
    // Autocomplete for translation dialog
    new Autocompleter.Local('vocabulary_word','vocabulary_lookup_auto_complete', vocabularies, {frequency: 0, minChars: 1});
    
    // Refresh on switching language
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
}


// Endless page stuff

var live_search = false;

// from http://codesnippets.joyent.com/posts/show/835
Position.GetWindowSize = function(w) {
    var width, height;
        w = w ? w : window;
        this.width = w.innerWidth || (w.document.documentElement.clientWidth || w.document.body.clientWidth);
        this.height = w.innerHeight || (w.document.documentElement.clientHeight || w.document.body.clientHeight);

        return this;
}

function loadRemainingItems(){
  // infer url from browser location
  var url = window.location.href + '.js'
  // compute amount of page below the current scroll position
  var remaining = ($('vocabulary_results').viewportOffset()[1] + $('vocabulary_results').getHeight()) - Position.GetWindowSize().height;
  // compute height of bottom element
  var last = $$(".vocabulary").last().getHeight();

  if(remaining < last*2 && !live_search){
    if(Ajax.activeRequestCount == 0){
      var last = $$(".vocabulary").last().className.match(/[0-9]+/)[0];
      new Ajax.Request(url, {
        method: 'get',
        parameters: 'last=' + last,
        onSuccess: function(xhr){
          $('vocabulary_results').insert({bottom : xhr.responseText})
        }
      });
    }
  }
}

// find to events that could fire loading items at the bottom
Event.observe(window, 'scroll', function(e){
  loadRemainingItems();
});

Event.observe(window, 'resize', function(e){
  loadRemainingItems();
});


// Changes view after preview for import is loaded

function resetImportForm() {
  $('preview').innerHTML = "";
  $('vocabulary_csv').show();
}