import "@hotwired/turbo-rails"
import "controllers"
import flatpickr from "flatpickr"

// Make it available globally for inline scripts and helper functions
window.flatpickr = flatpickr.default || flatpickr;

console.log('🚀 application.js: flatpickr loaded');