class BannedIngredient < ActiveRecord::Base
  belongs_to :diets
  belongs_to :ingredient
end