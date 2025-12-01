class Users::PaymentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @booking = current_user.bookings.find(params[:id])
    @car = @booking.car
    @days = [(@booking.end_date - @booking.start_date).to_i, 1].max
    @total_amount = @booking.calculate_total_amount
    @selected_period = @booking.selected_period || 'daily'
  end

  def create_checkout
    @booking = current_user.bookings.find(params[:id])
    @car = @booking.car
    days = [(@booking.end_date - @booking.start_date).to_i, 1].max
    total_amount = @booking.calculate_total_amount

    begin
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        customer_email: current_user.email,
        line_items: [{
          price_data: {
            currency: 'aed',
            product_data: {
              name: "#{@car.brand} #{@car.model} - Car Rental",
              description: "#{days} day rental from #{@booking.start_date.strftime('%B %d')} to #{@booking.end_date.strftime('%B %d, %Y')}"
            },
            unit_amount: (total_amount * 100).to_i
          },
          quantity: 1
        }],
        mode: 'payment',
        success_url: success_users_payment_url(@booking),
        cancel_url: cancel_users_payment_url(@booking),
        metadata: {
          booking_id: @booking.id.to_s,
          car_id: @car.id.to_s,
          user_id: @booking.user.id.to_s
        },
        invoice_creation: {enabled: true }
      )
      
      redirect_to session.url, allow_other_host: true, status: 303
    rescue => e
      redirect_to users_payment_path(@booking), alert: "Payment error: #{e.message}"
    end
  end

  def success
    @booking = current_user.bookings.find(params[:id])
    @booking.update(payment_processed: true, status: 'confirmed')
    redirect_to user_home_path, notice: 'Payment successful! Your booking is now confirmed.'
  end

  def cancel
    @booking = current_user.bookings.find(params[:id])
    redirect_to user_home_path, alert: 'Payment was cancelled. Your booking remains pending.'
  end
end