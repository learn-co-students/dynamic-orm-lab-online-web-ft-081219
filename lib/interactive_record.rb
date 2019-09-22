require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
    
    table_info = DB[:conn].execute("pragma table_info('#{table_name}')")
    
    table_info.map do |row|
      row["name"]
    end.compact
  end
  
  def initialize(properties={})
    properties.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
    #formats col names
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(attribute_hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys[0].to_s} = '#{attribute_hash.values[0].to_s}'"

    DB[:conn].execute(sql)
  end
  
end