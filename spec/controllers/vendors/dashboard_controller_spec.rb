require 'rails_helper'

RSpec.describe Vendors::DashboardController, type: :controller do
  let(:vendor) { create(:vendor) }

  describe 'GET #index' do
    context 'when vendor is authenticated' do
      before { sign_in_vendor(vendor) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when vendor is not authenticated' do
      it 'redirects to vendor sign in' do
        get :index
        expect(response).to redirect_to(new_vendor_session_path)
      end
    end
  end
end
