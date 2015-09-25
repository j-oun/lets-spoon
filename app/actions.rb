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
  
  @recipes = Recipe.joins(:ingredients).where(
    "ingredients.name LIKE :search OR recipes.name LIKE :search OR recipes.description LIKE :search", 
    search: "%#{@search_term}%"
  ).where("ingredients.id NOT IN (?)", [1]).group(:id)
  erb :'search/results'
  # erb :index
end

get '/recipes/:id' do
  @recipe = Recipe.find(params[:id])

  @instructions = @recipe.instructions.split('. ')
  erb :'recipes/recipe'
end

