class AdminActivityDatatable < AjaxDatatablesRails::ActiveRecord

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      ip_address: { source: 'Activity.ip_address', cond: :like, searchable: true, orderable: true },
      created_at: { source: 'Activity.created_at', cond: :eq, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      {
          ip_address: record.ip_address,
          created_at: record.created_at
      }
    end
  end

  def get_raw_records
    member_id = params[:id]
    Activity.where(member: member_id )
  end

end
