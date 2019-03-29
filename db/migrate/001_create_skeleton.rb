migration_class = ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration

class CreateSkeleton < migration_class
  def change
    create_table :skeleton do |t|
      t.string   :example,               :null => false
    end
  end
end
