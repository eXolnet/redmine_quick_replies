migration_class = ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration

class CreateReplies < migration_class
  def change
    create_table :replies do |t|
      t.column :user_id, :integer,     :null => false
      t.string :name,                  :null => false
      t.column :body, :text
    end
  end
end
