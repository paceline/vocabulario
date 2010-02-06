// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// Highlight flash[:notice] and hide after a few seconds

function highlight() {
	Element.show('notice');
	new Effect.Highlight('notice');
	setTimeout("new Effect.BlindUp('notice')",3000);
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

function activateTab(no, pane) {
  if(pane != '') { $(pane).hide(); }
  $('tab_' + no + '_link').addClassName('active');
  if(pane != '') { new Effect.BlindDown(pane); }
}

function deactivateTab(length) {
  for(i=0; i<length; i++) { $('tab_' + i + '_link').className = 'tab_link' };
}


// Get selected text
// Requires ierange to work in IE (http://code.google.com/p/ierange/)

function getUserSelection() {
	var userSelection = window.getSelection();
	if (userSelection.toString() == "") {
		return [-1, -1];
	}
	else {
		var rangeObject = getRangeObject(userSelection);
		return [rangeObject.startOffset, rangeObject.endOffset-1];
	}
}

function getRangeObject(selectionObject) {
	if (selectionObject.getRangeAt)
		return selectionObject.getRangeAt(0);
	else {
		var range = document.createRange();
		range.setStart(selectionObject.anchorNode,selectionObject.anchorOffset);
		range.setEnd(selectionObject.focusNode,selectionObject.focusOffset);
		return range;
	}
}


// Paint a new graph
// Sends Ajax request to retrieve data from server, then uses Bluff to paint graph

function getGraphData(user, tag, type, page) {
	tag = (tag === undefined) ? '' : tag;
	type = (type === undefined) ? '' : type;
	page = (page === undefined) ? 0 : page;
	
	new Ajax.Request('/users/' + user + '/statistics.json', {
	  method: 'get',
		parameters: {tag: tag, type: type, page: page},
	  onSuccess: function(transport) {
	  	var data = transport.responseText.evalJSON();
			paintNewGraph(data.scores, (data.page-1)*25);
			$('loading').hide();
	  }
	});
}

function paintNewGraph(scores, offset) {
	var graph = new Bluff.Line('scores_as_timeline', '800x350');
  graph.hide_legend = true;
	graph.hide_title = true;
  graph.maximum_value = 100;
  graph.minimum_value = 0;
  graph.set_margins(0);
	graph.set_theme({
	    colors: ['#C0ED00', '#CCC', '#666', '#444'],
	    marker_color: '#02B8EA',
	    font_color: 'black',
	    background_colors: ['#fff', '#fff']
	});
  graph.tooltips = true;

	graph.data("Score: ", scores.collect(function(s) { return (s.score.questions > 0) ? s.score.points / s.score.questions * 100 : 0 }));
	var labels = new Hash();
	limit = (scores.size() < 25) ? scores.size() : 25;
	for (i=0; i<=limit; i=i+1) {
		labels.set(i, offset+i+1);
	}
	graph.labels = labels.toObject();

  graph.draw();
}