var loadForm=function () {
  jQuery('div.loading-form')[0].style='display:none';
  jQuery('button.button-load-form').click(function()
  {
    if(this.id === 'UploadPlanType6') {
      window.location.replace('http://37.18.27.44/jopsd/upload_mpp');
    }
    else {
      jQuery('div.loading-form')[0].style='display:block';
      jQuery('div.type-buttons')[0].style='display:none';
      jQuery('#upload-plan-type')[0].value = this.id;
    }
  });
};

jQuery(document).ready(loadForm());
