class Users::UsersController < ApplicationController
	before_action :authenticate_user, :only => [:index, :update, :exchange, :logarun_synced?]

	def new
		@error = 'That LogARun username is not on the LogAStrava team on LogARun' if params['error'] == 'join-team'
		@error = 'An account with that username has already been created' if params['error'] == 'uniq-user'
		@error = "Passwords don't match" if params['error'] == 'password'
	end

	def index
		@info = strava_info
		@num = User.all.count
	end

	def exchange
		unless params[:error] == 'access_denied'
			data = StaticDatum.first
			form = {:client_id => data.client_id, :client_secret => data.client_secret, :code => params[:code]}
			json = JSON.parse(HTTP.post("https://www.strava.com/oauth/token", :form => form).to_s)
			@current_user.access_token = json['access_token']
			@current_user.save
			Process.fork {
				sleep 5
				exec("RAILS_ENV=production bin/rake daily_sync:midnight[1284]")
	    }
		end
		redirect_to users_root_path
	end

	def login
		u = User.find_by(username: user_params[:username])
		if u && u.try(:authenticate, user_params[:password])
			session[:user_id] = u.id
			redirect_to users_root_path
		else
			redirect_to root_path(error: 'unauthorized')
		end
	end

	def create
		u = User.new(user_params)
		unless accept_user(u.username)
			redirect_to users_new_path(error: 'join-team')
			return
		end
		unless u.save
			code = User.find_by(username: user_params[:username]) ? 'uniq-user' : 'password'
			redirect_to users_new_path(error: code)
			return
		end
		session[:user_id] = u.id
	  redirect_to users_root_path
	end

	def update
	end

	def logarun_synced?
		render :json => lar_check(@current_user.username)
	end

	private
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

	def accept_user(username)
		begin
			HTTP.timeout(:read => 1).cookies(:sqlAuthCookie => ENV['SQL_AUTH_ID']).post('http://www.logarun.com/teamwebservice.ashx?op=activateuser', :body => "[['teamId', 1820], ['username', '#{username}']]")
			return true
		rescue
			return false
		end
	end

	def lar_check(username)
		doc = Nokogiri::HTML(HTTP.cookies(:sqlAuthCookie => ENV['SQL_AUTH_ID']).get("http://www.logarun.com/TeamCalendar.aspx?teamid=1820&date=#{Date.today.strftime('%m-%d-%Y')}").to_s)
		doc.css('div.day>a').inner_html.include?(username)
	end

	def strava_info
		return false unless @current_user.access_token
		response = HTTP.get("https://www.strava.com/api/v3/athlete?access_token=#{@current_user.access_token}")
		return false if response.code == 401
		return JSON.parse(response.to_s)
	end
end
