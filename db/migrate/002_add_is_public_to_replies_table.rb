class AddIsPublicToRepliesTable < ActiveRecord::Migration
    def self.up
      add_column :replies, :is_public, :boolean, :default => false, :null => false
    end
  
    def self.down
      remove_column :replies, :is_public
    end
  end
  