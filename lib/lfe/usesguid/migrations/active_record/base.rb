module Lfe::Usesguid::Migrations::ActiveRecord
  module Base
    
    def self.included( base )
      base.extend( ClassMethods )
    end

    module ClassMethods
      def self.extended( base )
        class << base
          #alias_method_chain :columns, :redhillonrails_core
          alias_method_chain :abstract_class?, :lfe_usesguid_migrations
        end
      end
      
      def abstract_class_with_lfe_usesguid_migrations?
         abstract_class_without_lfe_usesguid_migrations? || !(name =~ /^Abstract/).nil?
       end
      
      def base_class?
        self == base_class
      end
      
      def pluralized_table_name( table_name )
        ActiveRecord::Base.pluralize_table_names ? table_name.to_s.pluralize : table_name
      end
    end
    
  end
end