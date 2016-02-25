helpers do
  def current_user
    @user_id = session[:user_id] if session[:user_id]
  end

  def flash
    session[:flash] = "Invalid information" if session[:flash]
    session[:flash] = nil
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
  if @user
    session[:user_id] = @user.id
    session[:email] = @user.email
    session[:first_name] = @user.first_name
    session[:last_name] = @user.last_name
    redirect '/'
  else
    session[:flash] = "Invalid information"
    redirect '/'
  end
end

get '/profile/signout' do
  session.clear
  redirect '/'
end

get "/profile" do
  @habits = Habit.where(user_id: @user_id)
  erb :profile
end

post '/profile/decision' do
  if params[:decision] == "I Changed My Mind"
    redirect "/profile/:id"
  else
    @habit = Habit.new(
      name: params[:habit_name],
      user_id: session[:user_id],
      start_date: Date.today + params[:start_in_days].to_i
      )
    @habit.save
    redirect "/profile/:id"
  end
end
