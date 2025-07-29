class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    case event['type']
    when 'checkout.session.completed'
      handle_checkout_session_completed(event['data']['object'])
    when 'payment_intent.succeeded'
      handle_payment_intent_succeeded(event['data']['object'])
    when 'payment_intent.payment_failed'
      handle_payment_intent_failed(event['data']['object'])
    end

    render json: { received: true }
  end

  private

  def handle_checkout_session_completed(session)
    booking_id = session['metadata']['booking_id']
    booking = Booking.find(booking_id)
    
    booking.update(
      payment_processed: true,
      status: 'confirmed',
      stripe_session_id: session['id']
    )
  end

  def handle_payment_intent_succeeded(payment_intent)
    # Find booking by payment intent ID
    booking = Booking.find_by(stripe_payment_intent_id: payment_intent['id'])
    
    if booking
      booking.update(
        payment_processed: true,
        status: 'confirmed'
      )
    end
  end

  def handle_payment_intent_failed(payment_intent)
    # Find booking by payment intent ID
    booking = Booking.find_by(stripe_payment_intent_id: payment_intent['id'])
    
    if booking
      booking.update(status: 'payment_failed')
    end
  end
end
