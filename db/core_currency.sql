CREATE TABLE `core_currency` (
  `id`  int(3)  NOT NULL,
  `coincd` varchar(20) DEFAULT NULL,
  `coinnm` varchar(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



/*코인명 저장 테이블 추가 , 기존 파일에 정의되어 불편해서 추가함 */



insert into core_currency ( id, coincd )  values ( 1, 'BTC' );
insert into core_currency ( id, coincd )  values ( 2, 'BCH' );
insert into core_currency ( id, coincd )  values ( 3, 'ETH' );
insert into core_currency ( id, coincd )  values ( 4, 'CSC' );
insert into core_currency ( id, coincd )  values ( 5, 'XRP' );
insert into core_currency ( id, coincd )  values ( 6, 'TRON' );
insert into core_currency ( id, coincd )  values ( 7, 'IMPEREUM' );
insert into core_currency ( id, coincd )  values ( 8, 'EMS' );
insert into core_currency ( id, coincd )  values ( 9, 'ECPPLUS' );
insert into core_currency ( id, coincd )  values ( 10, 'USDCOIN' );
insert into core_currency ( id, coincd )  values ( 11, 'AOKEY7' );
insert into core_currency ( id, coincd )  values ( 12, 'CAC' );