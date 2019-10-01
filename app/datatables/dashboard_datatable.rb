class DashboardDatatable < AjaxDatatablesRails::ActiveRecord
  delegate  :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        :recordsTotal => data.length,
        :recordsFiltered => data.length,
        :data => data.drop(@view[:start].to_i).first(@view[:length].to_i)
    }
  end

  def data

    records = ( @view[:search][:value].present? ? (Currency.all.select{|x|  x.code.include?@view[:search][:value].downcase.strip}) : Currency.all )
    all_records = ( @view[:summary] == 'full' ? records.map(&:summary) : records.map(&:summary_24) )
    all_records = sort_records(all_records)
    all_records.map do |record|
      {
        code: record[:name],
        locked_balance: record[:locked].present? ? record[:locked] : '',
        balance:  record[:balance].present? ? record[:balance] : '',
        sum:  record[:sum].present? ? record[:sum]: '',
        hot_balance: record[:hot].present? ? record[:hot]: '' ,
        cold_balance: record[:hot].present? ? (record[:sum] - record[:hot]) : 'N/A'
      }
    end
  end

 private

  def sort_records(all_records)
    a = [:code,:locked_balance, :balance, :sum,:hot_balance,:cold_balance]
    column_name = a[@view[:order]['0'][:column].to_i]
    direction = @view[:order]['0']["dir"]
    all_records = all_records.sort_by { |hsh| hsh[column_name] }
    all_records = all_records.reverse! if @view[:order]['0']["dir"] != 'asc'
    all_records
  end

end
