class FileUploader < CarrierWave::Uploader::Base
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def content_type_whitelist
    ['image',"text/plain", "text/csv", "application/csv", "application/vnd.ms-excel", "application/msword", "application/vnd.ms-office", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/zip", "application/xls", "application/octet-stream", "application/CDFV2-unknown; charset=binary","application/x-ole-storage", "text/comma-separated-values"]
  end

  def extension_white_list
    %w(jpg jpeg gif png pdf)
  end

  def content_type_blacklist
    %w(zip tar.gz)
  end

  def size_range
    1..2.megabytes
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
