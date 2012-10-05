class AddAuthenticationCodeToLists < ActiveRecord::Migration
  def change
    add_column :lists, :authentication_code, :string
  end
end
