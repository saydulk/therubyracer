class Asset < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  mount_uploader :file, FileUploader

  def image?
    file.content_type.start_with?('image') if file?
  end

  validates_integrity_of :file
end

class Asset::IdDocumentFile < Asset
end

class Asset::IdBillFile < Asset
end

class Asset::FileAirdrop < Asset

  def content_type_whitelist
    # %w(text/plain text/comma-separated-values text/csv application/csv application/excel application/vnd.ms-excel application/vnd.msexcel )
    # ["text/plain", "text/csv", "application/csv", "application/vnd.ms-excel", "application/msword", "application/vnd.ms-office", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/zip", "application/xls", "application/octet-stream", "application/CDFV2-unknown; charset=binary","application/x-ole-storage", "text/comma-separated-values"]
    # ['text/csv', 'application/vnd.ms-excel']
    true
  end

  def extension_white_list
    %w(csv)
  end

  def content_type_blacklist
    /image\//
  end

  def image?
    true
  end

end
