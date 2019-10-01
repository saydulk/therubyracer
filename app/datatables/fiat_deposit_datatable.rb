class FiatDepositDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable
  def_delegators :@view,
                 :admin_deposits_fiats_path
                 :raw
                 :concat

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
        email: { source: "Member.email", cond: :like, searchable: true, orderable: true },
        amount: { source: "Deposit.amount", cond: :like, searchable: true, orderable: true },
        done_at: { source: "Deposit.done_at", cond: :eq },
        fund_uid: { source: "Deposit.fund_uid", cond: :like, searchable: true, orderable: true },
    }
  end

  def data
    records.map do |record|
      {
        email: record.member.email,
        amount: record.amount,
        done_at: record.done_at,
        fund_uid: record.fund_uid,
        view_deposit: "<a href='/admin/deposits/fiats/#{record.id}'>View</a>".html_safe
      }
    end
  end

  def get_raw_records
    deposit_model = "::Deposits::Fiat".constantize
    records = deposit_model.includes(:member).references(:member)
    records = records.where("members.email like :name or deposits.fund_uid like :name or deposits.amount like :name ", { name: "%#{params[:search][:value].strip}%" } )
    records
  end

end
