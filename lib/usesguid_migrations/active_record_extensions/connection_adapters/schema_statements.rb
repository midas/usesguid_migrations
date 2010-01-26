module UsesguidMigrations::ActiveRecordExtensions::ConnectionAdapters
  module SchemaStatements

    def self.included( base )
      base.module_eval do
        alias_method_chain :create_table, :lfe_usesguid_migrations
        alias_method_chain :add_column, :lfe_usesguid_migrations
      end
    end

    def create_table_with_lfe_usesguid_migrations( table_name, options={} )
      table_definition = ActiveRecord::ConnectionAdapters::TableDefinition.new( self )

      if options[:guid] == false
        table_definition.primary_key( options[:primary_key] || ActiveRecord::Base.get_primary_key( table_name ) ) unless options[:id] == false
      else
        table_definition.guid_primary_key( options[:primary_key] || ActiveRecord::Base.get_primary_key( table_name ) ) unless options[:id] == false
      end

      yield table_definition

      drop_table( table_name, options ) if options[:force] && table_exists?( table_name )
      usesguid_create_table( table_name, table_definition, options )
    end

    def add_column_with_lfe_usesguid_migrations( table_name, column_name, type, options={} )
      return add_column_without_lfe_usesguid_migrations( table_name, column_name, type, options ) unless %w(guid guid_fk).include?( type.to_s )
      
      column_name = (type.to_s == 'guid_fk' && column_name) ? "#{column_name}_id" : column_name
      uses_guid_add_column( table_name, column_name, type, options )
    end
  end
end