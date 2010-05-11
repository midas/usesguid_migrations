module UsesguidMigrations::ActiveRecordExtensions::ConnectionAdapters
  module SqliteAdapter

    def usesguid_create_table( table_name, table_definition, options )
      begin
        sql = usesuid_create_table_statement( table_name, table_definition, options )
        sql.sub!( '"id" blob(22) NOT NULL', '"id" blob(22) PRIMARY KEY NOT NULL' )
        execute( sql )
      rescue SQLite3::MisuseException; end

      unless table_name == "schema_migrations"
        unless options[:id] == false || options[:guid] == false
          sql = usesguid_alter_column_statement( table_name, table_definition.primary_key_name, :null => false )
          execute( sql ) unless sql.nil? || sql.empty?
          sql = usesguid_make_column_primary_key( table_name, table_definition.primary_key_name )
          execute( sql ) unless sql.nil? || sql.empty?
        end

        return if table_definition.associative_keys.nil?

        table_definition.associative_keys.each do |assoc|
          begin
            sql = usesguid_alter_column_statement( table_name, assoc.name, assoc.options )
            execute( sql ) unless sql.nil? || sql.empty?
          rescue SQLite3::MisuseException; end
        end
      end
    end

    def uses_guid_add_column( table_name, column_name, type, options={} )
      column = ActiveRecord::ConnectionAdapters::ColumnDefinition.new( self, column_name, :text )
      if options[:limit]
        column.limit = options[:limit]
        #elsif native[type.to_sym].is_a?( Hash )
        #  column.limit = native[type.to_sym][:limit]
      end
      column.precision = options[:precision]
      column.scale = options[:scale]
      column.default = options[:default]
      column.null = options[:null]

      add_column_sql = usesguid_add_column_statement( table_name, column )

      begin
        execute( add_column_sql )
      rescue SQLite3::MisuseException; end
    end

    def usesuid_create_table_statement( table_name, table_definition, options )
      create_sql = "CREATE#{' TEMPORARY' if options[:temporary]} TABLE "
      create_sql << "#{quote_table_name( table_name )} ("
      create_sql << table_definition.to_sql
      create_sql << ") #{options[:options]}"
      create_sql
    end

    def usesguid_alter_column_statement( table_name, pk_name, options={} )
      ''
    end

    def usesguid_make_column_primary_key( table_name, pk_name )
      ''
    end

    def usesguid_add_column_statement( table_name, column_def )
      "ALTER TABLE #{quote_table_name( table_name )} ADD COLUMN #{column_def.to_sql} DEFAULT('')"
    end

  end
end