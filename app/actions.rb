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
  erb :'search/results'

  @recipes = Recipe.joins(:ingredients).where(
    "ingredients.name LIKE :search OR recipes.name LIKE :search OR recipes.description LIKE :search", 
    search: "%#{@search_term}%"
  ).where("ingredients.id NOT IN (?)", [3]).group(:id)
  
end

get '/recipes/:id' do
  @recipe = Recipe.find(5)

  @instructions = @recipe.instructions.split('. ')
  # binding.pry
  erb :'recipes/recipe'
end

