module UsesguidMigrations
  module ActiveRecordExtensions
    module Schema
  
      def self.included( base )
        base.extend( ClassMethods )
      end

      module ClassMethods
        def self.extended( base )
          class << base
            attr_accessor :defining
            alias :defining? :defining

            alias_method_chain :define, :lfe_usesguid_migrations
          end
        end

        def define_with_lfe_usesguid_migrations( info={}, &block )
          self.defining = true
          define_without_lfe_usesguid_migrations( info, &block )
        ensure
          self.defining = false
        end
      end
  
    end
  end
end