Spree::Core::Engine.routes.draw do
  namespace :admin do
  	resources :kitchens do
  		member do
  			post :inc_progress
  		end
  	end
  end
end