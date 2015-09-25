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
    "SELECT recipes.name
    FROM recipes 
    JOIN recipe_ingredients 
      ON recipes.id = recipe_ingredients.recipe_id
    JOIN ingredients
      ON recipe_ingredients.ingredient_id = ingredients.id
    WHERE recipes.id NOT IN (
      SELECT recipes.id 
      FROM recipes 
      JOIN recipe_ingredients 
        ON recipes.id = recipe_ingredients.recipe_id
      WHERE recipe_ingredients.ingredient_id IN ( 
        SELECT ingredient_id 
        FROM banned_ingredients 
        JOIN diets 
          ON banned_ingredients.diet_id = diets.id
       WHERE diets.id = #{diet}
      )
    )
    AND (
      recipes.name LIKE '#{@search_term}'
      OR recipes.description LIKE '(#{@search_term})'
      OR ingredients.name LIKE '(#{@search_term})'
    )  
    GROUP BY recipes.id")

  erb :'search/results'

  # erb :index
end

get '/recipes/:id' do
  @recipe = Recipe.find(params[:id])

  @instructions = @recipe.instructions.split('. ')
  erb :'recipes/recipe'
end 

