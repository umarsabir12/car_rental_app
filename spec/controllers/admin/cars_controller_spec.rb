require 'rails_helper'

RSpec.describe Admin::CarsController, type: :controller do
  let(:admin) { create(:admin) }

  describe 'GET #index' do
    context 'when admin is authenticated' do
      before { sign_in_admin(admin) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns all cars' do
        car1 = create(:car)
        car2 = create(:car)

        get :index
        expect(assigns(:cars)).to include(car1, car2)
      end
    end

    context 'when admin is not authenticated' do
      it 'redirects to admin sign in' do
        get :index
        expect(response).to redirect_to(new_admin_session_path)
      end
    end
  end
end
