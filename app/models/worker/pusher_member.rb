module Worker
  class PusherMember

    def process(payload, metadata, delivery_info)
      return unless member = Member.find_by_id(payload['member_id'])
      event  = payload['event']
      data   = JSON.parse payload['data']
      member.notify(event, data) if member
    end

  end
end
