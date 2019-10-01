$ ->
  $('#withdraws-datatable').dataTable
    processing: true
    serverSide: true
    ajax: $('#withdraws-datatable').data('source')
    pagingType: 'full_numbers'
    searchable: true
    orderable: true
    language: {
      searchPlaceholder: "By Bank or Amount"
    }
    columns: [
      {
        data: 'id'
        name: "id"
        searchable: false
        orderable: true
      }
      {
        data: 'created_at'
        name: "created_at"
        searchable: false
        orderable: false
      }
      {
        data: 'currency_obj_key_text'
        name: "currency_obj_key_text"
        searchable: true
        orderable: true
      }
      {
        data: 'member_name'
        name: "member_name"
        searchable: false
        orderable: false
      }
      {
        data: 'fund_source'
        name: "fund_source"
        searchable: true
        orderable: true
      }
      {
        data: 'amount'
        name: "amount"
        searchable: false
        orderable: false
      }
      {
        data: 'state_and_action'
        name: "state_and_action"
        searchable: false
        orderable: false
      }
    ]

  $('#withdraws_one_day_datatable').dataTable
    processing: true
    serverSide: true
    ajax: $('#withdraws_one_day_datatable').data('source')
    pagingType: 'full_numbers'
    searchable: true
    orderable: true
    language: {
      searchPlaceholder: "By Bank or Amount"
    }
    columns: [
      {
        data: "id"
        name: "id"
        searchable: false
        orderable: true
      }
      {
        data: "created_at"
        name: "created_at"
        searchable: false
        orderable: false
      }
      {
        data: 'currency_obj_key_text'
        name: "currency_obj_key_text"
        searchable: true
        orderable: true
      }
      {
        data: "member_name"
        name: "member_name"
        searchable: false
        orderable: false
      }
      {
        data: "fund_source"
        name: "fund_source"
        searchable: true
        orderable: true
      }
      {
        data: "amount"
        name: "amount"
        searchable: false
        orderable: false
      }
      {
        data: "state_and_action"
        name: "state_and_action"
        searchable: false
        orderable: false
      }
    ]
  $('#fiats_deposit').dataTable
    processing: true
    serverSide: true
    ajax: $('#fiats_deposit').data('source')
    pagingType: 'full_numbers'
    searchable: true
    orderable: true
    columns: [
      {
        data: "email"
        name: "email"
        searchable: true
        orderable: true
      }
      {
        data: "amount"
        name: "amount"
        searchable: true
        orderable: true
      }
      {
        data: "done_at"
        name: "done_at"
        searchable: true
        orderable: true
      }
      {
        data: "fund_uid"
        name: "fund_uid"
        searchable: true
        orderable: true
      }
      {
        data: 'view_deposit'
        name: 'view_deposit'
        searchable: true
        orderable: false
      }

    ]
