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
    rate.round(1)
  end

  def week2_success_rate(habit_id)
    week1 = Day.where(habit_id: habit_id, position:(8..14), result:"T")
    number_success = week1.count
    rate = number_success/7.0*100
    rate.round(1)
  end

  def week3_success_rate(habit_id)
    week1 = Day.where(habit_id: habit_id, position:(15..21), result:"T")
    number_success = week1.count
    rate = number_success/7.0*100
    rate.round(1)
  end

  def avg_success_rate(habit_id)
    avg = (week1_success_rate(habit_id) + week2_success_rate(habit_id) + week3_success_rate(habit_id)) / 3
    avg.round(1)
  end
end

before do
  current_user
  check_flash
end

get '/' do
  erb :index
end

get '/testemail' do
  # Pony.options = {
  #   subject: "Hello World",
  #   body: "All the Best from the Habit Tracker Team.",
    # via: :smtp,
    # via_options: {
    #   address:              'smtp.gmail.com',
    #   port:                 '587',
    #   enable_starttls_auto: true,
    #   user_name:            'habit.tracker.mailer@gmail.com',
    #   password:             'web-van-feb2016',
    #   authentication:       :login,
    #   domain:               'gmail.com'
    # }
  # }
  Pony.mail(
    to: 'zhengyuchao@yahoo.ca',
    subject: 'Hello World',
    html_body: '<h1>Test Email</h1>
                <h4 style="color:red;">Habit Tracker Test<h4>',
    body: "Test Email (non-html version in case you can't read html body)"
  )
  redirect '/'
end

get '/form' do
  repopulate_habit_name
  erb :form
end

# CZ: called from habits.erb \ calendar \ updateDay ajax function
get '/update_day' do
  day_to_update = Day.find_by(habit_id: params[:habit].to_i, position: params[:day].to_i)
  day_to_update.result = params[:result]
  day_to_update.save
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

      @user = User.find_by(id: session[:user_id])
      Pony.mail(
        to: @user.email,
        subject: "#{@user.first_name}, you created a new habit - #{params[:habit_name]}",
        html_body: "
          <h2>You created a new habit - #{params[:habit_name]} :)</h2>
          <p><a href=\"http://0.0.0.0:3000/habits/#{@habit.id}\">Goto #{params[:habit_name]}</a></p>
          <p>&nbsp;</p>
          <p style=\"font-style:italic;\">Sincerely,</p>
          <p>The Habit Tracker Team</p>
          ",
        body: "
          You created a new habit - #{params[:habit_name]} :)
          Link: http://0.0.0.0:3000/habits/#{@habit.id}
          "
      )
      redirect "/profile"
    end
  end
end

# CZ: deletes a profile given user_id, habit_id. called from profile.erb
post '/profile/delete' do
  @habit = Habit.find(params[:habit_id])
  @user = User.find(session[:user_id])
  Pony.mail(
    to: @user.email,
    subject: "#{@user.first_name}, you deleted an existing habit - #{@habit.name}",
    html_body: "
      <h2>You deleted a habit - #{@habit.name} :(</h2>
      <p><a href=\"http://0.0.0.0:3000/profile\">Go commit to a new one!</a></p>
      <p>&nbsp;</p>
      <p style=\"font-style:italic;\">Sincerely,</p>
      <p>The Habit Tracker Team</p>
      ",
    body: "
      You deleted a habit - #{@habit.name} :(
      Link: http://0.0.0.0:3000/profile
      "
  )
  #CZ: todo - DRY this code out
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
    Pony.mail(
      to: @user.email,
      subject: "Welcome to Habit Tracker, #{@user.first_name}!",
      html_body: "
        <h1>Welcome to Habit Tracker!</h1>
        <p><span style=\"font-weight:bold;\">#{@user.first_name}</span>, you smart! We appreciate you!</p>
        <p style=\"color:blue;\">We wish you all the best in your journey of building new habits.</p>
        <p>&nbsp;</p>
        <p><a href=\"http://0.0.0.0:3000/\">Go to my Habit Tracker profile</a></p>
        <p>&nbsp;</p>
        <p style=\"font-style:italic;\">Sincerely,</p>
        <p>The Habit Tracker Team</p>
        ",
      body: "
        Welcome to Habit Tracker!

        http://0.0.0.0:3000/ - Go to my Habit Tracker profile

        We wish you all the best in your journey of building new habits.
        You smart! We appreciate you!

        Sincerely,
        The Habit Tracker Team
        "
    )
    session[:flash] = "Welcome to Habit Tracker! A confirmation email has been sent and will arrive shortly."
    redirect '/'
  else
    redirect '/signup'
  end
end