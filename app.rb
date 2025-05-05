require 'sinatra'
require 'sinatra/flash'
require 'bcrypt'
require 'securerandom'

enable :sessions
set :session_secret, ENV['SESSION_SECRET'] || SecureRandom.hex(64)

# Simple in-memory user store (replace with a database in production)
users = {}

# Middleware to check if user is logged in
before '/dashboard*' do
  redirect '/login' unless session[:user_id]
end

# Home page
get '/' do
  erb :index
end

# Login page
get '/login' do
  erb :login
end

# Login form submission
post '/login' do
  username = params[:username]
  password = params[:password]
  
  if users[username] && BCrypt::Password.new(users[username][:password]) == password
    session[:user_id] = username
    session[:csrf_token] = SecureRandom.hex(32)
    redirect '/dashboard'
  else
    flash[:error] = "Invalid username or password" # flash render message error
    redirect '/login'
  end
end

# Registration page
get '/register' do
  erb :register
end  


# Registration form submission
post '/register' do
  username = params[:username]
  password = params[:password]
  
  if username.nil? || username.empty? || password.nil? || password.empty?
    flash[:error] = "Username and password are required"
    redirect '/register'
  elsif users[username]
    flash[:error] = "Username already exists"
    redirect '/register'
  else
    # Hash the password before storing
    hashed_password = BCrypt::Password.create(password)
    users[username] = { password: hashed_password }
    
    flash[:success] = "Registration successful! Please log in."
    redirect '/login'
  end
end

# Dashboard (protected route)
get '/dashboard' do
  erb :dashboard, locals: { username: session[:user_id], csrf_token: session[:csrf_token] }
end

# Logout
post '/logout' do
  # Verify CSRF token
  if params[:csrf_token] == session[:csrf_token]
    session.clear
    redirect '/'
  else
    status 403
    "CSRF token verification failed"
  end
end
