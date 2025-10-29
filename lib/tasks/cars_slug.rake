# lib/tasks/cars_slug.rake
namespace :cars_slug do
  desc "Seed car slug"
  task seed: :environment do
    puts "Starting to seed cars slug..."

    Car.find_each do |car|
      car.save(validate: false)
    end
    
    puts "\n" + "="*50
    puts "Slug seeding completed!"
    puts "Total Cars in database: #{Car.count}"
    puts "="*50
  end
end