migration_class = ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration

class AddIsPublicToRepliesTable < migration_class
    def self.up
      add_column :replies, :is_public, :boolean, :default => false, :null => false
    end
  
    def self.down
      remove_column :replies, :is_public
    end
  end
  