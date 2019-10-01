class FiatAttachment < ActiveRecord::Base
  belongs_to :deposit
  mount_uploader :avatar, FileUploader
end
