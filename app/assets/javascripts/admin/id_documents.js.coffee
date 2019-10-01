jQuery ->
  $('#verified_datatable').dataTable
    processing: true
    serverSide: true
    ajax: $('#verified_datatable').data('source')
    pagingType: 'full_numbers'
    searching: true
    language: {
      searchPlaceholder: "By Name or Email"
    }
    columns: [
      {
        data:"name"
        name: "name"
        searchable: true
        orderable: true
      }
      {
        data: 'email'
        name: 'email'
        searchable: true
        orderable: true
      }
#      {
#        data: 'id_document_type'
#        name: 'id_document_type'
#        searchable: false
#        orderable: false
#      }
      {
        data: 'id_bill_type'
        name: 'id_document_type'
        searchable: false
        orderable: false
      }
      {
        data: 'updated_at'
        name: 'updated_at'
        searchable: false
        orderable: false
      }
      {
        data: 'verified'
        name: 'verified'
        searchable: false
        orderable: false
      }

      {
        data: 'view_user'
        name: 'view_user'
        searchable: false
        orderable: false
      }


    ]

    $('#unverified_datatable').dataTable
      processing: true
      serverSide: true
      ajax: $('#unverified_datatable').data('source')
      pagingType: 'full_numbers'
      searching: true
      language: {
        searchPlaceholder: "By Name or Email"
      }
      columns: [
        {
          data:"name"
          name: "name"
          searchable: true
          orderable: true
        }
        {
          data: 'email'
          name: 'email'
          searchable: true
          orderable: true
        }
#        {
#          data: 'id_document_type'
#          name: 'id_document_type'
#          searchable: false
#          orderable: false
#        }
        {
          data: 'id_bill_type'
          name: 'id_document_type'
          searchable: false
          orderable: false
        }
        {
          data: 'updated_at'
          name: 'updated_at'
          searchable: false
          orderable: false
        }
        {
          data: 'verified'
          name: 'verified'
          searchable: false
          orderable: false
        }

        {
          data: 'view_user'
          name: 'view_user'
          searchable: false
          orderable: false
        }

      ]
