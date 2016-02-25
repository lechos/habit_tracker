class CreateUsersHabitsDays < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.timestamps null: false
    end

    create_table :habits do |t|
      t.references :user
      t.date :start_date
      t.timestamps null: false
    end

    create_table :days do |t|
      t.references :habit
      t.integer :position
      t.string :result, default: 0
      t.string :message
      t.timestamps null: false
    end    
  end
end
