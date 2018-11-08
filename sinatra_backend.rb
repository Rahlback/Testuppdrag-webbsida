require "sinatra"
require "sinatra/reloader"
require "bcrypt"
require "date"

layout 'layout.erb'

$LANG = 'utf-8'

def hash_password(password)
  BCrypt::Password.create(password).to_s
end

def verify_password(password, hash)
  BCrypt::Password.new(hash) == password
end


def current_user
	if session[:user_id] != nil
		return USERS.find { |u| u.id == session[:user_id]}
	else
		return nil
	end
end


User = Struct.new(:id, :username, :password_hash)
USERS = [
  User.new(1, 'janne', hash_password('losenord')),
]


enable :sessions

get '/' do
	directory = "./news_feed_posts"
	@posts = Dir.glob(directory + "/*.post")
	@user = current_user
	erb :hem
end

get '/login' do
	@user = current_user
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

get '/logout' do
	session.clear
	redirect '/'
end

post '/feed_post' do
	if current_user == 1
		time = Time.now
		file_name = "./news_feed_posts/#{time.year}_#{time.month}_#{time.day}_#{time.hour}#{time.min}"
		file_name = file_name + "," + Dir.glob("#{file_name}*").size.to_s + ".post"
		f = File.new(file_name, "w")
		f.write(params[:feed_text])
		f.close
		end
	redirect '/'
end

get '/tjanster' do
	@file = File.read("./public/custom_view/tjanster.custom")
	@user = current_user
	erb :tjanster
end

post '/tjanster_form_post' do
	if (params[:rubrik] != "")
		text = '<p class="rubrik1">' + "\n"
		text = text + params[:rubrik] + "\n" + "</p>"
	else
		text = ""
	end
	
	text = text + params[:tjanster_textarea]
	f = File.open("./public/custom_view/tjanster.custom","w")
	f.write(text)
	f.close
	redirect '/tjanster'
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
