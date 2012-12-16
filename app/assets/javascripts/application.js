// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//= require jquery
//= require jquery_ujs

//= require_self

$(document).ready(function() {
  /* Activating Best In Place */
	//jQuery(".best_in_place").best_in_place();
	$(".popover").popover();

	$("[rel*='popover']").popover({trigger:'hover', placement:'right', html : true});
	
	//setTimeout($.get("/poll"), 10000);	

	$("[rel*='tooltip']").tooltip();
	$('.dropdown-toggle').dropdown();
	
	$('.dropdown form').on('click', function (e) {
		e.stopPropagation()
	});

	$("#extruderLeft").buildMbExtruder({
		position:"left",
		top:300,
		extruderOpacity:1,
		hidePanelsOnClose:false,
		accordionPanels:false,
		onExtOpen:function(){},
		onExtContentLoad:function(){$("#extruderLeft").openPanel();},
		onExtClose:function(){}
	});

});



