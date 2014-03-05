class AddProgressToOrder < ActiveRecord::Migration
  def change
  	    add_column :spree_orders, :order_progress, :int, default: 0, null: false
  end
end
