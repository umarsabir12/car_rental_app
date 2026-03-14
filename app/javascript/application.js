import "@hotwired/turbo-rails"
import "controllers"
import flatpickr from "flatpickr"

// Make it available globally for inline scripts and helper functions
window.flatpickr = flatpickr.default || flatpickr;

console.log('🚀 application.js: flatpickr loaded');

// Global Form Loader Logic
document.addEventListener('turbo:load', () => {
  document.addEventListener('submit', (event) => {
    const form = event.target;
    if (form && form.getAttribute('data-show-loader') === 'true') {
      const loader = document.getElementById('global-loader');
      if (loader) {
        loader.classList.remove('hidden');

        // Prevent multiple submissions
        const submitButton = form.querySelector('[type="submit"]');
        if (submitButton) {
          submitButton.disabled = true;
          submitButton.classList.add('opacity-50', 'cursor-not-allowed');
        }
      }
    }
  });

  document.addEventListener('turbo:submit-end', (event) => {
    const form = event.target;
    if (form && form.getAttribute('data-show-loader') === 'true') {
      const loader = document.getElementById('global-loader');
      if (loader) {
        loader.classList.add('hidden');

        // Re-enable the submit button
        const submitButton = form.querySelector('[type="submit"]');
        if (submitButton) {
          submitButton.disabled = false;
          submitButton.classList.remove('opacity-50', 'cursor-not-allowed');
        }
      }
    }
  });
});