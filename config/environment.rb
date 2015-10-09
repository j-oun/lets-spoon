require 'rubygems'
require 'bundler/setup'

require 'active_support/all'

# Load Sinatra Framework (with AR)
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib/all' # Requires cookies, among other things
# require 'pry'
# require 'byebug'


# Load these for api calls/extraction in object importers
require "net/http"
require "uri"
require 'active_support/core_ext/hash'
require_relative '../lib/recipe_importer'
require_relative '../app/models/recipe'
require_relative '../app/models/ingredient'
require_relative '../app/models/recipe_ingredient'
require_relative '../app/models/banned_ingredient'
require_relative '../app/models/diet'
require_relative '../app/models/user'


APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))
APP_NAME = APP_ROOT.basename.to_s

# Sinatra configuration
configure do
  set :root, APP_ROOT.to_path
  set :server, :puma

  enable :sessions
  set :session_secret, ENV['SESSION_KEY'] || 'lighthouselabssecret'

  set :views, File.join(Sinatra::Application.root, "app", "views")
end

# Set up the database and models
require APP_ROOT.join('config', 'database')

# Load the routes / actions
require APP_ROOT.join('app', 'actions')
