require "sinatra"
require "sinatra/reloader"
require "bcrypt"

layout 'layout.erb'

$LANG = 'utf-8'

def hash_password(password)
  BCrypt::Password.create(password).to_s
end

def verify_password(password, hash)
  BCrypt::Password.new(hash) == password
end

User = Struct.new(:id, :username, :password_hash)
USERS = [
  User.new(1, 'janne', hash_password('losenord')),
]

# enable :inline_templates
enable :sessions

get '/' do
	directory = "./news_feed_posts"
	@posts = Dir.glob(directory + "/*.post")
	erb :hem
end

get '/login' do
	erb :login
end

post '/login' do
	@error_message = nil
	user = USERS.find {|u| u.username == params[:username]}
	if (user && verify_password(params[:losenord], user.password_hash))
		session.clear
		session[:user_id] = user.id
		redirect '/'
	else
		@error_message = 'Användarnamn eller lösenord är inkorrekt'
		erb :login
	end
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
