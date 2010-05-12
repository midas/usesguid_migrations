$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
require 'usesguid_migrations/active_record_extensions/base'
require 'usesguid_migrations/active_record_extensions/schema'
require 'usesguid_migrations/active_record_extensions/schema_dumper'
require 'usesguid_migrations/active_record_extensions/connection_adapters/mysql_adapter'
require 'usesguid_migrations/active_record_extensions/connection_adapters/schema_statements'
require 'usesguid_migrations/active_record_extensions/connection_adapters/sqlite_adapter'
require 'usesguid_migrations/active_record_extensions/connection_adapters/table_definition'
  
module UsesguidMigrations
  VERSION = '1.0.2'
end

def windows?
  !(RUBY_PLATFORM =~ /(mingw32|mswin32)/i).nil?
end

ActiveRecord::Base.send( :include, UsesguidMigrations::ActiveRecordExtensions::Base ) if defined?( ActiveRecord::Base )
ActiveRecord::Schema.send( :include, UsesguidMigrations::ActiveRecordExtensions::Schema ) if defined?( ActiveRecord::Schema )
ActiveRecord::SchemaDumper.send( :include, UsesguidMigrations::ActiveRecordExtensions::SchemaDumper ) if defined?( ActiveRecord::SchemaDumper )
if defined?( ActiveRecord::ConnectionAdapters::SchemaStatements )
  ActiveRecord::ConnectionAdapters::SchemaStatements.send( :include, UsesguidMigrations::ActiveRecordExtensions::ConnectionAdapters::SchemaStatements )
end
if defined?( ActiveRecord::ConnectionAdapters::TableDefinition )
  ActiveRecord::ConnectionAdapters::TableDefinition.send( :include, UsesguidMigrations::ActiveRecordExtensions::ConnectionAdapters::TableDefinition )
end
if defined?( ActiveRecord::ConnectionAdapters::MysqlAdapter )
  ActiveRecord::ConnectionAdapters::MysqlAdapter.send( :include, UsesguidMigrations::ActiveRecordExtensions::ConnectionAdapters::MysqlAdapter )
end
if defined?( ActiveRecord::ConnectionAdapters::SQLiteAdapter )
  ActiveRecord::ConnectionAdapters::SQLiteAdapter.send( :include, UsesguidMigrations::ActiveRecordExtensions::ConnectionAdapters::SqliteAdapter )
end

if windows?
  ActiveRecord::ConnectionAdapters::AbstractAdapter.send( :include, UsesguidMigrations::ActiveRecordExtensions::ConnectionAdapters::SqliteAdapter )
end