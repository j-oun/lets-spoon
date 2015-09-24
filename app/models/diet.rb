class Diet < ActiveRecord::Base

  has_many :users
  has_many :banned_ingredients
  has_many :ingredients, through: :banned_ingredients

end