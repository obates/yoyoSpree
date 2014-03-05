module Spree
  module Admin
    class KitchensController < Spree::Admin::BaseController

      before_filter :initialize_order_events
      before_filter :load_order, :only => [:edit, :update, :cancel, :resume, :approve, :resend, :open_adjustments, :close_adjustments]

      respond_to :html

      def index
        @orders = Order.where("order_progress = ? and created_at > ? and state == ?",0,Time.at(params[:after].to_i + 1),"complete")
      end

      def show
        @orders = Order.where("order_progress = ? and created_at > ? and state == ?",0,Time.at(params[:after].to_i + 1),"complete")
      end
      
      def new
        @order = Order.create
        @order.created_by = try_spree_current_user
        @order.save
        redirect_to edit_admin_order_url(@order)
      end

      def edit
        unless @order.complete?
          @order.refresh_shipment_rates
        end
      end

      def inc_progress
        @order = Order.find(params[:id])
        @order.order_progress += 1
        @order.save

        @orders = Order.where(order_progress:0)

        respond_to do |format|
          format.js {}
          #format.html {render :layout => false}
        end
      end

      def update
        if @order.update_attributes(params[:order]) && @order.line_items.present?
          @order.update!
          unless @order.complete?
            # Jump to next step if order is not complete.
            redirect_to admin_order_customer_path(@order) and return
          end
        else
          @order.errors.add(:line_items, Spree.t('errors.messages.blank')) if @order.line_items.empty?
        end

        render :action => :edit
      end

      def cancel
        @order.cancel!
        flash[:success] = Spree.t(:order_canceled)
        redirect_to :back
      end

      def resume
        @order.resume!
        flash[:success] = Spree.t(:order_resumed)
        redirect_to :back
      end

      def approve
        @order.approved_by(try_spree_current_user)
        flash[:success] = Spree.t(:order_approved)
        redirect_to :back
      end

      def resend
        OrderMailer.confirm_email(@order.id, true).deliver
        flash[:success] = Spree.t(:order_email_resent)

        redirect_to :back
      end

      def open_adjustments
        adjustments = @order.adjustments.where(:state => 'closed')
        adjustments.update_all(:state => 'open')
        flash[:success] = Spree.t(:all_adjustments_opened)

        respond_with(@order) { |format| format.html { redirect_to :back } }
      end

      def close_adjustments
        adjustments = @order.adjustments.where(:state => 'open')
        adjustments.update_all(:state => 'closed')
        flash[:success] = Spree.t(:all_adjustments_closed)

        respond_with(@order) { |format| format.html { redirect_to :back } }
      end

      private
      def load_order
        @order = Order.includes(:adjustments).find_by_number!(params[:id])
        authorize! action, @order
      end

        # Used for extensions which need to provide their own custom event links on the order details view.
        def initialize_order_events
          @order_events = %w{approve cancel resume}
        end

        def model_class
          Spree::Order
        end
      end
    end
  end