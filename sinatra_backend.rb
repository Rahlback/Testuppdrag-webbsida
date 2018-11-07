require "sinatra"
require "sinatra/reloader"

layout 'layout.erb'

$LANG = 'utf-8'

get '/' do

	erb :hem
end

get '/tjanster' do
	erb :tjanster
end

get '/kontakt' do
	erb :kontakt
end

get '/galleri' do
	erb :galleri
end

get '/login' do
	erb :login
end
