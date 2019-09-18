
var description_info;
description_info=new Array(22);
for (var i = 0; i < 22; i++) {
  description_info[i]="";
}

function setMilestones()
{
  description_info=new Array(22);
  for (var i = 0; i < 22; i++) {
    description_info[i]="<table style='width: 400px'>"+
      "<thead>"+
      "<tr>"+
      "<th>Название</th>"+
      "<th>Ответственный</th>"+
      "<th>Статус</th>"+
      "</tr>"+
      "</thead>"+
      "<tbody style='text-align: left'>";
  }
  var inc = 0;
  var today=new Date();
  var dd = String(today.getDate()).padStart(2, '0');
  var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
  var yyyy = today.getFullYear();
  today = yyyy + '-' + mm + '-' + dd;
  var matrix = new Array(22);
  for (var i = 0; i < matrix.length; i++) {
    matrix[i] = new Array(4);
    for (var j=0;j<matrix[i].length;j++)
    {
      matrix[i][j]=0;
    }
  }
  jQuery.ajax({
      type: 'GET',
      url: document.location.pathname+'/get_wps',
      async: true,
      success:function (object) {

        object.forEach(function(){
          // if (object[inc][0].length>=47)
          // {
          //   object[inc][0]=object[inc][0].substring(0,44);
          //   object[inc][0]+="...";
          // }
          var name = object[inc][0].split(" ", 5);
          description_info[object[inc][2]-1]+="<tr>"+
            "<td>" +
            "<a href='/work_packages/details/" + object[inc][1] + "/overview?plan_type=execution'>" +
            name.join(" ")+ "..." +
            "</a>" +
            "</td>"+
            "<td>"+object[inc][3]+"</td>";
          if(inc<object.length&&object[inc][2]!==null&&object[inc][2]!==undefined)
          {
            if(object[inc][4]===2)
            {
              matrix[object[inc][2]-1][0]++;
              description_info[object[inc][2]-1]+="<td>Не исполнено</td>"+
                "</tr>";
              // this.style.fill='#c00000';
            }
            else if (object[inc][4]===3)
            {
              matrix[object[inc][2]-1][1]++;
              description_info[object[inc][2]-1]+="<td>Проблемы</td>"+
                "</tr>";
              // this.style.fill='#ffc000';
            }
            else if (object[inc][4]===4)
            {
              matrix[object[inc][2]-1][2]++;
              description_info[object[inc][2]-1]+="<td>В работе</td>"+
                "</tr>";
              // this.style.fill='#1f497d';//#1A27A3//#0000c0//#5555c5
            }
            else if (object[inc][4]===1)
            {
              matrix[object[inc][2]-1][3]++;
              description_info[object[inc][2]-1]+="<td>Исполнено</td>"+
                "</tr>";
              // this.style.fill='#00b050';
            }
            inc++;
          }
          // else {
          //   this.style.fill='lightgrey';
          // }

        });
        jQuery('[class="region"]').each(function () {
          if (matrix[parseInt(this.id)-1][0] > 0)
          {
            this.style.fill='#c00000';

          }
          else if(matrix[parseInt(this.id)-1][1] > 0)
          {
            this.style.fill='#ffc000';
          }
          else if(matrix[parseInt(this.id)-1][2] > 0)
          {
            this.style.fill='#1f497d';
          }
          else if(matrix[parseInt(this.id)-1][3] > 0)
          {
            this.style.fill='#00b050';
          }
          else {
            this.style.fill='grey';
          }

        });

      }
    }
  );
}

function showDescription(path)
{
  jQuery('[class="description"]').show();
  for (var i = 0; i < description_info.length; i++) {
    if (description_info[i] === "<table style='display: inline-block'><thead><tr><th>Название</th><th>Ответственный</th><th>Статус</th></tr></thead><tbody>"||description_info[i] === "")
    {
      description_info[i]="В данном районе пока нет проектов."
      jQuery('[class="description"]').html('<h2>' + jQuery('[id="' + path.id + '"]').attr('name') + '</h2>' + description_info[path.id-1]);
    }
    else
    {
      jQuery('[class="description"]').html('<h2>' + jQuery('[id="' + path.id + '"]').attr('name') + '</h2>' + description_info[path.id - 1] + '</tbody>' + '</table>');
    }
  }

}

var readDescription=function(){
  jQuery('a.show-description').click(function(){
    showDescription(this.childNodes[1]);
  });
  jQuery('[class="description"]').hide();
};

jQuery(document).ready(setMilestones());
jQuery(document).ready(readDescription());

