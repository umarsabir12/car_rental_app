require 'rails_helper'

RSpec.describe Admin::VendorsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:vendor) { create(:vendor) }

  describe 'GET #index' do
    context 'when admin is authenticated' do
      before { sign_in_admin(admin) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns all vendors' do
        vendor1 = create(:vendor)
        vendor2 = create(:vendor)

        get :index
        expect(assigns(:vendors)).to include(vendor1, vendor2)
      end
    end

    context 'when admin is not authenticated' do
      it 'redirects to admin sign in' do
        get :index
        expect(response).to redirect_to(new_admin_session_path)
      end
    end
  end

  describe 'GET #show' do
    before { sign_in_admin(admin) }

    it 'returns http success' do
      get :show, params: { id: vendor.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested vendor' do
      get :show, params: { id: vendor.id }
      expect(assigns(:vendor)).to eq(vendor)
    end
  end
end
