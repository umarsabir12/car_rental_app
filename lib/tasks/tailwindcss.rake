# Override tailwindcss-rails default paths.
# The gem expects input at app/assets/tailwind/application.css, but we moved it
# to app/tailwind/application.css to keep it out of the Sprockets asset pipeline.
Rake::Task["tailwindcss:build"].clear
Rake::Task["tailwindcss:watch"].clear

namespace :tailwindcss do
  task build: :environment do
    require "tailwindcss/ruby"

    input  = Rails.root.join("app/tailwind/application.css").to_s
    output = Rails.root.join("app/assets/builds/tailwind.css").to_s

    command = [ Tailwindcss::Ruby.executable, "-i", input, "-o", output, "--minify" ]
    system(*command, exception: true)
  end

  task watch: :environment do
    require "tailwindcss/ruby"

    input  = Rails.root.join("app/tailwind/application.css").to_s
    output = Rails.root.join("app/assets/builds/tailwind.css").to_s

    command = [ Tailwindcss::Ruby.executable, "-i", input, "-o", output, "-w" ]
    system(*command)
  end
end
