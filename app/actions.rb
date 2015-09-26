helpers do
  def current_user
    @user = User.first
    # @user = User.create(
    #   name: 'Doge', 
    #   email: 'doge@doge.com', 
    #   password: 'password',
    # ) 
    # @diet1 = UsersDiet.create(
    #   user_id: @user.id,
    #   diet_id: 3)
    # @diet2 = UsersDiet.create(
    #   user_id: @user.id,
    #   diet_id: 0)
    @diet1 = UsersDiet.find_by(user_id: @user.id, diet_id: 1)
    @diet2 = UsersDiet.find_by(user_id: @user.id, diet_id: 2)
    @diet3 = UsersDiet.find_by(user_id: @user.id, diet_id: 3)
    @diet4 = UsersDiet.find_by(user_id: @user.id, diet_id: 4)
    @diet5 = UsersDiet.find_by(user_id: @user.id, diet_id: 5)
    @diet6 = UsersDiet.find_by(user_id: @user.id, diet_id: 6)
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

post '/users/:id/update' do
  # byebug

  if params[:pesc]    
    unless @diet1
      UsersDiet.create(
        user_id: @user.id,
        diet_id: 1
      )
    end
  else     
    @diet1.destroy if @diet1
  end

  if params[:vegetarian]
    unless @diet2
      UsersDiet.create(
        user_id: @user.id,
        diet_id: 2
      )
    end
  else 
    # byebug
    @diet2.destroy if @diet2
  end


  if params[:vegan]    
    unless @diet3
      UsersDiet.create(
        user_id: @user.id,
        diet_id: 3
      )
    end
  else 
    @diet3.destroy if @diet3
  end

  if params[:glut]    
    unless @diet4
      UsersDiet.create(
        user_id: @user.id,
        diet_id: 4
      )
    end
  else     
    @diet4.destroy if @diet4
  end

  if params[:paleo] 
    unless @diet5
      UsersDiet.create(
        user_id: @user.id,
        diet_id: 5
      )
    end
  else 
    @diet5.destroy if @diet5
  end

  if params[:lact]
    unless @diet6
      UsersDiet.create(
        user_id: @user.id,
        diet_id: 6
      )
    end
  else 
    @diet6.destroy if @diet6
  end

  redirect "/users/#{params[:id]}"
end


