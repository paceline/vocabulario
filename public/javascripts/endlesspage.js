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
  // compute amount of page below the current scroll position
  var remaining = ($('vocabulary_results').viewportOffset()[1] + $('vocabulary_results').getHeight()) - Position.GetWindowSize().height;
  //compute height of bottom element
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