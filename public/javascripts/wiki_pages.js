// Controller-specific JavaScript functions and classes for Wiki Pages

document.observe("dom:loaded", function() {

  if ($('taglist') != undefined) {
    enableTagListEditor();
  }

})