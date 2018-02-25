require './db'

require 'sinatra'
require 'haml'

require 'json'

require './auth'
require './quotes'

get '/' do
  return 403 if $ban_unregistered and (!session[:token] or !valid_token?(session[:token]))
  @page = 'home'
  @offset = 0
  if params[:offset]
    @offset = params[:offset].to_i
  end
  haml :index, :layout => :layout
end

not_found do
  haml :'404', :layout => :layout
end

error 403 do
  haml :'403', :layout => :layout
end

get '/fail' do
  @page = 'home'
  haml :fail, :layout => :layout
end

get '/login' do
  @page = 'login'
  haml :login, :layout => :layout
end

post '/login' do
  return redirect '/fail' if session[:token]
  username = request[:username]
  password = request[:password]
  token = login(username, password)
  return redirect '/fail' unless token
  session[:token] = token
  redirect '/'
end

get '/logout' do
  return redirect '/fail' unless session[:token]
  session[:token] = nil
  redirect '/'
end

get '/register' do
  @page = 'register'
  haml :register, :layout => :layout
end

post '/register' do
  return redirect '/fail' if session[:token]
  return redirect '/fail' unless $enable_register
  username = request[:username]
  password = request[:password]
  token = register(username, password)
  return redirect '/fail' unless token
  session[:token] = token
  redirect '/'
end

get '/add' do
  @page = 'add'
  haml :add, :layout => :layout
end

post '/add' do
  quote = request[:quote]
  return redirect '/fail' unless quote.length >= 64
  token = session[:token]
  return redirect '/fail' unless token
  user = valid_token?(token)
  return redirect '/fail' unless user
  id = $db.execute('SELECT MAX(id) FROM quotes;')[0][0]
  id = if id then id + 1 else 0 end
  $db.execute('INSERT INTO quotes (id, quote, author) VALUES (?, ?, ?);', [id, quote, user])
  redirect '/'
end