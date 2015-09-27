class ModifyDietsTable < ActiveRecord::Migration
  def change
    remove_column :diets, :banned_ingredient_id
    remove_column :users, :diet_id

    create_table :users_diets do |t|
      t.references :diet
      t.references :user
    end
  end
end
