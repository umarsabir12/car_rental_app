# lib/tasks/sedan_to_economy.rake
namespace :sedan_to_economy do
  desc "Sedan To Economy"
  task seed: :environment do
    puts "Starting to sedan cars"

    Car.where(category: 'Sedan').each do |car|
      car.category = 'Economy'
      car.save(validate: false)
    end
    
    puts "\n" + "="*50
    puts "Sedan car updating completed!"
    puts "="*50
  end
end