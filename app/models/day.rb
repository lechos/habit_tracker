class Day < ActiveRecord::Base
  belongs_to :habit

  validates :position, numericality: { only_integer: true }
  
end