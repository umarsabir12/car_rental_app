require 'rails_helper'

RSpec.describe VendorRequestsController, type: :controller do
  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          vendor_request: {
            first_name: 'John',
            last_name: 'Doe',
            email: 'john@example.com',
            company_name: 'Test Company',
            vehicle_count: 10
          }
        }
      end

      before do
        # Stub the mailer to prevent actual email delivery in tests
        allow(VendorMailer).to receive(:request_email).and_return(double(deliver_now: true))
      end

      it 'creates a new vendor request' do
        expect {
          post :create, params: valid_params
        }.to change(VendorRequest, :count).by(1)
      end

      it 'redirects after successful creation' do
        post :create, params: valid_params
        expect(response).to have_http_status(:redirect)
      end

      it 'sends vendor request email' do
        expect(VendorMailer).to receive(:request_email).and_return(double(deliver_now: true))
        post :create, params: valid_params
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          vendor_request: {
            first_name: '',
            email: 'invalid'
          }
        }
      end

      it 'does not create a vendor request' do
        expect {
          post :create, params: invalid_params
        }.not_to change(VendorRequest, :count)
      end
    end
  end
end
