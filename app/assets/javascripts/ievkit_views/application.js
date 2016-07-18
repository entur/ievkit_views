"use strict";

(function($){
  $(document).on('page:change', function () {
    $('.ievkit-AccordionBlock-details').click( function() {
      var $gi = $(this).find('.glyphicon');
      $gi.toggleClass('glyphicon-plus glyphicon-minus');
      $(this).closest('li').find('div').slideToggle();
    });
    $('[data-toggle="collapse"]').click( function() {
      var index = parseInt($(this).data('jump-to'));
      if(index > 4) {
        window.location.href = '#heading-' + (index - 4);
      }
    });
  });
})(jQuery);
