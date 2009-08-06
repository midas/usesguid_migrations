module Lfe::Usesguid::Migrations::ActiveRecord
  module SchemaDumper
    def self.included( base )
      base.class_eval do
        private
        alias_method_chain :table, :lfe_usesguid_migrations
        alias_method_chain :indexes, :lfe_usesguid_migrations
      end
    end

    private

    def table_with_lfe_usesguid_migrations( table, stream )
      #table_without_lfe_usesguid_migrations( table, stream )
      columns = @connection.columns(table)
      begin
        tbl = StringIO.new

        guid_pk = @connection.primary_key_name( table )
        guid_fks = @connection.foreign_keys( table )

        if @connection.respond_to?(:pk_and_sequence_for)
          pk, pk_seq = @connection.pk_and_sequence_for(table)
        end
        pk ||= 'id'

        tbl.print "  create_table #{table.inspect}"
        if columns.detect { |c| c.name == pk }
          if pk != 'id'
            tbl.print %Q(, :primary_key => "#{pk}")
          end
        else
          tbl.print ", :id => false"
        end
        tbl.print ", :force => true"
        tbl.puts " do |t|"

        column_specs = columns.map do |column|
          raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" if @types[column.type].nil?
          next if column.name == pk
          #if column.name == pk
          #  unless guid_pk.nil? || guid_pk.empty?
              
          #  end
          #end
          spec = {}
          spec[:name]      = column.name.inspect
          spec[:type]      = column.type.to_s
          spec[:limit]     = column.limit.inspect if column.limit != @types[column.type][:limit] && column.type != :decimal
          spec[:precision] = column.precision.inspect if !column.precision.nil?
          spec[:scale]     = column.scale.inspect if !column.scale.nil?
          spec[:null]      = 'false' if !column.null
          spec[:default]   = default_string(column.default) if column.has_default?
          (spec.keys - [:name, :type]).each{ |k| spec[k].insert(0, "#{k.inspect} => ")}
          spec
        end.compact

        unless guid_pk.nil? || guid_pk.empty?
          column_specs.insert( 0, { :name => "\"#{guid_pk}\"", :type => 'binary', :limit => ':limit => 22', :null => ':null => false' } )
        end

        #unless guid_fks.nil? || guid_fks.empty?
        #  guid_fks.each do |fk|
            
        #  end
        #end

        # find all migration keys used in this table
        keys = [:name, :limit, :precision, :scale, :default, :null] & column_specs.map(&:keys).flatten

        # figure out the lengths for each column based on above keys
        lengths = keys.map{ |key| column_specs.map{ |spec| spec[key] ? spec[key].length + 2 : 0 }.max }

        # the string we're going to sprintf our values against, with standardized column widths
        format_string = lengths.map{ |len| "%-#{len}s" }

        # find the max length for the 'type' column, which is special
        type_length = column_specs.map{ |column| column[:type].length }.max

        # add column type definition to our format string
        format_string.unshift "    t.%-#{type_length}s "

        format_string *= ''

        column_specs.each do |colspec|
          values = keys.zip(lengths).map{ |key, len| colspec.key?(key) ? colspec[key] + ", " : " " * len }
          values.unshift colspec[:type]
          tbl.print((format_string % values).gsub(/,\s*$/, ''))
          tbl.puts
        end

        tbl.puts "  end"
        tbl.puts

        indexes(table, tbl)

        tbl.rewind
        stream.print tbl.read
      rescue => e
        stream.puts "# Could not dump table #{table.inspect} because of following #{e.class}"
        stream.puts "#   #{e.message}"
        stream.puts
      end

      stream
    end

    def indexes_with_lfe_usesguid_migrations( table, stream)
      indexes_without_lfe_usesguid_migrations( table, stream)
      pk = @connection.primary_key_name( table )
      foreign_keys = @connection.foreign_keys( table )

      stream.puts "  execute \"ALTER TABLE `#{table}` MODIFY COLUMN `#{pk}` VARCHAR(22) BINARY CHARACTER SET latin1 COLLATE latin1_bin NOT NULL;\""
      stream.puts "  execute \"ALTER TABLE `#{table}` ADD PRIMARY KEY (#{pk})\""
      stream.puts if foreign_keys.nil? || foreign_keys.empty?

      foreign_keys.each do |key|
        stream.puts "  execute \"ALTER TABLE `#{table}` MODIFY COLUMN `#{key}` VARCHAR(22) BINARY CHARACTER SET latin1 COLLATE latin1_bin NOT NULL;\""
      end

      stream.puts unless foreign_keys.nil? || foreign_keys.empty?
    end
  end
end