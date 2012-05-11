class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.string :username
      t.string :password
      t.integer :list

      t.timestamps
    end
    
    add_index :lists, :name
  end
end
