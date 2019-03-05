$(document).ready(function(){
	$(".carousel-content").slick({
		dots: true,
  		infinite: true
	});

	$(".e-btn_more").on("click", function(e) {
		var target = $(e.target).data("target");
		$("#" + target).slideToggle();
	});
});




