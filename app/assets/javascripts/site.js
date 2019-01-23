$(document).on ('ready page:load', function (){

  // $('#search-navbar').affix({
  //     offset: {
  //       top: 80
  //     , bottom: function () {
  //         return (this.bottom = $('.footer').outerHeight(true))
  //       }
  //     }
  // })

  // $('#search-navbar').affix({
  //   offset: { top: $('#search-navbar').offset().top }
  // })

  // $('#nav-wrapper').height($("#nav").height());



  // $('#search-navbar').attr('data-offset-top', 80);

  // alert( 'navbar height: ' + $('#navbar').height());
  // alert( 'image-holder height: ' + (window.outerHeight - ( $('#navbar').height() ) ) );

  // var headerHeight = $('#myCarousel').css('max-height', (window.outerHeight - ( $('#navbar').height() * 2 )  ) );

  //var headerHeight = (window.outerHeight - ( $('#navbar').height() * 2 )  ) ;

  setHeaderSize();



  // $('#image-holder').css('height', (window.outerHeight - ( $('#navbar').height() ) ) );

  // resize header on widow resize
  var resizerId;

  $(window).resize(function() {
    clearTimeout(resizerId);
    resizerId = setTimeout(setHeaderSize, 500);
  });


});

function getScreenWidth() {
  var _width = $(window).width();
  return _width;
}

function setHeaderSize() {
  /* var _headerSubMenuHeight = $('#header-sub-menu').height(); */ //removed the sub-navbar
  var _headerHeight = ( ($(window).outerHeight()) - ( $('#navbar').height() * 2 ) ) ;
  var _carouselHeight = (_headerHeight /*- _headerSubMenuHeight */) / 1.75;
  $('#carousel').css('max-height', _carouselHeight );
  $('.image-holder').css('height', _carouselHeight );
}

function getScreenWidth() {
  var _width = $(window).width();
  return _width;
}

/* scroll to anchor of same name */
  $(function() {
    // $('a[href*=#]:not([href=#])').click(function() {
    // $('.scroll-to-anchor').click(function() {
    $('.scroll-to-anchor').click(function() {
      if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
        var target = $(this.hash);
        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
        if (target.length) {
          $('html,body').animate({
            scrollTop: target.offset().top - $('#navbar').height()
          }, 1000);
          return false;
        }
      }
    });
  });

// show scroll to top link if > 100
$(document).scroll(function () {
    var y = $(this).scrollTop();
    if (y > 100) {
        $('.scroll-to-top').fadeIn();
    } else {
        $('.scroll-to-top').fadeOut();
    }

});

// $(document).scroll(function () {
// else {;
//   $('#main-container').css("padding-top","0px");
// }

// });l