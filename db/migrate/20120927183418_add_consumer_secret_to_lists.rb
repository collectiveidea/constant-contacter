class AddConsumerSecretToLists < ActiveRecord::Migration
  def change
    add_column :lists, :consumer_secret, :string
  end
end
