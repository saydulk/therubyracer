$ ->

  $('#admin_activity_datatable').dataTable
    processing: true
    serverSide: true
    ajax: $('#admin_activity_datatable').data('source')
    pagingType: 'full_numbers'
    searching: false
    columns: [
      {
        data: 'ip_address'
        name: "ip_address"
        searchable: true
        orderable: true
      }

      {
        data: 'created_at'
        name: "created_at"
      }
    ]

  $('#dashboard_full_datatable').dataTable
    processing: true
    serverSide: true
    ajax: $('#dashboard_full_datatable').data('source')
    pagingType: 'full_numbers'
    searching: true
    language: {
      searchPlaceholder: "By Name"
    }
    columns: [
      {
        data: "code"
        name: "code"
        searchable: true
        orderable: true
      }

      {
        data: "locked_balance"
        name: "locked_balance"
        searchable: false
        orderable: true
      }

      {
        data: "balance"
        name: "balance"
        searchable: false
        orderable: false
      }

      {
        data: "sum"
        name: "sum"
        searchable: false
        orderable: false
      }

      {
        data: "hot_balance"
        name: "hot_balance"
        searchable: false
        orderable: false
      }

      {
        data: "cold_balance"
        name: "cold_balance"
        searchable: false
        orderable: false
      }
    ]

  $('#dashboard_one_day_datatable').dataTable
    processing: true
    serverSide: true
    ajax: $('#dashboard_one_day_datatable').data('source')
    pagingType: 'full_numbers'
    searching: true
    language: {
      searchPlaceholder: "By Name"
    }
    columns: [
      {
        data: "code"
        name: "code"
        searchable: true
        orderable: true
      }

      {
        data: "locked_balance"
        name: "locked_balance"
        searchable: false
        orderable: true
      }

      {
        data: "balance"
        name: "balance"
        searchable: false
        orderable: false
      }

      {
        data: "sum"
        name: "sum"
        searchable: false
        orderable: false
      }

      {
        data: "hot_balance"
        name: "hot_balance"
        searchable: false
        orderable: false
      }

      {
        data: "cold_balance"
        name: "cold_balance"
        searchable: false
        orderable: false
      }
    ]

  $('#deposits-datatable').dataTable
    processing: true
    serverSide: true
    ajax: $('#deposits-datatable').data('source')
    pagingType: 'full_numbers'
    searching: true
    columns: [
      {
        data: "txid"
        name: "txid"
        searchable: true
        orderable: true
      }
      {
        data: "created_at"
        name: "created_at"
        searchable: true
        orderable: true
      }
      {
        data: "currency"
        name: "currency"
        searchable: true
        orderable: true
      }
      {
        data: "member"
        name: "member"
        searchable: true
        orderable: false
      }
      {
        data: "amount"
        name: "amount"
        searchable: true
        orderable: false
      }
      {
        data: "confirmations"
        name: "confirmations"
        searchable: true
        orderable: false
      }
      {
        data: "actions"
        name: "actions"
        searchable: true
        orderable: false
      }
    ]
