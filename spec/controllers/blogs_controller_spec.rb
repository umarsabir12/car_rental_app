require 'rails_helper'

RSpec.describe BlogsController, type: :controller do
  describe 'GET #index' do
    let!(:published_blog) { create(:blog, :published) }
    let!(:draft_blog) { create(:blog, :draft) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns only published blogs' do
      get :index
      expect(assigns(:blogs)).to include(published_blog)
      expect(assigns(:blogs)).not_to include(draft_blog)
    end
  end

  describe 'GET #show' do
    let(:blog) { create(:blog, :published) }

    it 'returns http success' do
      get :show, params: { slug: blog.slug }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested blog' do
      get :show, params: { slug: blog.slug }
      expect(assigns(:blog)).to eq(blog)
    end
  end
end
