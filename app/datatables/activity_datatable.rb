class ActivityDatatable < AjaxDatatablesRails::ActiveRecord

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      ip_address: { source: "Activity.ip_address", cond: :eq, searchable: true, orderable: true },
      user_email: { source: "Member.email", cond: :like, searchable: true, orderable: true  },
      sign_in: { source: "Activity.created_at", cond: :like, searchable: false, orderable: false  },

    }
  end

  def data
    records.map do |record|
      if record
        {
          ip_address: record.ip_address,
          user_email: record.email,
          sign_in: record.signin.strftime("%Y-%m-%d %H:%M:%S") ,
          view_activity: "<a href='/admin/show_activity/#{record.m_id}'>View</a>".html_safe
        }
      end
    end
  end

  def get_raw_records
    records = Activity.joins(:member).group("activities.member_id").select('activities.ip_address as ip_address, members.email as email, members.id as m_id, max(activities.created_at) as signin ')
    records
  end

  def as_json(options = {})
    {
        # :sEcho => params[:sEcho].to_i,
        :recordsTotal => get_raw_records.length,
        :recordsFiltered => filtered_records_count,
        :data => data
    }
  end

  def filtered_records_count
    records_count = filter_records(get_raw_records).length
    return records_count.inject(0){|a,(_,b)|a+b} if records_count.is_a?(Hash)
    records_count
  end

end
