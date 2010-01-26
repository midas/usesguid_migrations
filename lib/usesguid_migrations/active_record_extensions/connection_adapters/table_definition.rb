module UsesguidMigrations::ActiveRecordExtensions::ConnectionAdapters
  module TableDefinition

    def self.included( base )
      base.class_eval do
        include InstanceMethods
        attr_accessor :primary_key_name
        attr_accessor :associative_keys
      end
    end

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
        # make not nullable the default for a guid column as it is likely a foreign key
        options.merge!( :null => false ) unless options[:null] == true
        @associative_keys << OpenStruct.new( :name => name, :options => options )
        column( name, :binary, options )
      end
    end

  end
end