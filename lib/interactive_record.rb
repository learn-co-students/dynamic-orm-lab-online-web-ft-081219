require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
   def self.table_name
      self.to_s.downcase.pluralize
   end

   def self.column_names
      #DB[:conn].results_as_hash=true
      sql="PRAGMA table_info('#{table_name}')"
      table_info=DB[:conn].execute(sql)
      column_names=[]
      table_info.each {|col|column_names << col["name"]}
      column_names.compact
   end

   def table_name_for_insert
      self.class.table_name
   end

   def col_names_for_insert
      self.class.column_names.delete_if{|i|i=="id"}.join(", ")
   end

   def values_for_insert
      holder=[]
      self.class.column_names.each do |a|
         holder << "'#{send(a)}'" unless send(a).nil?
      end
      holder.join(", ")
   end

   def save
      unless self.id != nil
         sql="INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
         DB[:conn].execute(sql)
         @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
      end
   end

   def self.find_by_name(name)
      DB[:conn].execute("SELECT * FROM #{table_name} WHERE name=?",name)
   end

   def self.find_by(options={})
      holder=[]
      options.each do |key,value|
         holder << key.to_s
         holder << value
      end
      #binding.pry
      DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{holder[0]}=?", holder[1])
   end

end