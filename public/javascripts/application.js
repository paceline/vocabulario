// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// Run highlight function when appropriate

document.observe("dom:loaded", function() {
  if ($('notice').visible() && $('notice').childElements().first().identify().startsWith('flash_')) {
    highlightNotice();
  }
})


// Highlight flash[:notice] and hide after a few seconds

function highlightNotice() {
	$('notice').show();
	setTimeout("new Effect.BlindUp('notice')",3000);
}


// Revert back to old content after a timeout

function revertUpdate(element, content) {
  var command = "$('" + element + "').update('" + content.replace(/\n/g,'') + "')";
  setTimeout(command,3000); 
}


// Enable showing/hiding spinner

document.observe("dom:loaded", function() {
  enableSpinner('.lengthy');
});
function enableSpinner(selector) {
  document.on('ajax:before', selector, function(event) { preSpinner(); $('loading').show(); });
  document.on('ajax:complete', selector, function(event) { $('loading').hide(); preSpinner(); });
}
function preSpinner() {
  if ($('conjugation_menu') != undefined) { $('conjugation_menu').toggle(); };
  if ($('patterns') != undefined) { $('patterns').toggle(); };
}


// Toggle given elements when ESC key is hit

function toggleElementsOnEscape(event, forms) {
	if (event.which == null) {
	 	key = event.keyCode;    // IE
	}
	else if (event.which > 0) {
		key = event.which;	  // All others
	}
	if(key==27) {
    forms.each(Element.toggle);
	}
}


// Toggle list item

function toggleListItem(dom_id) {
	if ($(dom_id + '_details').visible()) {
		$(dom_id + '_link').update('+');
	}
	else {
		$(dom_id + '_link').update('-');
	}
	$(dom_id + '_details').toggle();
}


// Toggle list item

function toggleListMenu(vocabulary_id) {
  if ($('options_for_' + vocabulary_id).visible()) {
		$('link_to_' + vocabulary_id).setStyle({ background: '#444' });
	}
	else {
		$('link_to_' + vocabulary_id).setStyle({ background: '#02B8EA' });
	}
	$('options_for_' + vocabulary_id).toggle();
}


// Toggle manage stuff menu

function toggleMenu(dom_id, elements) {
  if ($(dom_id).visible()) {
    $(dom_id).blindUp({ duration: 0.5 })
	}
	else {
	  elements.each(function(s) {
	    if ($(s).visible()) {
        $(s).blindUp({ duration: 0.25 })
      }
    });
	  $(dom_id).blindDown({ duration: 0.5 })
	}
}


// Activates or deactivates given tab

function activateTab(no) {
  if($('tab_browser') != undefined) { $('tab_browser').hide(); }
  $('tab_' + no + '_link').addClassName('active');
  if($('tab_browser') != undefined) { new Effect.BlindDown('tab_browser'); }
}

function deactivateTab(length) {
  for(i=0; i<length; i++) { $('tab_' + i + '_link').className = 'tab_link' };
}


// Display and hide admin options

function enableHiddenOptions(root, klass) {
  $$(root).each(function(element) {
    element.observe('mouseover', function(event) { element.select(klass)[0].show(); });
    element.observe('mouseout', function(event) { element.select(klass)[0].hide(); });
  });
}


// Resets form field containing hint

function clearHint(dom_id, hint) {
  if ($(dom_id).getValue() == hint) {
    $(dom_id).setValue('');
    $(dom_id).focus();
  }
}


// Enhanced auto completer

function getSelectionId(text, li) { 
  new Ajax.Request('/rules/' + li.id + '.json', {
    method: 'get',
    onSuccess: function(transport) {
      var rule = transport.responseText.evalJSON().rule;
      $('rule_name').setValue(rule.name);
      $('rule_replace').setValue(rule.replace);
      new Effect.Highlight('rule_name');
      new Effect.Highlight('rule_replace');
    }
  });
}


// Javascript replacement for observe_field

