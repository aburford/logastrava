class Users::UsersController < ApplicationController
	before_action :authenticate_user, :only => [:index, :update, :exchange]

	def new
	end

	def index
		# check if account setup is complete: check strava authentication && LogARun visibility
		# @current_user
		@info = strava_info
	end

	def exchange
		render 'Unauthorized' if params[:error] == 'access_denied'
		data = StaticDatum.first
		form = {:client_id => data.client_id, :client_secret => data.client_secret, :code => params[:code]}
		json = JSON.parse(HTTP.post("https://www.strava.com/oauth/token", :form => form).to_s)
		@current_user.access_token = json['access_token']
		@current_user.save
		redirect_to users_root_path
	end

	def login
		u = User.find_by(username: user_params[:username])
		if u.try(:authenticate, user_params[:password])
			session[:user_id] = u.id
			redirect_to users_root_path
		else
			redirect_to root_path
		end
	end

	def create
		u = User.new(user_params)
  	if u.save
			session[:user_id] = u.id
	  	redirect_to users_root_path
		else
			redirect_to users_new_path
		end
	end

	def update
	end

	private
  def user_params
    params.require(:user).permit(:username, :password)
  end

	def logarun_synced?
		doc = Nokogiri::HTML(HTTP.cookies(:sqlAuthCookie => ENV['SQL_AUTH_ID']).get("http://www.logarun.com/TeamCalendar.aspx?teamid=1820&date=#{Date.today.strftime('%m-%d-%Y')}").to_s)
		doc.css('div.day>a').inner_html.include? @current_user.username
	end

	def strava_info
		return false unless @current_user.access_token
		response = HTTP.get("https://www.strava.com/api/v3/athlete?access_token=#{@current_user.access_token}")
		return false if response.code == 401
		return JSON.parse(response.to_s)
	end
end
