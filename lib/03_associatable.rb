require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'
# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    @class_name.constantize
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {} )
    # ...
    default = {foreign_key: "#{name}_id".to_sym, class_name: "#{name.capitalize}", primary_key: :id}
    # default.each do |k,v|
    #   options[k] ||= v
    # end
    options = default.merge(options)
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    default = {foreign_key: "#{self_class_name.downcase}_id".to_sym, class_name: "#{name.capitalize.singularize}", primary_key: :id}
    default.each do |k,v|
      options[k] ||= v
    end
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    opts = BelongsToOptions.new(name,options)
    define_method("#{name}") do
      data = DBConnection.execute(<<-SQL, self.send(opts.foreign_key))
        SELECT
          #{opts.table_name}.*
        FROM
          #{opts.table_name}
        WHERE
          #{opts.table_name}.#{opts.primary_key} = ?
      SQL
      opts.model_class.parse_all(data).first
    end
  end

  def has_many(name, options = {})
    puts name
    # ...
    # opts = BelongsToOptions.new(name,options)
    # define_method("#{name}") do
    #   data = DBConnection.execute(<<-SQL, self.send(opts.foreign_key))
    #     SELECT
    #       #{opts.table_name}.*
    #     FROM
    #       #{opts.table_name}
    #     WHERE
    #       #{opts.table_name}.#{opts.primary_key} = ?
    #   SQL
    #   opts.model_class.parse_all(data).first
    # end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
