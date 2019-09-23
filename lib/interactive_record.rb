require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  
  
  def self.table_name
    self.to_s.downcase.pluralize
  end 
  
  def self.column_names 
    column = []
   info = DB[:conn].execute("PRAGMA table_info(#{self.table_name})") 
   info.each do |key, val| 
      column << key["name"]
   end
   column
  end 
  
  def table_name_for_insert
    self.class.table_name
  end
 
 def col_names_for_insert 
   col_names =  self.class.column_names.delete_if{|col| col == "id"}.join(", ")
 end 
 
 def values_for_insert 
   
  self.col_names_for_insert.split(", ").map do |attribute|
    "\'#{self.send(attribute)}\'"
  end.join(", ")
 
 end
 
 def save 
   DB[:conn].execute("INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})") 
   self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
 end 
 
 def self.find_by_name(name)
  
   DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?",name)
 end
 
 def self.find_by(attribute) 
   key = attribute.keys.first.to_s 
   val = attribute.values.first
 
  DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key} = ?", val)
 end

end