get '/' do
  erb :index
end

get "/profile/#{session["user_id"]}" do
  @habit = Habit.find_by(user_id: session["user"])
  erb :profile
end

get '/form' do

  erb :form
end

get '/profile/signin' do
  @user = User.find_by(
    email: params[:email],
    password: params[:password]
    )
  if @user != nil
    session["user"] = @user.id
    session["email"] = @user.email
    redirect '/'
  else
    erb :'users/signin'
  end
end

get '/profile/signout' do
  session.clear
  redirect '/'
end