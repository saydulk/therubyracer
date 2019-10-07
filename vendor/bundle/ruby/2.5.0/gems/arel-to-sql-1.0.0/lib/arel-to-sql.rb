# encoding: UTF-8
# frozen_string_literal: true

module ArelToSQL
  module TableExtension
    def to_sql(engine = nil)
      engine ||= respond_to?(:engine) ? self.engine : Arel::Table.engine
      engine.connection.quote_table_name(table_name)
    end

    alias to_s to_sql
  end

  module AttributeExtension
    def to_sql(engine = nil)
      return name if Arel::Nodes::SqlLiteral === name

      engine ||= relation.respond_to?(:engine) ? relation.engine : Arel::Table.engine

      engine.connection.quote_table_name(relation.table_alias || relation.table_name) +
      '.' +
      engine.connection.quote_column_name(name)
    end

    alias to_s to_sql
  end
end

require 'arel'

Arel::Attributes::Attribute.include ArelToSQL::AttributeExtension
Arel::Table.include ArelToSQL::TableExtension
