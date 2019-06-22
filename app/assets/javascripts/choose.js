
(function($) {

  $(function() {

    // function choose_from_depart_organizations_path(){
    //   alert('1');
    // };

    $('#choose_from_depart_organizations_path').bind('click', function() {
      console.log('User clicked on "foo."');
      MicroModal.show('modal-1');
    });

  });
}(jQuery));
