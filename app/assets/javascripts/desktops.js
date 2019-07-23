function menuSpan() {
  jQuery('#rabocii-stol').show();

  jQuery('.rabocii-stol-menu-item').click(function () {
    jQuery('.homescreen-page--invisible').hide();
    jQuery('#rabocii-stol').show();
  });

  jQuery('.kontrolnie-tochki-menu-item').click(function () {
    jQuery('.homescreen-page--invisible').hide();
    jQuery('#kontrolnie-tochki').show();
  });

  jQuery('.riski-i-problemy-menu-item').click(function () {
    jQuery('.homescreen-page--invisible').hide();
    jQuery('#riski-i-problemy').show();
  });

  jQuery('.ispolnenie-pokazatelei-menu-item').click(function () {
    jQuery('.homescreen-page--invisible').hide();
    jQuery('#ispolnenie-pokazatelei').show();
  });

  jQuery('.ispolnenie-budzheta-menu-item').click(function () {
    jQuery('.homescreen-page--invisible').hide();
    jQuery('#ispolnenie-budzheta').show();
  });

  jQuery('.kpi-menu-item').click(function () {
    jQuery('.homescreen-page--invisible').hide();
    jQuery('#kpi').show();
  });

  jQuery('.elektronnyi-protokol-menu-item').click(function () {
    jQuery('.homescreen-page--invisible').hide();
    jQuery('#elektronnyi-protokol').show();
  });

  jQuery('.obsuzhdeniya-menu-item').click(function () {
    jQuery('.homescreen-page--invisible').hide();
    jQuery('#obsuzhdeniya').show();
  });

  jQuery('.ocenka-deyatelnosti-menu-item').click(function () {
    jQuery('.homescreen-page--invisible').hide();
    jQuery('#ocenka-deyatelnosti').show();
  });
}
jQuery(document).ready(menuSpan);
