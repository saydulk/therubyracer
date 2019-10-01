class AirdropHistory < ActiveRecord::Base
  belongs_to :withdraw
  belongs_to :airdrop_file
end
