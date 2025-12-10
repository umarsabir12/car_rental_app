# FactoryBot configuration
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Disable transactional fixtures when using FactoryBot
  config.use_transactional_fixtures = true
end
