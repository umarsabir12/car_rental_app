require 'rails_helper'

RSpec.describe Admin::FeaturedCarsController, type: :controller do
  let(:admin) { create(:admin) }
  let!(:car) { create(:car, featured: false) }

  before { sign_in_admin(admin) }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns cars ordered by featured status' do
      featured_car = create(:car, featured: true)
      get :index
      expect(assigns(:cars)).to eq([featured_car, car].sort_by { |c| [c.featured ? 0 : 1, -c.id] })
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates the car featured status' do
        patch :update, params: { id: car.id, car: { featured: true } }
        car.reload
        expect(car.featured).to be true
      end

      it 'redirects to index on html format' do
        patch :update, params: { id: car.id, car: { featured: true } }
        expect(response).to redirect_to(admin_featured_cars_path)
      end

      it 'returns json success on json format' do
        patch :update, params: { id: car.id, car: { featured: true } }, format: :json
        expect(response.content_type).to include('application/json')
        expect(JSON.parse(response.body)['success']).to be true
      end
    end
  end
end
