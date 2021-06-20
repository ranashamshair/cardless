$(document).on("turbolinks:load", function() {
// $(function () {
  /* right Sidebar */
$('.user_icon').click(function(){
$('.sidebar_right').css("width", "230px");
});

$('.btn_close').click(function(){
$('.sidebar_right').css("width", "0px");
});

/* Notification Sidebar */
$('.notify_icon').click(function(){
$('.notify_sidebar').css("width", "350px");
});

$('.notify_btn_close').click(function(){
$('.notify_sidebar').css("width", "0px");
});

/* Fix Home Btn Dashboard left sidebar */
$(".sidebar_left").mouseover(function(){
$(".fa-home").css("left", "40%");
});
$(".sidebar_left").mouseout(function(){
$(".fa-home").css("left", "18%");
});
  $(".toggle_navigation").click(function () {
      $("menu").slideToggle(600);
  });




  /*$(window).scroll(function () {
      var height = $(window).scrollTop();
      if (height > 30) {
          $(".nav_bar").addClass("sticky_header");
      } else {
          $(".nav_bar").removeClass("sticky_header");
      }

  });*/

  var lFollowX = 0,
    lFollowY = 0,
    x = 0,
    y = 0,
    friction = 1 / 30;

  function moveBackground() {
    x += (lFollowX - x) * friction;
    y += (lFollowY - y) * friction;

    //  translate = 'translateX(' + x + 'px, ' + y + 'px)';
    translate = 'translateX(' + x + 'px) translateY(' + y + 'px)';

    $('.animate-this').css({
      '-webit-transform': translate,
      '-moz-transform': translate,
      'transform': translate
    });

    window.requestAnimationFrame(moveBackground);
  }

  $(window).on('mousemove', function (e) {

    var isHovered = $('.animate-this:hover').length > 0;

    //if(!$(e.target).hasClass('animate-this')) {
    if (!isHovered) {
      var lMouseX = Math.max(-100, Math.min(100, $(window).width() / 2 - e.clientX)),
        lMouseY = Math.max(-100, Math.min(100, $(window).height() / 2 - e.clientY));

      lFollowX = (10 * lMouseX) / 100;
      lFollowY = (30 * lMouseY) / 100;
    }
  });

  moveBackground();
//jQuery time
var current_fs, next_fs, previous_fs; //fieldsets
var left, opacity, scale; //fieldset properties which we will animate
var animating; //flag to prevent quick multi-click glitches

$(".next").click(function(){
if(animating) return false;
animating = true;

current_fs = $(this).parent();
next_fs = $(this).parent().next();

//activate next step on progressbar using the index of next_fs
$("#progressbar li").eq($("fieldset").index(next_fs)).addClass("active");

//show the next fieldset
next_fs.show();
//hide the current fieldset with style
current_fs.animate({opacity: 0}, {
  step: function(now, mx) {
    //as the opacity of current_fs reduces to 0 - stored in "now"
    //1. scale current_fs down to 80%
    scale = 1 - (1 - now) * 0.2;
    //2. bring next_fs from the right(50%)
    left = (now * 10)+"%";
    //3. increase opacity of next_fs to 1 as it moves in
    opacity = 1 - now;
    current_fs.css({
      'transform': 'scale('+scale+')',
      'position': 'absolute'
    });
    next_fs.css({'left': left, 'opacity': opacity});
  },
  duration: 800,
  complete: function(){
    current_fs.parent();
    animating = false;
  },
  //this comes from the custom easing plugin
  easing: 'easeInOutBack'
});
});

$(".previous").click(function(){
if(animating) return false;
animating = true;

current_fs = $(this).parent();
previous_fs = $(this).parent().prev();

//de-activate current step on progressbar
$("#progressbar li").eq($("fieldset").index(current_fs)).removeClass("active");

//show the previous fieldset
previous_fs.show();
//hide the current fieldset with style
current_fs.animate({opacity: 0}, {
  step: function(now, mx) {
    //as the opacity of current_fs reduces to 0 - stored in "now"
    //1. scale previous_fs from 80% to 100%
    scale = 0.8 + (1 - now) * 0.2;
    //2. take current_fs to the right(50%) - from 0%
    left = ((1-now) * 50)+"%";
    //3. increase opacity of previous_fs to 1 as it moves in
    opacity = 1 - now;
    current_fs.css({'left': left});
    previous_fs.css({'transform': 'scale('+scale+')', 'opacity': opacity});
  },
  duration: 800,
  complete: function(){
    current_fs.hide();
    animating = false;
  },
  //this comes from the custom easing plugin
  easing: 'easeInOutBack'
});
});

/* Tooltip */
$('#btn_copy').tooltip({
  trigger: 'click',
  placement: 'bottom'
});

/* Click To Reveal */
$(".btn_secret").click(function () {
  $(".btn_secret").hide(300);
});

function setTooltip(btn, message) {
  $(btn).tooltip('hide')
    .attr('data-original-title', message)
    .tooltip('show');
}

function hideTooltip(btn) {
  setTimeout(function() {
    $(btn).tooltip('hide');
  }, 1000);
}
/* Clipboard */
if($("#btn_copy").length != 0){
  var clipboard = new ClipboardJS('#btn_copy');

  clipboard.on('success', function(e) {
    setTooltip(e.trigger, 'Copied!');
    hideTooltip(e.trigger);
  });

  clipboard.on('error', function(e) {
    setTooltip(e.trigger, 'Failed!');
    hideTooltip(e.trigger);
  });
}
$('*[data-href]').on('click', function() {
  window.location = $(this).data("href");
});
// });
});
