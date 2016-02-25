class Habit < ActiveRecord::Base
  belongs_to :user
  has_many :days

  validates :start_date, presence: true
end