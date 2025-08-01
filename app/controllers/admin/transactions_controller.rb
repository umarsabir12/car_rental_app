class Admin::TransactionsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_transaction, only: [:show, :refund]

  def index
    @transactions = Transaction.includes(:booking => [:user, :car])
                            #   .recent
                            #   .page(params[:page])
                            #   .per(20)
    
    # Filter by status
    @transactions = @transactions.where(status: params[:status]) if params[:status].present?
    
    # Filter by transaction type
    @transactions = @transactions.where(transaction_type: params[:type]) if params[:type].present?
    
    # Search by booking ID or user email
    if params[:search].present?
      @transactions = @transactions.joins(booking: :user)
                                  .where("bookings.id = ? OR users.email ILIKE ?", 
                                         params[:search].to_i, "%#{params[:search]}%")
    end
  end

  def show
    @booking = @transaction.booking
    @user = @booking.user
    @car = @booking.car
  end

  def refund
    if @transaction.refundable?
      amount = params[:refund_amount].present? ? params[:refund_amount].to_f : @transaction.amount
      reason = params[:refund_reason]
      
      if @transaction.refund!(amount: amount, reason: reason)
        redirect_to admin_transaction_path(@transaction), notice: 'Refund processed successfully.'
      else
        redirect_to admin_transaction_path(@transaction), alert: "Refund failed: #{@transaction.errors.full_messages.join(', ')}"
      end
    else
      redirect_to admin_transaction_path(@transaction), alert: 'This transaction cannot be refunded.'
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end
end 