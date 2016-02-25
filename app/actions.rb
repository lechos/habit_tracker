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
  if @user != nil
    session["user_id"] = @user.id
    session["email"] = @user.email
    session["first_name"] = @user.first_name
    redirect "/profile/1"
  end
    redirect "/"
end

get '/profile/signout' do
  session.clear
  redirect '/'
end

get "/profile/1" do
  @habit = Habit.find_by(user_id: :id)
  erb :profile
end

