jQuery ->

  $('#activity_datatable').dataTable
    processing: true
    serverSide: true
    ajax: $('#activity_datatable').data('source')
    pagingType: 'full_numbers'
    searching: true
    language: {
      searchPlaceholder: "By  Email"
    }
    columns: [
      {
        data:"ip_address"
        name: "address"
        searchable: true
        orderable: true
      },
      {
        data:"user_email"
        name: "user_email"
        searchable: true
        orderable: true
      },
      {
        data:"sign_in"
        name: "sign_in"
        searchable: false
        orderable: false
      },
      {
        data: 'view_activity'
        name: 'view_activity'
        searchable: false
        orderable: false
      }

    ]

