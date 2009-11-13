module Lfe::Usesguid::Migrations::ActiveRecord::ConnectionAdapters
  module SchemaStatements
    def self.included( base )
      base.module_eval do
        alias_method_chain :create_table, :lfe_usesguid_migrations
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

      if options[:force] && table_exists?( table_name )
        drop_table( table_name, options )
      end

      create_sql = "CREATE#{' TEMPORARY' if options[:temporary]} TABLE "
      create_sql << "#{quote_table_name( table_name )} ("
      create_sql << table_definition.to_sql
      create_sql << ") #{options[:options]}"
      execute create_sql

      # TODO this needs to be different for each adapter
      unless table_name == "schema_migrations"
        unless options[:id] == false || options[:guid] == false
          execute "ALTER TABLE `#{table_name}` MODIFY COLUMN `#{table_definition.primary_key_name}` VARCHAR(22) BINARY CHARACTER SET latin1 COLLATE latin1_bin NOT NULL;"
          execute "ALTER TABLE `#{table_name}` ADD PRIMARY KEY (#{table_definition.primary_key_name})"
        end

        return if table_definition.associative_keys.nil?

        table_definition.associative_keys.each do |assoc|
          key = assoc.name
          opts = assoc.options
          sql = "ALTER TABLE `#{table_name}` MODIFY COLUMN `#{key}` VARCHAR(#{opts[:limit] || 22}) BINARY CHARACTER SET latin1 COLLATE latin1_bin"
          if opts[:null] == false || opts[:null].nil?
            sql << " NOT NULL;"
          else
            sql << ";"
          end
          execute( sql )
        end
      end
    end
  end
end