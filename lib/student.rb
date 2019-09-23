require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord 
  
 self.column_names.each do |attributes| 
   attr_accessor attributes.to_sym
 end 
 
 def initialize(options = {})  
   options.each do |key,val| 
     self.send("#{key}=", val)
   end
 end

end
