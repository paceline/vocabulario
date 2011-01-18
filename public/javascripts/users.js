// Controller-specific JavaScript functions and classes for Users


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