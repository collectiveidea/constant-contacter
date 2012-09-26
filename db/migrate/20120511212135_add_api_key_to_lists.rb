class AddApiKeyToLists < ActiveRecord::Migration
  def change
    add_column :lists, :api_key, :string
  end
end
