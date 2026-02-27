require 'rails_helper'

RSpec.describe CarsController, type: :controller do
  describe 'GET #index' do
    let!(:available_car) { create(:car, :with_approved_document, category: 'SUV', brand: 'BMW') }
    let!(:car_without_document) { create(:car, category: 'Sedan') }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'only shows cars with approved mulkiya' do
      get :index
      expect(assigns(:cars)).to include(available_car)
      expect(assigns(:cars)).not_to include(car_without_document)
    end

    it 'filters by category' do
      # Skip redirect for this test
      allow(controller).to receive(:redirect_query_params)
      get :index, params: { category: 'suv' }
      expect(assigns(:cars)).to include(available_car)
    end

    it 'filters by brand' do
      # Skip redirect for this test
      allow(controller).to receive(:redirect_query_params)
      get :index, params: { brand: 'bmw' }
      expect(assigns(:cars)).to include(available_car)
    end

    it 'assigns categories' do
      get :index
      expect(assigns(:car_categories)).to be_an(Array)
    end

    it 'assigns brands' do
      get :index
      expect(assigns(:car_brands)).to be_an(Array)
    end

    context 'when filtering by with-driver' do
      let!(:driver_car) { create(:car, :with_approved_document, :with_driver) }
      let!(:normal_car) { create(:car, :with_approved_document, with_driver: false) }

      it 'sets session and redirects when with_driver param is passed' do
        get :index, params: { with_driver: 'true' }
        expect(session[:with_driver]).to be true
        expect(response).to redirect_to(cars_path)
      end

      it 'returns only cars with driver when session is set' do
        session[:with_driver] = true
        get :index
        expect(assigns(:cars)).to include(driver_car)
        expect(assigns(:cars)).not_to include(normal_car)
      end
    end
  end

  describe 'GET #show' do
    let(:car) { create(:car, :with_approved_document) }

    it 'returns http success' do
      get :show, params: { id: car.slug }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested car' do
      get :show, params: { id: car.slug }
      expect(assigns(:car)).to eq(car)
    end

    it 'assigns booked dates' do
      create(:booking, :confirmed, car: car, start_date: Date.today, end_date: Date.today + 2.days)
      get :show, params: { id: car.slug }
      expect(assigns(:booked_dates)).to be_an(Array)
    end

    it 'assigns recommended cars' do
      create(:car, :with_approved_document, category: 'SUV')
      create(:car, :with_approved_document, category: 'Luxury')
      get :show, params: { id: car.slug }
      expect(assigns(:recommended_cars)).to be_an(Array)
    end
  end

  describe 'GET #search_cars' do
    let!(:bmw_car) { create(:car, :with_approved_document, brand: 'BMW', model: 'X5', year: 2023) }
    let!(:audi_car) { create(:car, :with_approved_document, brand: 'Audi', model: 'A4', year: 2022) }

    it 'returns JSON response' do
      get :search_cars, params: { query: 'BMW' }, format: :json
      expect(response.content_type).to include('application/json')
    end

    it 'returns search results matching brand' do
      get :search_cars, params: { query: 'BMW' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response['results']).not_to be_empty
    end

    it 'returns empty results for short queries' do
      get :search_cars, params: { query: 'B' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response['results']).to be_empty
    end
  end

  describe 'GET #filter_options' do
    let!(:suv_bmw) { create(:car, :with_approved_document, category: 'SUV', brand: 'BMW', model: 'X5') }
    let!(:sedan_audi) { create(:car, :with_approved_document, category: 'Sedan', brand: 'Audi', model: 'A4') }

    it 'returns filtered brands when category is selected' do
      get :filter_options, params: { category: 'SUV' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response['filtered_brands']).to include('BMW')
    end

    it 'returns filtered categories when brand is selected' do
      get :filter_options, params: { brand: 'Audi' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response['filtered_categories']).to include('Sedan')
    end

    it 'returns filtered models' do
      get :filter_options, params: { brand: 'BMW' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response['filtered_models']).to include('X5')
    end
  end
end
