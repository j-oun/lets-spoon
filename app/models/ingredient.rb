class Ingredient < ActiveRecord::Base
  has_many :recipe_ingredients 
  has_many :recipes, through: :recipe_ingredients

  has_many :banned_ingredients
  has_many :diets, through: :banned_ingredients
end