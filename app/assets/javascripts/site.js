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

$(document).ready(function(){
  /* paging of long lists in availability side bar*/
  init_downloads_list();

  /* gotoviewer fix */
  $("a[href='#gotoviewer']").click(function() {
    $("html, body").animate({ scrollTop: $(document).height() });
    return false;
  });

});

function init_downloads_list(){

  //Math.ceil($(".hhc_pager li").length/10);
  ///$(".hhc_pager:gt(0)").hide();
	//  render_index(num_pages,0);
  $(".hhc_index").on("click", ".hhc_ind", function(){
    if($(this).hasClass("disabled")){return false;}
    $(".hhc_pager").hide();
    $($(".hhc_pager").get($(this).data("index"))).show();
//    var show_this = $(".hhc_pager").get($(this).data("index"));
 //   $(show_this).show();
    render_index(parseInt($(this).data("index")));
  });

}

function render_index(current_ind){
  $(".hhc_index").empty();

  num_files=$("#num_files").data("num-files");
  num_pages=$("#num_pages").data("num-pages");
  page_size=$("#page_size").data("page-size");
  num_page_links_show=$("#num_page_links_show").data("num-page-links-show");
  console.log("num_pages: ",num_pages);
  console.log("num_page_links_show: ",num_page_links_show);
  console.log("num_files", num_files);
  console.log("page_size", page_size);


  if(num_pages > num_page_links_show){
    start_page = (current_ind-Math.floor(num_page_links_show/2));

    $(".hhc_index").append('<li class="btn hhc_ind hhc_page_'+(current_ind-1)+' prev" data-index="'+(current_ind-1)+'">&lt;&lt;</li>');

    console.log(current_ind," > (",num_pages,"-",num_page_links_show,")");
    console.log(current_ind," > ",(num_pages-num_page_links_show));


    if(start_page > (num_pages-(num_page_links_show*2)) && start_page <= (num_pages-(num_page_links_show))){
       start_page = num_pages-(num_page_links_show*2);
    }
    // at this point we move to the right hand page links and set the left hand ones back to 1
    if(current_ind >= (num_pages-num_page_links_show)){
       start_page = 0;
    }
    if(start_page < 0 ){
       start_page = 0;
    }
    if(current_ind > 0){
      $(".hhc_index .prev").removeClass('disabled').addClass("btn-primary");
    }

    for (var i=start_page; i < (start_page+num_page_links_show); i++){
      if(i==current_ind){
        $(".hhc_index").append('<li class="btn btn-primary btn-success hhc_ind hhc_page_'+i+'" data-index="'+i+'">'+(parseInt(i)+1)+'</li>');
      }else{
        $(".hhc_index").append('<li class="btn btn-primary hhc_ind hhc_page_'+i+'" data-index="'+i+'">'+(parseInt(i)+1)+'</li>');
      }
    }
    $(".hhc_index").append('<li class="hhc_ind">...</li>');
//    <% [*@num_pages-@num_page_links_show..@num_pages-1].each do | i | %>

   for (var i=(num_pages-num_page_links_show); i < (num_pages); i++){
      if(i==current_ind){
        $(".hhc_index").append('<li class="btn btn-primary btn-success hhc_ind hhc_page_'+i+'" data-index="'+i+'">'+(parseInt(i)+1)+'</li>');
      }else{
        $(".hhc_index").append('<li class="btn btn-primary hhc_ind hhc_page_'+i+' btn-primary" data-index="'+i+'">'+(parseInt(i)+1)+'</li>');
      }
    }
  }else{
    if(current_ind == 0){
      $(".hhc_index .prev").addClass('disabled').removeClass("btn-primary");
    }
    for (var i=start_page; i < (num_pages-1); i++){
      if(i==current_ind){
        $(".hhc_index").append('<li class="btn btn-primary btn-success hhc_ind hhc_page_'+i+'" data-index="'+i+'">'+(parseInt(i)+1)+'</li>');
      }else{
        $(".hhc_index").append('<li class="btn btn-primary hhc_ind hhc_page_'+i+'" data-index="'+i+'">'+(parseInt(i)+1)+'</li>');
      }
    }
  }
  $(".hhc_index").append('<li class="btn btn-primary hhc_ind hhc_page_'+(current_ind+1)+' next" data-index="'+(current_ind+1)+'">&gt;&gt;</li>');
  if(current_ind == (num_pages-1)){
      $(".hhc_index .next").addClass('disabled').removeClass("btn-primary");
    }

}

// $(document).scroll(function () {
// else {;
//   $('#main-container').css("padding-top","0px");
// }

// });l
