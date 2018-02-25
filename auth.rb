$secret = File.read 'secret.txt'

require 'digest'
require 'jwt'

def login(username, password)
  password_hash = Digest::SHA512.digest password
  password.gsub /./, ' '

  rows = $db.execute('SELECT * FROM users WHERE username=? AND password_hash=? LIMIT 1;', [username, password_hash])
  
  return false if rows.empty?

  payload = { 'username' => username, 'random' => Random.rand  }
  JWT.encode payload, $secret, 'HS256'
end

def register(username, password)
  return false unless $enable_register

  return false unless $db.execute('SELECT * FROM users WHERE username=? LIMIT 1;', [username]).empty?

  password_hash = Digest::SHA512.digest password
  password.gsub /./, ' '

  $db.execute('INSERT INTO users (username, password_hash) VALUES (?, ?);', [username, password_hash])

  payload = { 'username' => username, 'random' => Random.rand  }
  JWT.encode payload, $secret, 'HS256'
end

def decode_token(token)
  payload = JWT.decode token, $secret, true, { :algorithm => 'HS256' }
  return payload[0]['username']
end

def valid_token?(token)
  begin
    username = decode_token(token)  
    rows = $db.execute('SELECT * FROM users WHERE username=? LIMIT 1;', [username])
    if rows.empty? then return false else return username end
  rescue JWT::VerificationError => e
    return false
  end
end

post '/auth/login' do
  username = request[:username]
  password = request[:password]
  token = login(username, password)
  return 403 unless token
  {
    'token' => token
  }.to_json
end

post '/auth/register' do
  username = request[:username]
  password = request[:password]
  token = register(username, password)
  return 403 unless token
  {
    'token' => token
  }.to_json
end

post '/auth/test' do
  {
    'username' => decode_token(request[:token])
  }.to_json
end