class CreateSavedRecipes < ActiveRecord::Migration
  def change
    create_table :saved_recipes do |t|
      t.references :recipe
      t.references :user
    end

    change_table :recipes do |t|
      t.references :user
      t.references :saved_recipes
    end

    change_table :users do |t|
      t.references :diet
      t.references :saved_recipes
    end
  end
end
