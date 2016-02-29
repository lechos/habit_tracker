require 'rubygems'
require 'bundler/setup'

require 'active_support/all'

# Load Sinatra Framework (with AR)
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib/all' # Requires cookies, among other things

require 'pony'
require 'pry'

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


class Application < Sinatra::Base
  configure do
    Pony.options = {
      via: :smtp,
      via_options: {
        from:                 'habit.tracker.mailer@gmail.com',
        address:              'smtp.gmail.com',
        port:                 '587',
        enable_starttls_auto: true,
        user_name:            'habit.tracker.mailer@gmail.com',
        password:             'vagrantssh',
        authentication:       :login,
        domain:               'gmail.com'
      }
    }
  end
end