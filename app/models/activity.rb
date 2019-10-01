class Activity < ActiveRecord::Base
  belongs_to :member

  def self.export(data)
    attributes = %w(IP\ Address User\ Email Signin\ Time  )
    csv_data = CSV.generate do |csv|
      csv <<  attributes
      if data.present?
        data.each do |val|
          row_data = []
          row_data << val[3]
          row_data << val[4]
          row_data << val[1]
          csv << row_data
        end
      end
    end
    return csv_data
  end


  def self.export_single_activity(data)
    attributes = %w(IP\ Address Signin\ Time)
    csv_data = CSV.generate do |csv|
      csv <<  attributes
      if data.present?
        data.each do |val|
          row_data = []
          row_data << val[:ip_address]
          row_data << val[:created_at]
          csv << row_data
        end
      end
    end
    return csv_data
  end

end
