pin "application"
pin "controllers", to: "controllers/index.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "swiper", to: "swiper-bundle.min.js"
pin "flatpickr", to: "flatpickr.min.js"