function startObserving(dom_id, path, highlight, attr_name, optional) {
  var attr_name = (attr_name === undefined) ? dom_id : attr_name;
  new Form.Element.EventObserver(dom_id, function(element, value) {
    params = attr_name + '=' + value;
    if ($('loading') != undefined) { $('loading').show(); };
    if (!(optional === undefined)) {
      optional.each(function(pair) { params += '&' + pair.value + '=' + $A($(pair.key).options).find(function(option) { return option.selected; } ).value });
    }
    new Ajax.Request(path, { 
      asynchronous:true, evalScripts:true,
      onComplete:function(request){new Effect.Highlight(highlight,{}); },
      onLoaded:function(request) { if ($('loading') != undefined) { $('loading').hide(); }; },
      parameters: params
    });
  });
}


// Javascript replacement for observe_field with frequency

function startObservingFrequently(dom_id, target_id, timer, path, attr_name, snippet) {
  new Form.Element.Observer(dom_id, timer, function(element, value) {
    params = (attr_name === undefined) ? dom_id + '=' + encodeURIComponent(value) : attr_name + '=' + encodeURIComponent(value);
    params = (snippet === undefined) ? params : params + '&' + eval(snippet);
    if ($(target_id) != undefined) { $(target_id).hide(); };
    if ($('loading') != undefined) { $('loading').show(); };
    new Ajax.Updater(target_id, path, {
      asynchronous:true, evalScripts:true,
      onLoaded:function(request) {
        if ($('loading') != undefined) { $('loading').hide(); };
        if ($(target_id) != undefined) { $(target_id).show(); };
      },
      parameters: params
    });
  });
}


// Javascript replacement for in_place_editing

function discoverEditables() {
  var editables = $A($$(".editable"));

  editables.each(function(text) {
    var form = Element.next(text);
    text.observe('click', function() {
      text.hide();
      form.show();
      form.focusFirstElement();
 
      // when clicking outside of the form
      var clickObserver = function(event) {
        var element = Event.element(event);
        if(element == text || element.descendantOf(form))
          return;
          if(form.style.display == "") {
            form.fire("ajax:before");
            form.request();
          }
          Event.stopObserving(document, "click", clickObserver);
        };
        Event.observe(document, "click", clickObserver);
 
        // when escape key
        Event.observe(document, "keyup", function(event) {
          if (event.keyCode == Event.KEY_ESC) {
            form.hide();
            text.show();
        }
      });
 
      // when form submit
      form.observe("ajax:before", function() {
        form.hide();
        text.show();
        text.update("(saving ...)");
      });
    });
  });
};

function getSelectedOption(select) {
   var selectedOptions = $(select).getElementsBySelector('option');
   var selection  = null;
   for (var i = 0; i < selectedOptions.length; i++) {
      if (selectedOptions[i].selected) {
         selection = selectedOptions[i];
         break;
      }
   }
   return selection;
}


// Endless page stuff

var live_search = false;

function enableEndlessPage(results_dom_id, element_class) {
  
  // from http://codesnippets.joyent.com/posts/show/835
  Position.GetWindowSize = function(w) {
      var width, height;
          w = w ? w : window;
          this.width = w.innerWidth || (w.document.documentElement.clientWidth || w.document.body.clientWidth);
          this.height = w.innerHeight || (w.document.documentElement.clientHeight || w.document.body.clientHeight);
          return this;
  }

  // find to events that could fire loading items at the bottom
  Event.observe(window, 'scroll', function(e){
    loadRemainingItems(results_dom_id, element_class);
  });

  Event.observe(window, 'resize', function(e){
    loadRemainingItems(results_dom_id, element_class);
  }); 
}

function loadRemainingItems(results_dom_id, element_class){
  // infer url from browser location
  var url = (window.location.href.split('/').last() === '') ? '/status.js' : window.location.href + '.js';
  // compute amount of page below the current scroll position
  var remaining = ($(results_dom_id).viewportOffset()[1] + $(results_dom_id).getHeight()) - Position.GetWindowSize().height;
  // compute height of bottom element
  var last = $$('.' + element_class).last().getHeight();

  if(remaining < last*2 && !live_search){
    if(Ajax.activeRequestCount == 0){
      var last = $$('.' + element_class).last().className.match(/[0-9]+/)[0];
      new Ajax.Request(url, {
        method: 'get',
        parameters: 'last=' + last,
        onSuccess: function(xhr){
          $(results_dom_id).insert({bottom : xhr.responseText})
        }
      });
    }
  }
}