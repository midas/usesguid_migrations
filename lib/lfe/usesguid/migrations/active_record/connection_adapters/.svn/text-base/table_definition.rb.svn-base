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

      def associated( name )
        name = name.to_s
        name = "#{name}_id" unless name.end_with?( "_id" )
        @associative_keys = [] if @associative_keys.nil?
        @associative_keys << name
        column( name, :binary, :limit => 22, :null => false )
      end
    end
  end
  
end