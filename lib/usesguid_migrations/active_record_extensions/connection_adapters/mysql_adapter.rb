module UsesguidMigrations::ActiveRecordExtensions::ConnectionAdapters
  module MysqlAdapter

    def primary_key_name( table_name, name=nil )
      results = execute( "SHOW CREATE TABLE `#{table_name}`", name )
      keys = []
      primary_key = nil

      results.each do |row|
        row[1].each do |line|
          keys << $1 if line =~ /^  [`"](.+?)[`"] varchar\(22\) character set latin1 collate latin1_bin NOT NULL?,?$/
          primary_key = $1 if line =~ /^  PRIMARY KEY  \([`"](.+?)[`"]\)$/
          primary_key = $1 if line =~ /^  PRIMARY KEY  \([`"](.+?)[`"]\),$/
          primary_key = $1 if line =~ /^  PRIMARY KEY  \([`"](.+?)[`"]\), $/
        end
      end

      return keys.include?( primary_key ) ? primary_key : nil
    end

    def foreign_keys( table_name, name=nil )
      results = execute( "SHOW CREATE TABLE `#{table_name}`", name )

      null_foreign_keys = []
      not_null_foreign_keys = []
      primary_keys = []

      results.each do |row|
        row[1].each do |line|
          null_foreign_keys << $1 if line =~ /^  [`"](.+?)[`"] varchar\(22\) character set latin1 collate latin1_bin default NULL?,?$/
          not_null_foreign_keys << $1 if line =~ /^  [`"](.+?)[`"] varchar\(22\) character set latin1 collate latin1_bin NOT NULL?,?$/
          primary_keys << $1 if line =~ /^  PRIMARY KEY  \([`"](.+?)[`"]\)$/
          primary_keys << $1 if line =~ /^  PRIMARY KEY  \([`"](.+?)[`"]\),$/
        end
      end

      return null_foreign_keys - primary_keys, not_null_foreign_keys - primary_keys
    end

    def usesguid_create_table( table_name, table_definition, options )
      execute usesuid_create_table_statement( table_name, table_definition, options )

      unless table_name == "schema_migrations"
        unless options[:id] == false || options[:guid] == false
          execute usesguid_alter_column_statement( table_name, table_definition.primary_key_name, :null => false )
          execute usesguid_make_column_primary_key( table_name, table_definition.primary_key_name )
        end

        return if table_definition.associative_keys.nil?

        table_definition.associative_keys.each do |assoc|
          execute usesguid_alter_column_statement( table_name, assoc.name, assoc.options )
        end
      end
    end

    def uses_guid_add_column( table_name, column_name, type, options={} )
      column = ActiveRecord::ConnectionAdapters::ColumnDefinition.new( self, column_name, :string )
      if options[:limit]
        column.limit = options[:limit]
        #elsif native[type.to_sym].is_a?( Hash )
        #  column.limit = native[type.to_sym][:limit]
      end
      column.precision = options[:precision]
      column.scale = options[:scale]
      column.default = options[:default]
      column.null = options[:null]

      execute usesguid_add_column_statement( table_name, column )
    end

    def usesuid_create_table_statement( table_name, table_definition, options )
      create_sql = "CREATE#{' TEMPORARY' if options[:temporary]} TABLE "
      create_sql << "#{quote_table_name( table_name )} ("
      create_sql << table_definition.to_sql
      create_sql << ") #{options[:options]}"
      create_sql
    end

    def usesguid_alter_column_statement( table_name, pk_name, options={} )
      "ALTER TABLE `#{table_name}` MODIFY COLUMN `#{pk_name}` VARCHAR(#{options[:limit] || 22}) BINARY CHARACTER SET latin1 COLLATE latin1_bin#{options[:null] == true ? '' : ' NOT NULL'};"
    end

    def usesguid_make_column_primary_key( table_name, pk_name )
      "ALTER TABLE `#{table_name}` ADD PRIMARY KEY (#{pk_name})"
    end

    def usesguid_add_column_statement( table_name, column_def )
      "ALTER TABLE #{quote_table_name( table_name )} ADD #{quote_column_name( column_def.name )} VARCHAR(#{column_def.limit || 22}) BINARY CHARACTER SET latin1 COLLATE latin1_bin"
    end

  end
end