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

      context 'with filter param' do
        let!(:driver_car) { create(:car, :with_driver, vendor: vendor) }
        let!(:normal_car) { create(:car, vendor: vendor, with_driver: false) }

        it 'filters by with_driver' do
          get :index, params: { filter: 'with_driver' }
          expect(assigns(:cars)).to include(driver_car)
          expect(assigns(:cars)).not_to include(normal_car)
        end
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

  describe 'POST #create' do
    before { sign_in_vendor(vendor) }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          car: {
            brand: 'Toyota',
            model: 'Camry',
            category: 'Economy',
            daily_price: 100,
            insurance_policy: 'Full Coverage',
            images: [ fixture_file_upload('test_image.jpg', 'image/jpeg') ],
            mulkiya: fixture_file_upload('test_image.jpg', 'image/jpeg')
          }
        }
      end

      it 'creates a new car' do
        expect {
          post :create, params: valid_params
        }.to change(Car, :count).by(1)
      end

      it 'redirects to vendors_car_thank_you_path' do
        post :create, params: valid_params
        expect(response).to redirect_to(vendors_car_thank_you_path)
      end
    end
  end

  describe 'GET #thank_you' do
    before { sign_in_vendor(vendor) }

    it 'returns http success' do
      get :thank_you
      expect(response).to have_http_status(:success)
    end

    it 'renders the thank_you template' do
      get :thank_you
      expect(response).to render_template(:thank_you)
    end
  end
end
