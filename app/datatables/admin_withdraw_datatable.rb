class AdminWithdrawDatatable < AjaxDatatablesRails::ActiveRecord


  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
        id: { source: "Withdraw.id", cond: :like ,orderable: true},
        created_at: { source: "Withdraw.created_at", cond: :like,orderable: true },
        currency_obj_key_text: { source: "Withdraw.currency", cond: :like,searchable: true,orderable: true },
        fund_source: { source: "Withdraw.fund_extra", cond: :like,searchable: true,orderable: true},
        amount: { source: "Withdraw.amount", cond: :like,orderable: true },
    }
  end

  def data
    records.map do |record|
      {
        # example:
        id: record.id,
        created_at: record.created_at,
        currency_obj_key_text: record.currency.upcase,
        member_name: "<a href='/admin/members/#{record.member.id}'>#{record.member.name.present? ? record.member.name : "admin/members/#{record.member.id}" }</a>".html_safe,
        fund_source: "<span> #{record.fund_extra } # #{record.fund_uid.truncate(22)} </span>".html_safe ,
        amount: record.amount,
        state_and_action: "<span> #{record.aasm_state_text} / </span> <a href='/admin/withdraws/#{params['self'].controller_name}/#{record.id}'>View</a> ".html_safe

      }
    end
  end

  def get_raw_records
    # insert query here
    withdraw_model = "::Withdraws::#{params['self'].class.name.demodulize.gsub(/Controller\z/, '').singularize}".constantize
    records = withdraw_model.all.order(created_at: :desc) if params[:history] == 'full'
    records = withdraw_model.order('created_at desc') if params[:history] == 'one'
    records
  end

end
