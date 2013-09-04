
$(document).ready(function(){
  var isScroll = function (el) {
    // test targets
    var elems = el ? [el] : [document.documentElement, document.body];
    var scrollX = false, scrollY = false;
    for (var i = 0; i < elems.length; i++) {
      var o = elems[i];
      // test horizontal
      var sl = o.scrollLeft;
      o.scrollLeft += (sl > 0) ? -1 : 1;
      o.scrollLeft !== sl && (scrollX = scrollX || true);
      o.scrollLeft = sl;
      // test vertical
      var st = o.scrollTop;
      o.scrollTop += (st > 0) ? -1 : 1;
      o.scrollTop !== st && (scrollY = scrollY || true);
      o.scrollTop = st;
    }
    // ret
    return {
      scrollX: scrollX,
      scrollY: scrollY
    };
  };

  $('body').on('show.bs.modal', function () {
    if(!isScroll().scrollY){
      // no-scroll
      $('body').addClass("modal-open-noscroll");
    }else { 
      $('body').removeClass("modal-open-noscroll");
    }
  })
})
