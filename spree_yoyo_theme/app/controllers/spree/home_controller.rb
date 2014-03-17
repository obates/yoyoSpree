module Spree
  class HomeController < Spree::StoreController
    helper 'spree/products'
    respond_to :html

    def index
      @searcher = build_searcher(params)
      @products = @searcher.retrieve_products
      @orders = Order.find_all_by_user_id(spree_current_user, :limit => 3)
      @postcode = ""
    end

    def checkPostcode
    	@postcode = params[:postcode]
    	if @postcode
        @postcode = @postcode.upcase
        if @postcode.match('^(((([A-PR-UWYZ][0-9][0-9A-HJKS-UW]?)|([A-PR-UWYZ][A-HK-Y][0-9][0-9ABEHMNPRV-Y]?))\s{0,2}[0-9]([ABD-HJLNP-UW-Z]{2}))|(GIR\s{0,2}0AA))$')
	    	  flash[:success] = "Free delivery on orders over £10!"
	    	  redirect_to products_path
	      else
	    	  flash[:error] = "Sorry, we don't deliver to you (or an invalid postcode!)"
	    	  redirect_to :back
	      end
     end
    end
  end
end