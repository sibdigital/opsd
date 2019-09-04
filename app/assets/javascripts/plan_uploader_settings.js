// tmd

// function updateColumn() {
//   console.log('request');
//   jQuery.ajax({
//     type: 'GET',
//     url: '/plan_uploader_settings/update_column',
//     data: { selectedColumn: jQuery(document).find('#table-list')[0].value },
//     async: true
//   });
// }


// jQuery(document).ready(function () {
//   jQuery('#column-list').
// });

var loadList = function() {
  jQuery('#table-list').change(function()
  {
    var selectedValue = jQuery('#table-list').val();
    console.log(selectedValue);
    jQuery.ajax({
      type: 'GET',
      url: 'admin/plan_uploader_settings/update_column',
      data: { selectedColumn: selectedValue },
      async: true,
      success: function (json) {
        console.log(json);
        var dropDownList = jQuery('#column-list');
        dropDownList.html('');
        jQuery.each(json, function(index) {
          dropDownList.append(
            jQuery('<option></option>').val(json[index].name).html(json[index].human_name)
          );
        });
      }
    });
  });

  jQuery('#setting-type-select').change(function()
  {
    var selectedValue = jQuery('#setting-type-select').val();
    console.log(selectedValue);

    if(selectedValue == 999) {
      jQuery('#setting-type-select').hide();
      jQuery('#setting-type-block').append("<input placeholder=\"введите новое значение типа\" id=\"setting-type-input\" class=\"form--text-field\" type=\"text\" name=\"plan_uploader_setting[setting_type]\">");
    }
  });

};


jQuery(document).ready(loadList);



