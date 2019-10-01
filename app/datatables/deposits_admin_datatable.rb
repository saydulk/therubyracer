class DepositsAdminDatatable < AjaxDatatablesRails::ActiveRecord

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
        txid: { source: "Deposit.txid", cond: :eq },
        created_at: { source: "Deposit.created_at", cond: :eq },
        currency: { source: "Deposit.currency", cond: :eq,  searchable: true, orderable: true  },
        amount: { source: "Deposit.amount", cond: :eq,searchable: true },
        confirmations: { source: "Deposit.confirmations", cond: :eq },
    }
  end

  def data
    records.map do |record|
      action = record.may_accept? ? "<span> / </span> <a confirm='Confirm deposit?' rel='nofollow' data-method='PATCH' href='/admin/deposits/#{params['self'].controller_name}/#{record.id}'>Accept</a>" : ''
      {
          txid: "<a href='#{record.blockchain_url}' target='_blank'><code class='text-info'> #{record.txid.truncate(36)} </code></a>".html_safe,
          created_at: record.created_at,
          currency: record.currency.upcase,
          member: "<a target='_blank' href='/admin/members/#{record.member.id}'>#{record.member.name.present? ? record.member.name.to_s.capitalize : '/admin/members/' + record.member.id.to_s }</a>".html_safe,
          amount: "<code class='text-info'>#{record.amount} </span>".html_safe ,
          confirmations: "<span class='badge'>#{record.confirmations} </span>".html_safe,
          actions: "<span> #{record.aasm_state_text }</span> #{action}".html_safe
      }
    end
  end

  def get_raw_records
    deposit_model = "::Deposits::#{params[:self].class.name.demodulize.gsub(/Controller\z/, '').singularize}".constantize
    records = deposit_model.includes(:member).order('created_at desc')
    records = records.where("deposits.txid like ? or deposits.amount like ?", "%#{params[:search][:value].strip}%", "%#{params[:search][:value].strip}%" ) if params[:search][:value].present?
    records
  end

end
