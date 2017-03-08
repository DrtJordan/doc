(function($){
$.scrollTop=function(obj)
{
     var step = 20,
         topBtn = $(obj);         
     function goTop(){
              var top = $(window).scrollTop();               
              if(top > step){
                       topBtn.css("display" , "block");
              } else {
                       topBtn.css("display" , "none");
              }
     }
     $(window).on('scroll',goTop);
     topBtn.click(function(e){
              $(window).scrollTop(0);
              e.preventDefault();
     })
}     
})(jQuery);