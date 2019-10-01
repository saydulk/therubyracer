
/*고객별 코인별 잔고 */

select a.member_id, c.email,  concat( b.coincd , '/', a.currency) as coin ,  a.balance 
 from accounts a, core_currency b , members c 
where a.member_id =  c.id 
 and a.currency = b.id 
 order by a.member_id asc, b.id asc 
 
 

 
 
 /* 입금테이블 */
 
 
 select a.member_id, b.email, c.coincd, a.amount, a.fee, a.fund_uid, a.fund_extra, a.txid , 
 a.aasm_state , a.created_at, a.updated_at , a.confirmations,  a.type, a.address 
 from deposits a, members b, core_currency c
where a.member_id = b.id 
and a.currency  = c.id  order by a.member_id asc, c.coincd asc  limit 0, 500 



/* 주문 */

select    a.member_id,b.email,a.bid,  a.ask, concat(c.coincd, '/',a.currency) coin , a.price, a.volume, a.origin_volume, a.state, a.done_at, a.type,
 a.created_at, a.locked, a.origin_locked, a.funds_received, 
 a.trades_count , a.is_locked 
 from orders a, members b , core_currency c where a.member_id = b.id and a.currency = c.id 
 order by a.member_id asc ,a.currency asc limit 0, 3000 
 
 

 
 /* 출금 */
 withdraws
 
 transfers 
 
 
 AWS
ID: dev.cccubes@gmail.com
PW: dev.ccc12#$  PW: dev.ccc12#$  ==>ccc12#$.dev99  ==>     ##skawldnjs2019$%^& 

 ================================================  https://cccubes-stage.com
 



============CAC 상장 ==========
AOK의 경우 거래소 개인지갑으로 들어오면 0x6ebe2119908ce3c169ba64460663d74d8a0033a2
로 모아야 되는데 0x1929768c55Da174C8E14838a12229392a663875d 로 모으라고 입력된거 같음. 
뒤에것은 지갑주소가 아니고 엉뚱안 스마트컨트랙트 주소임. 다행히 컨트랙트 주소로 입력되어 있어 코인이 실제 전송되지 않음







============== mq 데몬 https://github.com/peatio/peatio/tree/master/lib/daemons ===========

  stage 서버 http://13.251.125.85:15672/

 




=================cac+ ======================
CAC+컨텍트주소 
0xB1C543a83597dA11bF07dB1Cb3Ec5AAcA11197Fb
CAC+컨텍트주소?
0xB1C543a83597dA11bF07dB1Cb3Ec5AAcA11197Fb 





  






 
 