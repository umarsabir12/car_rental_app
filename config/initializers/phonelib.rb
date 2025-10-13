require 'phonelib'

# Load phone number data
Phonelib.parse_special = true

# Optional: Set default country (use nil for international only)
# Phonelib.default_country = nil

# Strict mode for better validation
Phonelib.strict_check = true