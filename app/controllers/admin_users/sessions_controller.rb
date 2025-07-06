class AdminUsers::SessionsController < Devise::SessionsController
  layout :resolve_layout
  # You can add custom logic here if needed

  private

  def resolve_layout
    action_name == 'new' ? false : 'admin'
  end
end 