class Diet < ActiveRecord::Base

  has_many :users_diets
  has_many :users, through: :users_diets

  has_many :banned_ingredients
  has_many :ingredients, through: :banned_ingredients

end