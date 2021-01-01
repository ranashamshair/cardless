document.addEventListener("turbolinks:load", ()=> {
    // $("#example1").DataTable({
    //     "responsive": true,
    //     "autoWidth": false,
    //   });
      $('#example2').DataTable({
        "paging": false,
        "lengthChange": false,
        "searching": false,
        "ordering": true,
        "info": true,
        "autoWidth": false,
        "responsive": true,
      });
})