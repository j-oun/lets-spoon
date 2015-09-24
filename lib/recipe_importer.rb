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

  def import(keyword)
    # keyword is used to populate recipes and ingredients associated from the keyword 
   
    uri = URI.parse("http://api.bigoven.com/recipes?title_kw=#{keyword}&pg=1&rpp=20&api_key=#{API_KEY}")

    # Shortcut
    response = Net::HTTP.get(uri)

    session = Hash.from_xml(response)
    recipe_array = []
    session["RecipeSearchResult"]["Results"]["RecipeInfo"].each{|recipe| recipe_array << recipe["RecipeID"]}
    
    recipe_array.each do |recipe_entry|
      recipe_failure_count = 0
      Recipe.transaction do
        begin
          url = URI.parse("http://api.bigoven.com/recipe/" + recipe_entry + "?api_key=#{API_KEY}")
          recipe_response = Net::HTTP.get(url)
          session = Hash.from_xml(recipe_response)

          recipe = Recipe.create!(construct_recipe(session))

          # creating ingredients and recipe_ingredients
          ingredient_session = session["Recipe"]["Ingredients"]["Ingredient"]
          
          ingredient_session.each do |ingredient_entry|
            Ingredient.transaction do
              begin
                name = ingredient_entry["Name"]  
                unit = ingredient_entry["Unit"]
                quantity = ingredient_entry["Quantity"]
              rescue TypeError
                puts "Insufficient values for ingredients"
                next
              end
                       
              ingredient_hash = {:name => name} 
              
              ingredient_duplicate = Ingredient.find_by name: name

              recipe_ingredients_hash = Hash.new

              if ingredient_duplicate
                id = ingredient_duplicate.id
                recipe_ingredients_hash = {:recipe_id => recipe.id, :ingredient_id => id,:quantity => quantity, :unit => unit}
              else
                ingredient = Ingredient.create!(ingredient_hash) 
                id = ingredient.id
                recipe_ingredients_hash = {:recipe_id => recipe.id, :ingredient_id => id,:quantity => quantity, :unit => unit}    
              end             
              
              RecipeIngredient.transaction do 
                RecipeIngredient.create!(recipe_ingredients_hash)
              end

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
