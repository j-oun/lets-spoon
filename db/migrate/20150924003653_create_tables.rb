class CreateTables < ActiveRecord::Migration
  def change
    
    create_table :recipes do |t|
      t.string :name
      t.text :description
      t.text :instructions
      t.references :recipe_ingredient
      t.string :image_url
      t.timestamps
    end

    create_table :ingredients do |t|
      t.string :name
      t.timestamps
    end

    create_table :recipe_ingredients do |t|
      t.references :recipe
      t.references :ingredient
      t.string :quantity
      t.string :unit
    end

    create_table :banned_ingredients do |t|
      t.references :diet
      t.references :ingredient
      t.timestamps
    end

    create_table :diets do |t|
      t.string :name
      t.references :banned_ingredient
    end

    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password
      t.references :diet
    end
    
  end
end
