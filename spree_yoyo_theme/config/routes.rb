Spree::Core::Engine.routes.draw do
  namespace :admin do
  	resources :kitchens
  end
end
