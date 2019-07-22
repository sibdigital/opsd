function menuSpan() {
    jQuery('.rabocii-stol-menu-item').click(function () {
    jQuery('.test1').hide();
    jQuery('#glava').show();
  });

  jQuery('.other-stol-menu-item').click(function () {
    jQuery('.test1').hide();
    jQuery('#tasks').show();
  });
}

jQuery(document).ready(menuSpan);
