require 'sinatra'
require 'thread'

$enable_register = false
$ban_unregistered = true

configure do
  enable :sessions
end

require './app'

run Sinatra::Application