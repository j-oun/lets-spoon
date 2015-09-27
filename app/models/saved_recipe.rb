class SavedRecipe < ActiveRecord::Base
  belongs_to :diet
  belongs_to :ingredient
end