Rails.application.routes.draw do
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	root 'welcome#index'

	namespace 'users' do
		post '/login' => 'users#login'
		post '/' => 'users#create'
		root 'users#index', format: 'html'
		get '/settings' => 'users#index'
		post '/update' => 'users#update'
		get '/new' => 'users#new'
		get '/exchange' => 'users#exchange'
	end
end
