helpers do

  def current_user
    @user_id = session[:user_id] if session[:user_id]
  end

  def check_flash
    @flash = session[:flash] if session[:flash]
    session[:flash] = nil
  end

  def repopulate_habit_name
    @habit_name = session[:habit_name] if session[:habit_name]
    session[:habit_name] = nil
  end

  def positive_integer?(str)
    /\A[+]?\d+\z/.match(str) ? true : false
  end

  def create_21_days
    position = 0
    loop do
      position += 1
      @day = Day.new(
        habit_id: @habit.id,
        position: position
      )
      @day.save
      break if position==21
    end
  end

  def update_day_result
    Day.where(habit_id: params[:id]).each {|x| x.update(result:"F")}
    position = 0
    loop do
      position += 1
        if params["#{position}"]
          day = Day.find_by(position: position, habit_id: params[:id])
          day.update(result: "T")
          day.save
        end
      break if position == 21
    end
  end

  def week1_success_rate(habit_id)
    week1 = Day.where(habit_id: habit_id, position:(1..7), result:"T")
    number_success = week1.count
    rate = number_success/7.0*100
    rate.round(2)
  end

  def week2_success_rate(habit_id)
    week1 = Day.where(habit_id: habit_id, position:(8..14), result:"T")
    number_success = week1.count
    rate = number_success/7.0*100
    rate.round(2)
  end

  def week3_success_rate(habit_id)
    week1 = Day.where(habit_id: habit_id, position:(15..21), result:"T")
    number_success = week1.count
    rate = number_success/7.0*100
    rate.round(2)
  end
end

before do
  current_user
  check_flash
end

get '/' do
  erb :index
end

get '/form' do
  repopulate_habit_name
  erb :form
end

post '/profile/signin' do
  @user = User.find_by(
    email: params[:email],
    password: params[:password]
    )
  @user_email = User.find_by(
    email: params[:email]
    )
  if @user    # user not falsey
    session[:user_id] = @user.id    # setting session hash values 
    session[:email] = @user.email
    session[:first_name] = @user.first_name
    session[:last_name] = @user.last_name
    redirect '/profile'
  elsif @user_email
    session[:flash] = "Password doesn't match our records. Please try again."
    redirect '/'
  else
    session[:flash] = "Email doesn't match our records. Please try again."
    redirect '/'
  end
end

get '/profile/signout' do
  session.clear
  redirect '/'
end

get "/profile" do
  @habits = Habit.where(user_id: @user_id).order(start_date: :desc)
  erb :profile
end

post '/profile/decision' do
  # CZ: Redirect to profile page if user is in /form, and clicked "I Changed My Mind"

  if params[:committed].nil?
    redirect "/profile" 
  else
    # CZ: Check if "days_from_now" is positive integer
    # CZ: (todo - DRY code)
    if params[:habit_name].nil? || params[:habit_name] == "" || (params[:habit_name].length < 3)
      session[:flash] = "Habit name cannot be less than 3 characters."
      session[:habit_name] = params[:habit_name]
      redirect "/form"
    elsif params[:start_in_days].nil? || params[:start_in_days] == ""
      session[:flash] = "Start in days can not be empty."
      session[:habit_name] = params[:habit_name]
      redirect "/form"
    elsif positive_integer?(params[:start_in_days]) == false
      session[:flash] = "Start in days must be a positive whole number."
      session[:habit_name] = params[:habit_name]
      redirect "/form"
    else
      @habit = Habit.new(
        name: params[:habit_name],
        user_id: session[:user_id],
        start_date: Date.today + params[:start_in_days].to_i
      )
      @habit.save
      create_21_days
      redirect "/profile"
    end
  end
end

# CZ: deletes a profile given user_id, habit_id. called from profile.erb
post '/profile/delete' do
  Habit.where(user_id: session[:user_id]).where(id: params[:habit_id]).destroy_all
  redirect "/profile"
end

get '/habits/:id' do
  @habit = Habit.find(params[:id])
  @week1 = Day.where(habit_id: params[:id], position:(1..7))
  @week2 = Day.where(habit_id: params[:id], position:(8..14))
  @week3 = Day.where(habit_id: params[:id], position:(15..21))
  erb :'habits'
end

post '/habits/:id' do
  update_day_result
  redirect "/habits/#{params[:id]}"
end

get '/calendar' do
  erb :'calendar'
end

get '/signup' do
  erb :'signup'
end

post '/profile/signup' do
  @user = User.new(
    first_name: params[:first_name].capitalize,
    last_name: params[:last_name].capitalize,
    email: params[:email],
    password: params[:password]
    )
  if @user    # user not falsey
    @user.save
    redirect '/'
  else
    redirect '/signup'
  end
end