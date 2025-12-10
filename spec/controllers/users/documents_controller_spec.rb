require 'rails_helper'

RSpec.describe Users::DocumentsController, type: :controller do
  let(:user) { create(:user, :with_documents) }

  describe 'GET #index' do
    context 'when user is authenticated' do
      before { sign_in_user(user) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns current user' do
        get :index
        expect(assigns(:user)).to eq(user)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
