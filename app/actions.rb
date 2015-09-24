helpers do
  def current_user
    @user = User.new(
      name: "name",
      email:  "email",
      password:  "password",
      diet_id: 1
    )
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
end

get '/recipes/:id' do
  erb :'recipes/recipe'
end

