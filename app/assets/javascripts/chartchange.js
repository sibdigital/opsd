var startChange = function()
{
  jQuery('a.changeChart').click(function(){
    changing(event.target.value);
  });
};
function changing(showInfo)
{
  var min=0;
  var max=100;
  var first = Math.floor(Math.random() * (+max - +min)) + +min;
  var second = Math.floor(Math.random() * (+max - +min)) + +min;
  var third = Math.floor(Math.random() * (+max - +min)) + +min;
  var fourth = Math.floor(Math.random() * (+max - +min)) + +min;
  var dataarray=[[80,90,95,100],[80,90,95,100],[80,90,95,100],
                  [80,90,95,100],[80,90,95,100],[80,90,95,100],
                  [80,90,95,100],[80,90,95,100],[80,90,95,100],
                  [80,90,95,100],[80,90,95,100],[80,90,95,100],
                  [80,90,95,100],[80,90,95,100],[80,90,95,100]];
  document.getElementById('chartlabel').innerText=event.target.innerText;

  console.log(document.getElementById('chartone').getAttribute('chart-data'));
  document.getElementById('chartone').setAttribute('chart-data','[{"data":['+first.toString()+','+second.toString()+','+third.toString()+','+fourth.toString()+'],"label":"false"}]');
  //случайный набор данных каждый клик
  var index = event.target.id;
  //setAttribute('chart-data','[{"data":['+dataarray[index][0].toString()+','+dataarray[index][1].toString()+','+dataarray[index][2].toString()+','+dataarray[index][3].toString()+'],"label":"false"}]');
  // для того чтобы использовать заготовленный набор данных dataarray

  document.getElementById("chartone").childNodes[0].childNodes[1].click();
}


JQuery(document).ready(startChange);
