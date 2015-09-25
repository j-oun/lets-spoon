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
   
    uri = URI.parse("http://api.bigoven.com/recipes?title_kw=#{keyword}&pg=1&rpp=20&api_key=#{API_KEY}")

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
          recipe_hash = Hash.from_xml(recipe_response)

          recipe = Recipe.create!(construct_recipe(recipe_hash))

          # creating ingredients and recipe_ingredients
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

              id = nil
              if ingredient_duplicate
                id = ingredient_duplicate.id
              else
                ingredient = Ingredient.create!(:name => name) 
                id = ingredient.id
              end             

              recipe_ingredients_hash = {:recipe_id => recipe.id, :ingredient_id => id,:quantity => quantity, :unit => unit}

              RecipeIngredient.transaction do 
                RecipeIngredient.create!(recipe_ingredients_hash)
              end

            end           
          end
          # after this, add more banned_ingredients based from the diet's list of initial banned ingredients
          # grab name from ingr where ing.id = banned.id
            
          vegetarian_array = ['meat','steak','beef','chicken','poultry','fish','salmon','trout','tuna','turkey','lamb','pork','bacon']
          Ingredient.all.each do |ingredient|
            # select id from ingredients where name = grabbed name
            vegetarian_array.each do |element|

            BannedIngredient.create!(diet_id: 1,ingredient_id: ingredient.id) if ingredient.name.downcase.match(/.*#{element}.*/)
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
