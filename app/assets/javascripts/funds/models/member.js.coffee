class Member extends PeatioModel.Model
  @configure 'Member', 'sn', 'created_at', 'updated_at', 'last_change'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Member.create(record)

window.Member = Member
