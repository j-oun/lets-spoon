helpers do
  def current_user
    @user = User.find(1) 
  end
end

before do
  current_user
end

get '/' do
  erb :index
end

get '/users/:id' do
  erb :'users/user'
end

get '/search' do
  @search_term = params[:search_term]
  diet = @user.diet_id
  @recipes = Recipe.find_by_sql(
    "SELECT *
      FROM recipes 
      JOIN recipe_ingredients 
        ON recipes.id = recipe_ingredients.recipe_id
      JOIN ingredients
        ON recipe_ingredients.ingredient_id = ingredients.id
      WHERE (
        recipes.name LIKE '%#{@search_term}%'
        OR recipes.description LIKE '%#{@search_term}%'  
        OR ingredients.name LIKE '%#{@search_term}%' 
      )  
      AND recipes.id NOT IN (
        SELECT recipes.id 
        FROM recipes 
        JOIN recipe_ingredients 
          ON recipes.id = recipe_ingredients.recipe_id
        WHERE recipe_ingredients.ingredient_id IN ( 
          SELECT ingredient_id 
          FROM banned_ingredients 
          JOIN diets ON banned_ingredients.diet_id = diets.id
          WHERE diets.id = 4
    )
  )
  
  GROUP BY recipes.id;")

#{@search_term}
  # byebug

  erb :'search/results'
end

get '/recipes/:id' do
  @recipe = Recipe.find(params[:id])

  @instructions = @recipe.instructions.split('. ')
  erb :'recipes/recipe'
end 

