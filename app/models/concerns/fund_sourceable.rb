module FundSourceable
  extend ActiveSupport::Concern

  included do
    attr_accessor :fund_source
    before_validation :set_fund_source_attributes, on: :create
    validates :fund_source, presence: true, on: :create
    validates :fund_extra, :fund_uid, presence: true, on: :create

  end

  def set_fund_source_attributes
     fs = FundSource.find_by_id(fund_source)
     if fund_extra.nil? && fund_uid.nil? && fs
      self.fund_extra = fs.extra
      self.fund_uid = fs.uid.strip
     end
  end
end
