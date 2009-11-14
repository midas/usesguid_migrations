module UsesguidMigrations
  module ActiveRecordExtensions
    module ConnectionAdapters
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
      
      end
    end
  end
end