import $ from 'jquery';

const initMarquee = () => {
  console.log('executed');
  var marquee = $('div.marquee');
  console.log(marquee);
  marquee.each(function() {
      var mar = $(this),indent = mar.width();
      mar.marquee = function() {
          indent--;
          mar.css('text-indent',indent);
          if (indent < -1 * mar.children('div.marquee-text').width()) {
              indent = mar.width();
          }
      };
      mar.data('interval',setInterval(mar.marquee,1000/60));
  });
};
export { initMarquee };
