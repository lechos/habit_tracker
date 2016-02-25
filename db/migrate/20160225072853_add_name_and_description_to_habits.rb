class AddNameAndDescriptionToHabits < ActiveRecord::Migration
  def change
    add_column :habits, :name, :string
    add_column :habits, :description, :string
  end
end
