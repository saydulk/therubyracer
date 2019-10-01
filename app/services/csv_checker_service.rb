require 'csv'
require 'open-uri'
class CsvCheckerService

  attr_accessor :airdrop_file, :local

  HEADER = %w(Email\ Id Wallet\ Address Token )

  def initialize(airdrop_file, local = false)
    @airdrop_file = airdrop_file
    @local = local
  end

  def is_valid?
    flag = true
    row = csv.first
    return false unless row
    row&.each do |attr|
      (flag = false and break) unless (HEADER.map &:downcase).include? attr&.downcase
    end
    flag
  end

  def total_amount
    total_token = 0
    csv.each_with_index do |row , index|
      total_token +=  row[2].to_f unless index == 0 and row.length == 3
    end
    total_token
  end

  def csv
    # return [] unless File::exists?()
    if %w(development test).include?(Rails.env) || @local
      CSV.parse(File.read(@airdrop_file.file.path))
    else
      csv_text = open(@airdrop_file.file.url)
      CSV.parse(csv_text)
    end
  end

end