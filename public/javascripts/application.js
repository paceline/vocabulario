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