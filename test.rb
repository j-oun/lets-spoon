require 'active_support/all'

diet = Diet.new(name: "Paleo", banned_ingredient_id: 1)
banned_ingredient = BannedIngredient.new(diet_id: 1, ingredient_id: 1)
ingredient = Ingredient.new(name: "Wheat")

p diet
p banned_ingredient
p ingredient