module Vendors::FormHelper
  def whatsapp_number_field(form, options = {})
    options = {
      placeholder: '+1234567890',
      class: 'form-control',
      pattern: '\+[0-9]{7,15}',
      title: 'Enter phone number with country code (e.g., +1234567890)'
    }.merge(options)
    
    form.telephone_field :whatsapp_number, options
  end
end