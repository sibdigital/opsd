// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// var hideDiv = function (id) {
//   jQuery('.test1').style.display = 'none';
//   jQuery(id).style.display = 'block';
// };

function menuSpan() {

  var glavaVisible = false;
  var currentMenu = '';

  if(!glavaVisible){
    jQuery('#glava').show();
    currentMenu = 'glava';
  }

  function showMenu(){
    //jQuery('#'+currentMenu)
    jQuery('.menu').animate({ //выбираем класс menu и метод animate
      left: '0px' /* теперь при клике по иконке, меню, скрытое за
                 левой границей на 285px, изменит свое положение на 0px и станет видимым */
    }, 200); //скорость движения меню в мс

    jQuery('.background').animate({ //выбираем тег body и метод animate
      left: '225px' /* чтобы всё содержимое также сдвигалось вправо
                 при открытии меню, установим ему положение 285px */
    }, 200); //скорость движения меню в мс
  }

  function hideMenu(){
    jQuery('.menu').animate({ //выбираем класс menu и метод animate
      left: '-225px' /* при клике на крестик меню вернется назад в свое
               положение и скроется */
    }, 200); //скорость движения меню в мс

    jQuery('.background').animate({ //выбираем тег body и метод animate
      left: '0px' //а содержимое страницы снова вернется в положение 0px
    }, 200); //скорость движения меню в мс
  }

  jQuery('#glava-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#glava').show();
    hideMenu();
  });

  jQuery('#tasks-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#tasks').show();
    hideMenu();
  });

  jQuery('#problems-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#problems').show();
    hideMenu();
  });

  jQuery('#targets-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#targets').show();
    hideMenu();
  });

  jQuery('#budget-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#budget').show();
    hideMenu();
  });

  jQuery('#kpi-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#kpi').show();
    hideMenu();
  });

  jQuery('#protocol-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#protocol').show();
    hideMenu();
  });

  jQuery('#discuss-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#discuss').show();
    hideMenu();
  });

  jQuery('#activity-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#activity').show();
    hideMenu();
  });

  jQuery('.icon-menu-span').click(function() { /* выбираем класс icon-menu и
               добавляем метод click с функцией, вызываемой при клике */
    if(jQuery('.menu').css('left') === '-225px') {
      showMenu();
    }
    else {
      hideMenu();
    }
  });


  /* Закрытие меню */
  jQuery('.icon-close').click(function() { //выбираем класс icon-close и метод click
    hideMenu();
  });
}

jQuery(document).ready(menuSpan);
