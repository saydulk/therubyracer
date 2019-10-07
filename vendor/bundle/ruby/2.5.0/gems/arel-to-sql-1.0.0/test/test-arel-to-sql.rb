# encoding: UTF-8
# frozen_string_literal: true

require 'bundler'
Bundler.require :default, :development, :test

class FakeRecord
  class Connection
    def quote_table_name(name)
      "`#{name}`"
    end

    def quote_column_name(name)
      "`#{name}`"
    end
  end

  class << self
    attr_accessor :connection
  end

  self.connection = Connection.new
end

class ArelToSQLTest < Test::Unit::TestCase
  def test_table_to_sql
    table = Arel::Table.new(:users)
    assert_equal '`users`', table.to_sql
  end

  def test_attribute_to_sql
    table = Arel::Table.new(:users)
    assert_equal '`users`.`name`', table[:name].to_sql
  end

  def setup
    super
    Arel::Table.engine = FakeRecord
  end
end
