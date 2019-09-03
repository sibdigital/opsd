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
};


jQuery(document).ready(loadList);



