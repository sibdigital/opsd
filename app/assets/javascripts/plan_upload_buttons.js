var loadForm=function () {
  jQuery('div.loading-form')[0].style='display:none';
  jQuery('button.button-load-form').click(function()
  {
    var protocol;
    var path = document.location.hostname;
    var port = null;
    var user;
    var project;
    var url;
    var location = document.location.pathname;
    var button = this;
    jQuery.ajax({
      type: 'GET',
      url: location.substring(0, location.lastIndexOf('/')) + '/get_info',
      async: true,
      success: function (object) {
        user = object.user;
        project = object.project;
        url = object.url;
        if(button.id === 'UploadPlanType6') {
          // window.location = protocol + '://' + path + (port !== null ? port : '') +
          //   '/jopsd/upload/mpp?' +
          //   ('authorId=' + user) + '&' + ('projectId=' + project);
          window.location = '/jopsd/upload/mpp?' +
            ('projectId=' + project);
        }
        else if(button.id === 'UploadPlanType7') {
          // window.location = protocol + '://' + path + (port !== null ? port : '') +
          //   '/jopsd/upload/el_budget?' +
          //   ('authorId=' + user) + '&' + ('projectId=' + project);
          window.location = '/jopsd/upload/el_budget?' +
            ('projectId=' + project);
        }
        else {
          jQuery('div.loading-form')[0].style='display:block';
          jQuery('div.type-buttons')[0].style='display:none';
          jQuery('#upload-plan-type')[0].value = button.id;
        }
      }
    });
  });
};

jQuery(document).ready(loadForm());
