module Lfe::Usesguid::Migrations::ActiveRecord::ConnectionAdapters
  
  module TableDefinition
    def self.included( base )
      base.class_eval do
        include InstanceMethods
        attr_accessor :primary_key_name
        attr_accessor :associative_keys
        #alias_method_chain :initialize, :redhillonrails_core
        #alias_method_chain :to_sql, :lfe_usesguid_migrations
      end
    end
    
    #def to_sql_with_lfe_usesguid_migrations
    #  sql = to_sql_without_lfe_usesguid_migrations
    #  sql
    #end

    module InstanceMethods
      def guid_primary_key( name )
        @primary_key_name = name
        column( name, :binary, :limit => 22, :null => false )
      end

      def references_with_guid( name, options={} )
        name = name.to_s
        name = "#{name}_id" unless name.end_with?( "_id" )
        guid( name, options )
      end
      
      def guid( name, options={} )
        @associative_keys = [] if @associative_keys.nil?
        options.merge!( :limit => 22 )
        options.merge!( :null => false ) unless options[:null]
        @associative_keys << OpenStruct.new( :name => name, :options => options )
        column( name, :binary, options )
      end
    end
  end
  
end