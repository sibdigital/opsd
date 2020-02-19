jQuery(function($) {
  function toggleContentTypeForm(content_type, edit) {
    jQuery('.edit-' + content_type).toggle(edit);
    jQuery('.show-' + content_type).toggle(!edit);

    jQuery('.button--edit-agenda').toggleClass('-active', edit);
    jQuery('.button--edit-agenda').attr('disabled', edit);
  }

  $('.button--edit-agenda').click(function() {
    var content_type = $(this).data('contentType');
    toggleContentTypeForm(content_type, true);

    return false;
  });

  $('.button--cancel-agenda').click(function() {
    var content_type = $(this).data('contentType');
    toggleContentTypeForm(content_type, false);

    return false;
  });


  $('.meetings--checkbox-version-to').click(function() {
    var target = $(this).data('target');
    $(target).prop('checked', true);
  });

  //iag(
  jQuery( document ).ready(function() {
    jQuery('#meeting-protocol-add').click(function(){
      jQuery(this).hide();
      jQuery('#meeting-protocol-form').show("fast");
    });
    jQuery('#meeting-protocol-cancel').click(function(){
      jQuery('#meeting-protocol-add').show("fast");
      jQuery('#meeting-protocol-form').hide("fast");
    });
  });
//)
//  knm+
  jQuery(document).ready(function(){
    jQuery('.meeting-protocol-edit').click(function () {
      jQuery('#'+this.id+'.showing').hide('fast');
      jQuery('#'+this.id+'.updating').show('fast');
    });
    jQuery('.meeting-protocol-edit-cancel').click(function(){
      jQuery('#'+this.id+'.updating').hide('fast');
      jQuery('#'+this.id+'.showing').show('fast');
    });
  });
//  knm-
});
