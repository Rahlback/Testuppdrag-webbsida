
require 'sinatra'
require 'sinatra/reloader'
require 'date'

require './posts.rb'
require './options.rb'
require './random.rb'
require './filehandler.rb'
require './binary_counter.rb'

layout 'layout.erb'

@@basedir = Dir.pwd
@@basedir = File.expand_path(@@basedir)
$LANG = 'utf-8'
# Post messages class used as a simple gathering of different methods
# This class is now a cluster fuck. It is hideous and should not exists. 2014-05-31




@@posts = Posts.new
@@options = Options.new
@@filehandler = Filehandler.new
@@randomizer = Randomizer.new

get "/" do
	date = @@posts.get_current_day_as_string

	settings = @@options.settings

	@post_data = @@posts.get_posts_from_dir("#{Time.new.year.to_s}/#{date}")
	@post_data = @@posts.sort_list_of_filenames(@post_data)

	@posts = @@posts.get_post_content(@post_data).reverse

	
	# @@options.switch_state
	if @@options.get_state == "on"
		@att = "background-color: #{settings["background-color"]}; color: #{settings["color"]};"
	else
		@att = ""
	end
	
	erb :skriv_inlagg
end


get "/open" do
	@@posts.load
	@message_list = @@posts.message_list
	erb :index
end

### Year handling
	get "/open_year" do
		@directories = Dir.glob("./public/posts/*").sort.reverse
		erb :open_year
	end

	get "/open_year/:year" do |year|


		posts = @@posts.remove_non_files_from_list(@@posts.get_posts_from_dir("#{year}/**"))
		@message_list = @@posts.get_post_content(posts)

		erb :index
	end


### Settings
	
	get "/settings" do 
		@state = @@options.get_state
		@settings = @@options.settings


		@att = "background-color: #{@settings["background-color"]}; color: #{@settings["color"]};"

		erb :settings
	end

	post "/change_settings" do
		background_color = params[:background_color]
		color = params[:text_color]

		if background_color == ""
			background_color = @@options.settings["background-color"]
		end

		if color == ""
			color = @@options.settings["color"]
		end

		@@options.change_settings([["background-color", background_color], ["color",
									 color]])
		@@options.save_settings
		redirect back
	end

	get "/switch_state" do
		@@options.switch_state
		redirect back
	end

# Don't use this. Unknow effects might occur. Haven't been tested.
	# get '/delete' do
	# 	@@posts.delete
	# 	@@posts.delete_files
	# 	redirect '/'
	# end


#WIP
# Features complete? All gets now work. get /subpage/ is now obsolete and should be removed. 2014-05-31.

get '/backup' do
	posts = Dir.glob("./public/posts/*")
	FileUtils.cp_r(posts, './public/backup')
	redirect back
end



### Date mark
	get '/date_mark/main' do 
		@directories = Dir.glob("./public/posts/*").sort.reverse
		erb :date_mark_years
	end

	get '/date_mark/:year' do |year|
		@year = year
		@directories = Dir.glob("./public/posts/#{year}/*").sort.reverse
		erb :date_mark_main
	end

	get '/date/:year/:page' do |year, page|


		@post_data = @@posts.get_posts_from_dir("#{year}/#{page}")
		@post_data = @@posts.sort_list_of_filenames(@post_data)
		@posts = @@posts.get_post_content(@post_data).reverse

		erb :date_mark
	end
### end date mark

get '/remove/:node' do
	@@posts.delete_node(params[:node])
	redirect '/'
end

get '/subpage/:page' do |page|
	if page != ""
		erb :"#{page}"
	end
end


### WIP edit capability
### DONE
### Start edit
	get '/edit_post/:id' do |id|
		@id_fullname = @@posts.get_file_fullname_from_id(id)
		@post = @@posts.get_post_content([@id_fullname])
		@post = @post[0]
		erb :edit_post
	end

	post '/edit_post/edit_message' do
		text = params[:edit_message]
		f = File.open("C:/Users/Rasmus/Desktop/shortcuts/textdokument/html/filedump/fildun.txt", "w")
		text = text.split("\n")
		i = 1
		text.each do |line|
			if i == 2
				f.write("")
			end
			f.write("#{i}: " + line)
			i += 1
		end
		f.write("#{@@posts.get_file_fullname_from_id(text[-1].chomp)} <--- This should be it: ID ")
		f.write(text[-1])
		f.close
		# file = File.open(@@posts.get_file_fullname_from_id(text[-1].chomp), "w")
		# text.each do |line|
		# 	file.write(line.gsub("\r", ""))
		# 	file.write("\n")
		# end
		# file.close

		@@posts.save_over_file(text[-1], text)

		redirect "/"
	end
### End edit

post '/message' do
	id = @@posts.updated_id
	@@posts.save_post([params[:message],params[:user], Time.now, id])
	redirect "/"
end

not_found do 
	"No such page found"
end

get '/rollback_posts' do
	backup_posts = Dir.glob("./public/backup/*")
	FileUtils.cp_r(backup_posts, './public/posts')
	redirect '/'
end




#### Features not tied to diary

get '/tools' do 
	erb :tools
end
# 
# This is supposed to output a random game chosen from a list. It is supposed to be editable from webpage.
# 


# random game
	get '/random_game' do
		@game_list = @@filehandler.load_from_file("./public/random_games.data")
		@random_game = @@randomizer.random_list_item(@game_list)
		erb :random_game
	end

	post '/random_game_update' do
		p = @@randomizer.data_manipulation(params[:message])
		if @@randomizer.data_manipulation(params[:overwrite])[0] == "overwrite"
			@@filehandler.save_to_file("./public/random_games.data", p)
		else
			@@filehandler.append_to_file("./public/random_games.data", p)
		end
		redirect '/random_game'
	end

	get '/remove_game/' do
		@@filehandler.remove_from_file("./public/random_games.data", "")
		redirect '/random_game'
	end

	get '/remove_game/:game' do |game|
		@@filehandler.remove_from_file("./public/random_games.data", game.gsub("%20", " "))
		redirect '/random_game'
	end



# base converter
	get '/base_converter' do 

		erb :base_converter
	end