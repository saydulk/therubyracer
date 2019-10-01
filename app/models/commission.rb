class Commission < ActiveRecord::Base
  include Withdrawable

  STATES = %i[submitted canceled rejected accepted].freeze
  validates_presence_of :wallet_address, :receipent_address

  def audit_transfer!
    puts"============ commission audit_transfer!======="
    super
    AMQPQueue.enqueue(:commission_collection, { commission_id: id }, { persistent: true }) if processing?
    puts"=========finish=="
  end

end
