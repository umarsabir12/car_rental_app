require 'rails_helper'

RSpec.describe "Cars Monthly Price Filter", type: :request do
  describe "GET /cars" do
    let!(:vendor) { create(:vendor) }

    # Car 1: 1000/month (no discount) -> Range 1000-1100
    let!(:car_standard) {
      create(:car, :with_approved_document,
        vendor: vendor,
        monthly_price: 1050,
        brand: 'Toyota',
        model: 'Camry',
        category: 'Economy'
      )
    }

    # Car 2: 2000/month (no discount) -> Range 2000-2100
    let!(:car_expensive) {
      create(:car, :with_approved_document,
        vendor: vendor,
        monthly_price: 2050,
        brand: 'BMW',
        model: 'X5',
        category: 'Luxury'
      )
    }

    # Car 3: 1500/month with 10% discount -> 1350 effective -> Range 1300-1400
    let!(:car_discounted) {
      create(:car, :with_approved_document,
        vendor: vendor,
        monthly_price: 1500,
        brand: 'Audi',
        model: 'A4',
        category: 'Sedan'
      )
    }

    let!(:discount) {
      create(:discount,
        vendor: vendor,
        discount_percentage: 10.0,
        active: true,
        category: [ 'Sedan' ]
      )
    }


    it "filters cars by simple monthly price range" do
      get cars_path, params: { monthly_price: "1000-1500" }
      expect(response).to have_http_status(:moved_permanently)
      follow_redirect!
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include(car_path(car_standard))
    end

    it "filters cars by discounted monthly price range" do
      # 1500 * 0.9 = 1350, so it should fall in 1000-1500
      get cars_path, params: { monthly_price: "1000-1500" }
      expect(response).to have_http_status(:moved_permanently)
      follow_redirect!
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include(car_path(car_discounted))
      expect(response.body).to include(car_path(car_standard))
    end

    it "filters cars in the 15000+ range" do
      car_super_expensive = create(:car, :with_approved_document, 
        vendor: vendor, 
        monthly_price: 20000, 
        brand: 'Ferrari', 
        model: 'SF90'
      )
      
      get cars_path, params: { monthly_price: "15000-plus" }
      expect(response).to have_http_status(:moved_permanently)
      follow_redirect!
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include(car_path(car_super_expensive))
      expect(response.body).not_to include(car_path(car_standard))
    end

    it "shows all cars when no filter is applied" do
      get cars_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include(car_path(car_standard))
      expect(response.body).to include(car_path(car_expensive))
      expect(response.body).to include(car_path(car_discounted))
    end
    
    it "excludes with-driver cars from the monthly price filter" do
      # Car 4: with-driver, 1000/month. Should NOT appear even in correct range.
      car_with_driver = create(:car, :with_approved_document, :with_driver, 
        vendor: vendor, 
        monthly_price: 1050, 
        brand: 'Mercedes', 
        model: 'Sprinter'
      )
      
      get cars_path, params: { monthly_price: "1000-1500" }
      expect(response).to have_http_status(:moved_permanently)
      follow_redirect!
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include(car_path(car_standard))
      expect(response.body).not_to include(car_path(car_with_driver))
    end

    it "redirects to pretty URL for monthly_price" do
      # When monthly_price is provided, it redirects to /cars/all-categories/all-brands/all-models/1000-1500
      get cars_path, params: { monthly_price: "1000-1500" }
      
      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to include("/cars/all-categories/all-brands/all-models/1000-1500")
    end

    it "preserves monthly_price in pretty URL when other filters exist" do
      get cars_path, params: { category: 'luxury', monthly_price: "2000-2500" }
      
      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to include("/cars/luxury/all-brands/all-models/2000-2500")
    end

    it "removes empty query parameters and commit during redirection" do
      # When search is empty and commit is present (default form submission)
      get cars_path, params: { monthly_price: "1000-1500", search: "", commit: "Search" }
      
      expect(response).to have_http_status(:moved_permanently)
      # Should NOT contain ?search= or commit=
      expect(response.location).to eq("http://www.example.com/cars/all-categories/all-brands/all-models/1000-1500")
    end

    it "handles invalid ranges gracefully" do
      get cars_path, params: { monthly_price: "invalid" }
      expect(response).to have_http_status(:moved_permanently)
      follow_redirect!
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include(car_path(car_standard))
    end
  end
end
