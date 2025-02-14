module CoinRPC
class ETH < BaseRPC
  def handle(name, *args)
    post_body = {"jsonrpc" => "2.0", 'method' => name, 'params' => args, 'id' => '1' }.to_json
    resp = JSON.parse( http_post_request(post_body) )
    raise JSONRPCError, resp['error'] if resp['error']
    result = resp['result']
    result.symbolize_keys! if result.is_a? Hash
    result
  end
  def http_post_request(post_body)
    http    = Net::HTTP.new(@uri.host, @uri.port)
    request = Net::HTTP::Post.new(@uri.request_uri)
    request.basic_auth @uri.user, @uri.password
    request.content_type = 'application/json'
    request.body = post_body
    http.request(request).body
  rescue Errno::ECONNREFUSED => e
    raise ConnectionRefusedError
  end
  def safe_getbalance
    begin
      (open('http://your_server_ip/cgi-bin/total.cgi').read.rstrip.to_f)
    rescue
      'N/A'
    end
  end
  def getnewaddress(account)
    call 'getnewaddress', account
  end
  def settxfee(fee)
    call 'settxfee', fee
  end
  def getbalance
    call 'getbalance'
  end
  def validateaddress(fund_uid)
    call 'validateaddress', fund_uid
  end
  def listtransactions(account, number)
    call 'listtransactions', account, number
  end
  def gettransaction(txid)
    call 'gettransaction', txid
  end
  def sendtoaddress(fund_uid, amount)
    call 'sendtoaddress', fund_uid, amount
  end

end
end