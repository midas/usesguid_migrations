require 'lfe/usesguid/migrations/active_record/base'
require 'lfe/usesguid/migrations/active_record/schema'
require 'lfe/usesguid/migrations/active_record/schema_dumper'
require 'lfe/usesguid/migrations/active_record/connection_adapters/mysql_adapter'
require 'lfe/usesguid/migrations/active_record/connection_adapters/schema_statements'
require 'lfe/usesguid/migrations/active_record/connection_adapters/table_definition'

ActiveRecord::Base.send( :include, Lfe::Usesguid::Migrations::ActiveRecord::Base ) if defined?( ActiveRecord::Base )
ActiveRecord::Schema.send( :include, Lfe::Usesguid::Migrations::ActiveRecord::Schema ) if defined?( ActiveRecord::Schema )
ActiveRecord::SchemaDumper.send( :include, Lfe::Usesguid::Migrations::ActiveRecord::SchemaDumper ) if defined?( ActiveRecord::SchemaDumper )
ActiveRecord::ConnectionAdapters::SchemaStatements.send( :include, Lfe::Usesguid::Migrations::ActiveRecord::ConnectionAdapters::SchemaStatements ) if defined?( ActiveRecord::ConnectionAdapters::SchemaStatements )
ActiveRecord::ConnectionAdapters::TableDefinition.send( :include, Lfe::Usesguid::Migrations::ActiveRecord::ConnectionAdapters::TableDefinition ) if defined?( ActiveRecord::ConnectionAdapters::TableDefinition )
if defined?( ActiveRecord::ConnectionAdapters::MysqlAdapter )
  ActiveRecord::ConnectionAdapters::MysqlAdapter.send( :include, Lfe::Usesguid::Migrations::ActiveRecord::ConnectionAdapters::MysqlAdapter )
end