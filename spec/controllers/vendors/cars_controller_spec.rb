require 'rails_helper'

RSpec.describe Vendors::CarsController, type: :controller do
  let(:vendor) { create(:vendor) }
  let(:car) { create(:car, vendor: vendor) }

  describe 'GET #index' do
    context 'when vendor is authenticated' do
      before { sign_in_vendor(vendor) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns vendor cars' do
        vendor_car1 = create(:car, vendor: vendor)
        vendor_car2 = create(:car, vendor: vendor)
        other_car = create(:car)

        get :index
        expect(assigns(:cars)).to include(vendor_car1, vendor_car2)
        expect(assigns(:cars)).not_to include(other_car)
      end
    end

    context 'when vendor is not authenticated' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_vendor_session_path)
      end
    end
  end

  describe 'GET #show' do
    before { sign_in_vendor(vendor) }

    it 'returns http success' do
      get :show, params: { id: car.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested car' do
      get :show, params: { id: car.id }
      expect(assigns(:car)).to eq(car)
    end
  end
end
