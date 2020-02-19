// knm +
var loadList = function() {
  var selectedValue = jQuery('#project_national_project_id').val();
  jQuery('#project_federal_project_id').children().css('display','none');
  jQuery('#project_federal_project_id').children('#' + selectedValue).css('display','');
  jQuery('#project_federal_project_id').children().first().css('display','');
};

var reloadList = function() {
  jQuery('#project_national_project_id').change(function () {
    loadList();
    jQuery('#project_federal_project_id').val(0);
  });
};

jQuery(document).ready(loadList);
jQuery(document).ready(reloadList);

//-
