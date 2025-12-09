require 'rails_helper'

RSpec.describe Users::BookingsController, type: :controller do
  let(:user) { create(:user, :with_approved_documents) }

  describe 'GET #index' do
    context 'when user is authenticated' do
      before { sign_in_user(user) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns user bookings' do
        booking1 = create(:booking, user: user)
        booking2 = create(:booking, user: user)
        other_booking = create(:booking)

        get :index
        expect(assigns(:bookings)).to include(booking1, booking2)
        expect(assigns(:bookings)).not_to include(other_booking)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
