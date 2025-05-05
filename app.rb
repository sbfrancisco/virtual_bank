require 'sinatra'

enable :sessions  # Habilita sesiones

# Datos de usuario (simulación, en una base de datos real estarían almacenados de otra forma)
USUARIOS = { "admin" => "1234", "usuario" => "pass" }

# Página de inicio (login)
get '/' do
  erb :login
end

# Ruta para procesar el login
post '/login' do
  usuario = params[:usuario]
  password = params[:password]

  if USUARIOS[usuario] == password  # Verifica credenciales
    session[:usuario] = usuario  # Guarda sesión
    redirect '/dashboard'  # Redirige a la página protegida
  else
    @error = "Usuario o contraseña incorrectos"
    erb :login  # Vuelve al login con mensaje de error
  end
end

# Ruta protegida (requiere estar logueado)
get '/dashboard' do
  redirect '/' unless session[:usuario]  # Si no hay sesión, vuelve al login
  erb :dashboard
end

# Cerrar sesión
get '/logout' do
  session.clear  # Borra la sesión
  redirect '/'
end