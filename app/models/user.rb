class User < ActiveRecord::Base

  has_many :user_diets
  has_many :saved_recipes
  has_many :recipes, through: :saved_recipes
end