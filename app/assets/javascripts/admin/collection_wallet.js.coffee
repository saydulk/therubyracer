$ ->
  $('#admin_wallet_datatable').dataTable
    processing: true
    serverSide: true
    ajax: $('#admin_wallet_datatable').data('source')
    pagingType: 'full_numbers'
    language: {
      searchPlaceholder: "Currency or Name or Add."
    }

    columns: [
      {
        data: 'id'
        name: "id"
      }
      {
        data: 'currency_id'
      }
      {
        data: 'name'
      }
      {
        data: 'address'
      }
      {
        data: 'kind'
      }
      {
        data: 'status'
      }
      {
        data: 'created_at'
      }
      {
        data: 'action'
        searchable: false
        orderable: false
      }

    ]