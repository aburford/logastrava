class WelcomeController < ApplicationController
  def index
    @logged_in = session[:user_id]
    if params[:error] == 'unauthorized'
      @error = 'Username/Password Incorrect'
    end
  end
end
