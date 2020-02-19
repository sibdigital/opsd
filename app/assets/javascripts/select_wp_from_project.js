// ban +
var loadList = function() {
  var selectedValue = jQuery('#user_task_project_id').val();
  jQuery('#user_task_object_id').children().css('display','none');
  jQuery('#user_task_object_id').children('#' + selectedValue).css('display','');
  jQuery('#user_task_object_id').children().first().css('display','');
  jQuery('#user_task_object_id').val(0);
};

var reloadList = function() {
  jQuery('#user_task_project_id').change(function () {
    loadList();
  });
};

jQuery(document).ready(loadList);
jQuery(document).ready(reloadList);

//-
