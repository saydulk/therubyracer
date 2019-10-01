class CollectionWalletDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def view_columns

    @view_columns ||= {
      id: { source: 'Wallet.id', cond: :like },
       currency_id: { source: 'Wallet.currency_id', cond: :like },

       name: { source: 'Wallet.name', cond: :like },
       address: { source: 'Wallet.Address', cond: :like },
       kind: { source: 'Wallet.kind', cond: :like },
       status: { source: 'Wallet.status', cond: :like },
       created_at: { source: 'Wallet.created_at', cond: :like }
    }
  end

  def data
    records.map do |record|
       if record.id.present?
        {
            id: record.id,
            currency_id:record.currency_id.upcase,
            name: record.name.capitalize,
            address:record.address,
            kind: record.kind.titleize,
            status: record.status.titleize,
            created_at: record.created_at.strftime('%B %d, %Y %R'),
            action:  "<a href='/admin/wallets/#{record.id}'>View</a>".html_safe
        }
       end
    end
  end

  def get_raw_records
    records = Wallet.includes(:blockchain)
    records
  end

end
