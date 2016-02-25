class AddPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :habits, :password, :string
  end
end
