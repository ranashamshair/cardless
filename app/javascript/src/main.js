$(function () {

    $(".toggle_navigation").click(function () {
        $("menu").slideToggle(600);
    });

    $(".show").click(function(){
        $(".icons").css("display", "none");
    });



    /*$(window).scroll(function () {
        var height = $(window).scrollTop();
        if (height > 30) {
            $(".nav_bar").addClass("sticky_header");
        } else {
            $(".nav_bar").removeClass("sticky_header");
        }

    });*/
});