## Adds `to_sql` to arel table and attribute.

[![Gem Version](https://badge.fury.io/rb/arel-to-sql.svg)](https://badge.fury.io/rb/arel-to-sql)
[![Build Status](https://travis-ci.org/yivo/arel-to-sql.svg?branch=master)](https://travis-ci.org/yivo/arel-to-sql)

## About
`Arel::Table` and `Àrel::Attributes::Attribute` receive `to_sql` method.

**Example**
```ruby
table = Arel::Table.new(:users)
table.to_sql # => `users`
table[:name].to_sql # => `users`.`name`
````

## Usage
**Before**
```ruby
# Calculate total money paid.
sql = "SELECT SUM(orders.price * (100 - orders.discount) / 100) as total 
       FROM orders 
       INNER JOIN payments ON payments.order_id = orders.id;"
```
**After**
```ruby
# Calculate total money paid.
t_order   = Order.arel_table
t_payment = Payment.arel_table
sql       = "SELECT SUM(#{t_order[:price]} * (100 - #{t_order[:discount]}) / 100) as total 
             FROM #{t_order} 
             INNER JOIN #{t_payment} ON #{t_payment[:order_id]} = #{t_order[:id]};"
```

## Installing gem
Add to your Gemfile:
```ruby
gem 'arel-to-sql', '~> 1.0'
```

## Running Tests
Install bundler:
```bash
gem install bundler
```

Install dependencies:
```bash
cd arel-to-sql && bundle
```

Run tests:
```bash
cd arel-to-sql && appraisal rake test
```
