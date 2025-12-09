require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  let(:admin) { create(:admin) }

  describe 'GET #index' do
    context 'when admin is authenticated' do
      before { sign_in_admin(admin) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
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
