# lib/tasks/features.rake
namespace :features do
  desc "Seed car features (common and premium)"
  task seed: :environment do
    puts "Starting to seed car features..."

    common_features = [
      "Airbags",
      "Anti-lock Brakes (ABS)",
      "Child Safety Locks",
      "Seat Belt Reminder",
      "Air Conditioning",
      "Power Windows & Locks",
      "Bluetooth/USB Connectivity",
      "Alloy Wheels",
      "Parking Sensors",
      "Power Side Mirrors",
      "Steering Wheel Controls"
    ]

    premium_features = [
      "Surround/360° Camera",
      "Blind Spot Warning",
      "Lane Keeping Assist",
      "Adaptive Cruise Control",
      "Parking Assist",
      "Leather Seats",
      "Powered/Memory Seats",
      "Heated/Cooled Seats",
      "Sunroof/Panoramic Roof",
      "Multi-zone Climate Control",
      "Touchscreen Display",
      "GPS Navigation",
      "Apple CarPlay/Android Auto",
      "Wireless Charging",
      "LED Headlights",
      "Power Liftgate",
      "All-Wheel Drive"
    ]

    # Add common features
    common_count = 0
    common_features.each do |feature_name|
      feature = Feature.find_or_create_by(name: feature_name) do |f|
        f.common = true
      end

      if feature.persisted? && feature.previously_new_record?
        common_count += 1
        puts "✓ Added common feature: #{feature_name}"
      else
        puts "- Skipped (already exists): #{feature_name}"
      end
    end

    # Add premium features
    premium_count = 0
    premium_features.each do |feature_name|
      feature = Feature.find_or_create_by(name: feature_name) do |f|
        f.common = false
      end

      if feature.persisted? && feature.previously_new_record?
        premium_count += 1
        puts "★ Added premium feature: #{feature_name}"
      else
        puts "- Skipped (already exists): #{feature_name}"
      end
    end

    puts "\n" + "="*50
    puts "Feature seeding completed!"
    puts "Common features added: #{common_count}"
    puts "Premium features added: #{premium_count}"
    puts "Total features in database: #{Feature.count}"
    puts "="*50
  end
end
