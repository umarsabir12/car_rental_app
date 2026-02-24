require 'rails_helper'

RSpec.describe BookingsController, type: :controller do
  let(:user) { create(:user, :with_approved_documents) }
  let(:car) { create(:car) }

  describe 'POST #create' do
    context 'when user is authenticated' do
      before { sign_in_user(user) }

      context 'with valid parameters' do
        let(:valid_params) do
          {
            booking: {
              car_id: car.id,
              start_date: Date.tomorrow,
              end_date: Date.tomorrow + 7.days,
              selected_period: 'weekly',
              selected_price: car.weekly_price
            }
          }
        end

        it 'creates a new booking' do
          expect {
            post :create, params: valid_params
          }.to change(Booking, :count).by(1)
        end

        it 'sets user_id to current_user' do
          post :create, params: valid_params
          expect(Booking.last.user_id).to eq(user.id)
        end

        it 'sets payment_processed to false' do
          post :create, params: valid_params
          expect(Booking.last.payment_processed).to be false
        end

        it 'redirects to thank_you_bookings_path' do
          post :create, params: valid_params
          expect(response).to redirect_to(thank_you_bookings_path)
        end

        it 'sets a success notice' do
          post :create, params: valid_params
          expect(flash[:notice]).to match(/Booking created/)
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            booking: {
              car_id: car.id,
              start_date: Date.tomorrow,
              end_date: Date.yesterday,
              selected_period: 'weekly',
              selected_price: car.weekly_price
            }
          }
        end

        it 'does not create a booking' do
          expect {
            post :create, params: invalid_params
          }.not_to change(Booking, :count)
        end

        it 'redirects to car page' do
          post :create, params: invalid_params
          expect(response).to redirect_to(car_path(car.id))
        end

        it 'sets an alert message' do
          post :create, params: invalid_params
          expect(flash[:alert]).to be_present
        end
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        post :create, params: { booking: { car_id: car.id } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #thank_you' do
    context 'when user is authenticated' do
      before { sign_in_user(user) }

      it 'returns http success' do
        get :thank_you
        expect(response).to have_http_status(:success)
      end

      it 'renders the thank_you template' do
        get :thank_you
        expect(response).to render_template(:thank_you)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        get :thank_you
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
