helpers do
  def current_user
    @user = User.find(session[:user_id]) if session[:user_id]

    if @user
      @diet1 = UsersDiet.find_by(user_id: @user.id, diet_id: 1)
      @diet2 = UsersDiet.find_by(user_id: @user.id, diet_id: 2)
      @diet3 = UsersDiet.find_by(user_id: @user.id, diet_id: 3)
      @diet4 = UsersDiet.find_by(user_id: @user.id, diet_id: 4)
      @diet5 = UsersDiet.find_by(user_id: @user.id, diet_id: 5)
      @diet6 = UsersDiet.find_by(user_id: @user.id, diet_id: 6)
    else
      @diet1 = UsersDiet.find_by(user_id: 0, diet_id: 1)
      @diet2 = UsersDiet.find_by(user_id: 0, diet_id: 2)
      @diet3 = UsersDiet.find_by(user_id: 0, diet_id: 3)
      @diet4 = UsersDiet.find_by(user_id: 0, diet_id: 4)
      @diet5 = UsersDiet.find_by(user_id: 0, diet_id: 5)
      @diet6 = UsersDiet.find_by(user_id: 0, diet_id: 6)
    end
  end

  def update_diets(id)
    if params[:pesc]    
      unless @diet1
        UsersDiet.create(
          user_id: id,
          diet_id: 1
        )
      end
    else     
      @diet1.destroy if @diet1
    end

    if params[:vegan]
      unless @diet2
        UsersDiet.create(
          user_id: id,
          diet_id: 2
        )
      end
    else 
      @diet2.destroy if @diet2
    end

    if params[:vegetarian]    
      unless @diet3
        UsersDiet.create(
          user_id: id,
          diet_id: 3
        )
      end
    else 
      @diet3.destroy if @diet3
    end

    if params[:glut]    
      unless @diet4
        UsersDiet.create(
          user_id: id,
          diet_id: 4
        )
      end
    else     
      @diet4.destroy if @diet4
    end

    if params[:paleo] 
      unless @diet5
        UsersDiet.create(
          user_id: id,
          diet_id: 5
        )
      end
    else 
      @diet5.destroy if @diet5
    end

    if params[:lact]
      unless @diet6
        UsersDiet.create(
          user_id: 0,
          diet_id: 6
        )
      end
    else 
      @diet6.destroy if @diet6
    end
  end

  def query(id)
    Recipe.find_by_sql(
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
              WHERE user_id = #{id}
          )
        )
      )  
      GROUP BY r.id;")
  end

  
  def saved_recipe_query
    Recipe.find_by_sql(
    "SELECT r.name, r.description, r.image_url, r.id
      FROM recipes as r 
      JOIN saved_recipes as s_r 
        ON r.id = s_r.recipe_id
      JOIN users as u
        ON s_r.user_id = u.id
      WHERE r.id in(
        SELECT id from saved_recipes WHERE user_id=#{@user.id} 
      )  
      GROUP BY r.id;") if @user
  end

  @search_page = true
end

before do
  current_user
  saved_recipe_query
end

get '/' do
  erb :index
end

get '/users/login' do
  erb :'users/login'
end

get '/users/:id' do
  erb :'users/user'
end

post '/users/login' do
  email = params[:email]

  user = User.find_by(email: email)

  if user 
    session[:user_id] = user.id
  else 
    session[:error] = "Invalid credentials"
  end

  redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/search' do
  if @user
    user_id = @user.id
  else
    user_id = 0
  end

  @search_term = params[:search_term]
  @saved_recipes = saved_recipe_query
  @recipes = query(user_id)
  @search_page = true
  
  erb :'search/results'
end

get '/homepage_search/:diet_id' do
  unless @user
    UsersDiet.create(
      user_id: 0,
      diet_id: params[:diet_id]
    )
  end
  redirect '/search'
end

get '/recipes/:id' do
  @recipe = Recipe.find(params[:id])
  @saved_recipes = saved_recipe_query
  @instructions = @recipe.instructions.split('. ')
  erb :'recipes/recipe'
end 

post '/users/:id/update' do
  update_diets(@user.id)

  redirect "/users/#{params[:id]}"
end

post '/search/refine' do
  update_diets(0)

  if @user
    user_id = @user.id
  else
    user_id = 0
  end

  @search_term = params[:search_term]

  @recipes = query(user_id)

  @diet1 = UsersDiet.find_by(user_id: 0, diet_id: 1)
  @diet2 = UsersDiet.find_by(user_id: 0, diet_id: 2)
  @diet3 = UsersDiet.find_by(user_id: 0, diet_id: 3)
  @diet4 = UsersDiet.find_by(user_id: 0, diet_id: 4)
  @diet5 = UsersDiet.find_by(user_id: 0, diet_id: 5)
  @diet6 = UsersDiet.find_by(user_id: 0, diet_id: 6)
  @search_page = true
  @saved_recipes = saved_recipe_query
  erb :'search/results'
end

post '/saved_recipes' do 
  SavedRecipe.create(user_id: @user.id, recipe_id: params[:recipe_id])
  path = "/users/" + "#{@user.id}/" + "recipes"
  redirect path
end

get '/users/:id/recipes' do |id|
  @recipes = saved_recipe_query
  @saved_recipes = saved_recipe_query
  @search_page = false
  erb :'search/results'
end