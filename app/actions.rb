helpers do
  def current_user
    @user_id = session["user_id"] if session["user_id"]
  end

  def flash
    session[:flash] = "Invalid information" if session[:flash]
  end
end

before do
  current_user
  flash
end

get '/' do
  erb :index
end

get '/form' do
  erb :form
end

post '/profile/signin' do
  @user = User.find_by(
    email: params[:email],
    password: params[:password]
    )
  if @user    # user not falsey
    session[:user_id] = @user.id    # setting session hash values 
    session[:email] = @user.email
    session[:first_name] = @user.first_name
    redirect "/"
  else
    session[:flash] = "Invalid information"
    redirect "/"
  end
end

get '/profile/signout' do
  session.clear
  redirect '/'
end

get "/profile" do
  @habit = Habit.where(user_id: @user_id)  # get params from url via get.
  erb :profile
end

