class RecipesImporter

  API_KEY = "4ZmjE50zOoqJ3YCG1na137DS3o4s92zU"

  def initialize
   
  end

  
  def construct_recipe(session)
    recipe = Hash.new
    recipe[:name] = session["Recipe"]["Title"]
    recipe[:description] = session["Recipe"]["Description"]
    recipe[:instructions] = session["Recipe"]["Instructions"]
    recipe[:image_url] = session["Recipe"]["ImageURL"]
    recipe
  end

  def add_banned_ingredients(current_ingredient)
    # after this, add more banned_ingredients based from the diet's list of initial banned ingredients
    pescatarian_array = ['meat','steak','beef','chicken','poultry','turkey','lamb','pork','bacon']
    vegetarian_array = pescatarian_array + ['fish','salmon','trout','tuna'] 
    vegan_array = vegetarian_array + ['eggs','cheese','milk','yogurt','cream','honey']
    gluten_free_array = ['flour','wheat','rye','barley','bulgur','bulghu','couscous','cous','kamut','semolina','pelt']
    
    diet_array = [vegetarian_array,pescatarian_array,vegan_array,gluten_free_array]
    

    Ingredient.all.each do |ingredient|
      diet_array.each_with_index do |diet,diet_index|
        diet.each do |element|
          BannedIngredient.create!(diet_id: diet_index+1,ingredient_id: current_ingredient.id) if current_ingredient.name.downcase.match(/.*#{element}.*/)
        end
      end
    end
  end

  def import(keyword)
   
    uri = URI.parse("http://api.bigoven.com/recipes?any_kw=#{keyword}&pg=1&rpp=50&api_key=#{API_KEY}")

    response = Net::HTTP.get(uri)

    session = Hash.from_xml(response)
    recipe_array = []
    session["RecipeSearchResult"]["Results"]["RecipeInfo"].each{|recipe| recipe_array << recipe["RecipeID"]}
    
    recipe_array.each do |recipe_entry|
      recipe_failure_count = 0
      
      url = URI.parse("http://api.bigoven.com/recipe/" + recipe_entry + "?api_key=#{API_KEY}")
      recipe_response = Net::HTTP.get(url)
      recipe_hash = Hash.from_xml(recipe_response)
      
      # check if a recipe has a list of ingredients
      next if recipe_hash["Recipe"]["Ingredients"].nil?

      Recipe.transaction do
        begin
          recipe = Recipe.create!(construct_recipe(recipe_hash))
          
          ingredient_hash = recipe_hash["Recipe"]["Ingredients"]["Ingredient"]
          
          ingredient_hash.each do |ingredient_entry|
            Ingredient.transaction do
              begin
                name = ingredient_entry["Name"]  
                unit = ingredient_entry["Unit"]
                quantity = ingredient_entry["Quantity"]
              rescue TypeError
                puts "Insufficient values for ingredients"
                next
              end
              
              ingredient_duplicate = Ingredient.find_by name: name

              recipe_ingredients_hash = Hash.new
              ingredient = nil
              id = nil
              if ingredient_duplicate
                ingredient = ingredient_duplicate
                id = ingredient_duplicate.id
              else
                ingredient = Ingredient.create!(:name => name) 
                id = ingredient.id
              end             

              recipe_ingredients_hash = {:recipe_id => recipe.id, :ingredient_id => id,:quantity => quantity, :unit => unit}

              RecipeIngredient.transaction do 
                RecipeIngredient.create!(recipe_ingredients_hash)
              end
              add_banned_ingredients(ingredient)
            end           
          end
          
          

          print '.'
        rescue ActiveRecord::UnknownAttributeError
          recipe_failure_count += 1
          print '!'
        ensure
          STDOUT.flush      
        end
      end
      failures = recipe_failure_count > 0 ? "(failed to create #{recipe_failure_count} recipe records)" : ''
      puts "\nDONE #{failures}\n\n"
    end
  end
end
