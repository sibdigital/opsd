//knm+
var loadForm = function() {
  var type = 'kind_' + jQuery('input[name=kind]:checked').val();
  jQuery('.radio-depend').hide();
  jQuery('.' + type).show();
};

var reloadForm = function() {
  jQuery('.radio-kind').change(function () {
    var type = this.id;
    jQuery('.radio-depend').hide();
    jQuery('.' + type).show();
  });
};

jQuery(document).ready(loadForm);
jQuery(document).ready(reloadForm);
//-
