//created by knm
//= require notify
//  var pg = require('pg');
//  var connectionString = "postgres://postgres:@localhost/localhost:5432/opsd_dev_db";
//  var pgClient = new pg.Client(connectionString);

var notifyMe=function(){
  jQuery('button.btn').click(function()
  {
    notifying();
  });
  // pgClient.query("SELECT id from Users");
};
var timerId = setTimeout(notifying(),5000);

function notifying()
{
  var count;
  var time;
  // jQuery.ajax({})
  // jQuery.ajax({ type: 'GET',
  //   url: '/alerts/get_delay_setting',
  //   async: true,
  //   success: function(text)
  //   {
  //     time=text;
  //   }
  // });
  // jQuery.ajax({ type: 'GET',
  //   url: '/alerts/get_dues',
  //   async: true,
  //   success: function(text)
  //   {
  //     time=text;
  //   }
  // });
  jQuery.ajax({ type: 'GET',
    url: '/alerts/get_pop_up_alerts',
    async: true,
    success: function(text)
    {
      if (text!==null&&text!==undefined)
      {
        count=text.length;
        for (var i=0;i<count;i++)
        {
          var date=new Date(text[i].alert_date);
          pop(text[i].id, 'Произведено действие с записями таблицы ' + text[i].entity_type + ' в '+ date.toLocaleDateString(),time);
        }
      }
    }
  });
  setTimeout(notifying,5000);
}

function pop(id, text, time){
  jQuery.notify({
    title: 'Уведомление ',
    icon: 'glyphicon glyphicon-star',
    message: text

  },{
    allow_duplicates: false,
    type: 'info',
    // showProgressbar: true,
    delay: 0,
    timer: 0,
    animate: {
      enter: 'animated fadeInUp',
      exit: 'animated fadeOutRight'
    },
    allow_dismiss: true,
    placement: {
      from: 'bottom',
      align: 'right'
    },
    offset: 20,
    spacing: 10,
    z_index: 1031,
    template:
      '<div data-notify="container" id="'+
      id+
      '" class="col-xs-11 col-sm-3 alert alert-{0}" role="alert" style="width: 350px; color: #31708f; background-color: #d9edf7; border: 1px #bce8f1 solid; border-radius: 4px; padding: 15px; margin-bottom: 20px;" >' +
      '<button type="button" id="'+
      time+
      '" aria-hidden="true" class="close" style="float: right; font-size: 21px; font-weight: bold; line-height: 1; color: #000; text-shadow: 0 1px 0 #fff; filter: alpha(opacity=20); opacity: .2; -webkit-appearance: none; padding: 0; cursor: pointer; background: transparent; border: 0" data-notify="dismiss">×</button>' +
      '<span data-notify="icon"></span> ' +
      '<span data-notify="title"><strong>{1}</strong></span> <br>' +
      '<span data-notify="message">{2}</span><br>' +
      '<div class="progress" data-notify="progressbar">' +
      '<div class="progress-bar progress-bar-{0}" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>' +
      '</div>' +
      '<button type="button" aria-hidden="true" class="read" style="font-size: 14px; line-height: 1; color: #31708f; text-shadow: 0 1px 0 #fff; filter:  -webkit-appearance: none; opacity: .8; margin-left: 70%;  margin-top: 5px; cursor: pointer;padding: 5px; background: #d9edf7; border: 1px #31708f solid;border-radius: 4px;" data-notify="read">Прочитано</button>' +
      '<a href="{3}" target="{4}" data-notify="url"></a>' +
      '</div>'
  });

}

jQuery(document).ready(notifyMe);
jQuery(document).ready(timerId);
