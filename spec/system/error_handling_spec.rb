require 'rails_helper'

RSpec.describe 'Error Handling and Flash Messages', type: :system do
  let(:vendor) { create(:vendor) }
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
  end

  describe 'Flash Messages' do
    it 'displays success notice after successful car creation' do
      login_as(vendor, scope: :vendor)
      visit vendors_new_car_path
      
      fill_in 'car[brand]', with: 'Toyota'
      fill_in 'car[model]', with: 'Camry'
      fill_in 'car[color]', with: 'White'
      fill_in 'car[year]', with: '2023'
      fill_in 'car[daily_price]', with: '200'
      fill_in 'car[insurance_policy]', with: 'Valid insurance policy for testing purposes.'
      select 'Luxury', from: 'car_category_select'
      
      # Attach images and mulkiya
      attach_file 'car_image_0', Rails.root.join('spec/fixtures/files/test_image.jpg'), visible: false
      attach_file 'car_mulkiya', Rails.root.join('spec/fixtures/files/test_document.pdf'), visible: false
      
      click_button 'Add Car'
      
      expect(page).to have_content('Car was successfully created.')
      expect(page).to have_css('.bg-teal-50', visible: false)
    end

    it 'displays alert message on failed vendor request' do
      visit new_vendor_request_path
      within('.hero-section') do
        fill_in 'vendor_request[first_name]', with: '' # Invalid
        click_button 'Submit Request'
      end

      expect(page).to have_content('Error:')
      expect(page).to have_css('.bg-red-50')
    end
  end

  describe 'Form Validation Errors' do
    it 'shows specific field errors in vendor request form' do
      visit new_vendor_request_path
      within('.hero-section') do
        fill_in 'vendor_request[first_name]', with: ''
        fill_in 'vendor_request[email]', with: 'invalid-email'
        click_button 'Submit Request'
      end

      within('.bg-red-50.border-l-4') do # Shared form errors container
        expect(page).to have_content("First name can't be blank")
        expect(page).to have_content("Email is invalid")
      end
    end

    it 'shows field-level errors when editing profile' do
      login_as(user, scope: :user)
      visit edit_user_path(user)
      
      fill_in 'user[first_name]', with: ''
      click_button 'Update Profile'
      
      expect(page).to have_content('Error:')
      expect(page).to have_content("First name can't be blank")
    end
  end

  describe 'Admin Flash Messages' do
    let(:admin) { create(:admin) }
    
    it 'displays flash messages in admin layout' do
      login_as(admin, scope: :admin)
      visit admin_settings_path
      
      click_link 'Clear Cache'
      
      within('body') do
        expect(page).to have_content('Cache cleared successfully!')
      end
      expect(page).to have_css('.bg-teal-50', visible: false)
    end
  end
end
