Spree::Core::Engine.routes.draw do
	post '/orders/:number/repeated_order' => 'repeated_orders#create', as: :repeat_order
	namespace :admin do
		resources :kitchens do
			member do
				post :inc_progress
			end
		end
	end

	namespace :home do
		post :checkPostcode
	end
end