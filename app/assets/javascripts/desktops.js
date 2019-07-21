// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// var hideDiv = function (id) {
//   jQuery('.test1').style.display = 'none';
//   jQuery(id).style.display = 'block';
// };

var currentMenu = '';
var glavaVisible = false;

function menuSpan() {


  if(!glavaVisible){
    jQuery('#glava').show();
    //currentMenu = 'glava';
  }

  function showMenu(){
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
    currentMenu = event.target.id;
    jQuery('.test-li').css('background-color', '#333333');
    jQuery('#' + event.target.id).css('background-color', '#16598c');
  });

  jQuery('#tasks-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#tasks').show();
    hideMenu();
    currentMenu = event.target.id;
    jQuery('.test-li').css('background-color', '#333333');
    jQuery('#' + event.target.id).css('background-color', '#16598c');
  });

  jQuery('#problems-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#problems').show();
    hideMenu();
    currentMenu = event.target.id;
    jQuery('.test-li').css('background-color', '#333333');
    jQuery('#' + event.target.id).css('background-color', '#16598c');
  });

  jQuery('#targets-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#targets').show();
    hideMenu();
    jQuery('.test-li').css('background-color', '#333333');
    jQuery('#' + event.target.id).css('background-color', '#16598c');
  });

  jQuery('#budget-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#budget').show();
    hideMenu();
    jQuery('.test-li').css('background-color', '#333333');
    jQuery('#' + event.target.id).css('background-color', '#16598c');
  });

  jQuery('#kpi-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#kpi').show();
    hideMenu();
    jQuery('.test-li').css('background-color', '#333333');
    jQuery('#' + event.target.id).css('background-color', '#16598c');
  });

  jQuery('#protocol-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#protocol').show();
    hideMenu();
    jQuery('.test-li').css('background-color', '#333333');
    jQuery('#' + event.target.id).css('background-color', '#16598c');
  });

  jQuery('#discuss-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#discuss').show();
    hideMenu();
    jQuery('.test-li').css('background-color', '#333333');
    jQuery('#' + event.target.id).css('background-color', '#16598c');
  });

  jQuery('#activity-li').click(function () {
    jQuery('.test1').hide();
    jQuery('#activity').show();
    hideMenu();
    jQuery('.test-li').css('background-color', '#333333');
    jQuery('#' + event.target.id).css('background-color', '#16598c');
  });


  jQuery('.kpi-a').click(function () {
    jQuery('.test1').hide();
    jQuery('#kpi').show();
  });

  jQuery('.tasks-a').click(function () {
    jQuery('.test1').hide();
    jQuery('#tasks').show();
  });

  jQuery('.problems-a').click(function () {
    jQuery('.test1').hide();
    jQuery('#problems').show();
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
