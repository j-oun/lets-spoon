helpers do
  def current_user
    @user = User.create(
      name: 'Doge', 
      email: 'doge@doge.com', 
      password: 'password',
    ) 
    @diet1 = UsersDiet.create(
      user_id: @user.id,
      diet_id: 3)
    @diet2 = UsersDiet.create(
      user_id: @user.id,
      diet_id: 0)
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

  @recipes = Recipe.find_by_sql(
    "SELECT r.name, r.description, r.image_url, r.id
      FROM recipes as r 
      JOIN recipe_ingredients as r_i 
        ON r.id = r_i.recipe_id
      JOIN ingredients as i
        ON r_i.ingredient_id = i.id
      WHERE (
        r.name LIKE '%#{@search_term}%'
        OR r.description LIKE '%#{@search_term}%'  
        OR i.name LIKE '%#{@search_term}%' 
      )  
      AND r.id NOT IN (
        SELECT r.id 
        FROM recipes as r 
        JOIN recipe_ingredients as r_i 
          ON r.id = r_i.recipe_id
        WHERE r_i.ingredient_id IN ( 
          SELECT ingredient_id 
          FROM banned_ingredients 
          WHERE diet_id IN (
            SELECT diet_id 
              FROM users_diets
              WHERE user_id = #{@user.id}
          )
        )
      )  
      GROUP BY r.id;")
  
  erb :'search/results'
end

get '/recipes/:id' do
  @recipe = Recipe.find(params[:id])

  @instructions = @recipe.instructions.split('. ')
  erb :'recipes/recipe'
end 

