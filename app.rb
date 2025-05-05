require 'sinatra'
require 'sinatra/flash'
require 'bcrypt'
require 'securerandom'

enable :sessions
set :session_secret, ENV['SESSION_SECRET'] || SecureRandom.hex(64)
set :environment, :development

# Store de usuarios (en memoria, solo para pruebas)
users = {}

# Middleware para proteger rutas del dashboard
before '/dashboard*' do
  redirect '/login' unless session[:user_id]
end

# Página principal
get '/' do
  erb :index
end

# Página de login
get '/login' do
  erb :login
end

# Procesar formulario de login
post '/login' do
  username = params[:username]
  password = params[:password]

  if users[username] && BCrypt::Password.new(users[username][:password]) == password
    session[:user_id] = username
    session[:csrf_token] = SecureRandom.hex(32)
    redirect '/dashboard'
  else
    flash[:error] = "Nombre de usuario o contraseña inválidos"
    redirect '/login'
  end
end

# Página de registro
get '/register' do
  erb :register
end

# Procesar formulario de registro
post '/register' do
  username = params[:username]
  password = params[:password]
  confirm_password = params[:confirm_password]

  # Verificación de contraseñas coincidentes
  if password != confirm_password
    flash[:error] = "Las contraseñas no coinciden"
    redirect '/register'
  # Validación de campos vacíos
  elsif username.to_s.strip.empty? || password.to_s.strip.empty?
    flash[:error] = "Se requieren nombre de usuario y contraseña"
    redirect '/register'
  # Verificación de existencia de usuario
  elsif users[username]
    flash[:error] = "El nombre de usuario ya existe"
    redirect '/register'
  else
    # Encriptación de la contraseña y almacenamiento del usuario
    hashed_password = BCrypt::Password.create(password)
    users[username] = { password: hashed_password }

    flash[:success] = "Registro exitoso. Inicia sesión."
    redirect '/login'
  end
end

# Dashboard (protegido)
get '/dashboard' do
  erb :dashboard
end

# Logout
get '/logout' do
  session.clear
  redirect '/login'
end
