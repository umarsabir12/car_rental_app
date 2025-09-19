// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import flatpickr from "flatpickr"

console.log('Application.js loaded, flatpickr:', flatpickr);

// Make flatpickr available globally
window.flatpickr = flatpickr;

// Initialize flatpickr for any existing elements on page load
document.addEventListener('turbo:load', () => {
  initializeFlatpickr();
});

// Function to initialize flatpickr for elements outside modals
function initializeFlatpickr() {
  const dateInputs = document.querySelectorAll('.flatpickr:not(.modal .flatpickr), .test-flatpickr');
  
  dateInputs.forEach((input) => {
    // Destroy existing instance if it exists
    if (input._flatpickr) {
      input._flatpickr.destroy();
    }
    
    // Create new instance
    try {
      flatpickr(input, {
        dateFormat: "Y-m-d",
        minDate: "today",
        disable: JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]"),
        onChange: function(selectedDates, dateStr, instance) {
          // Date selection handled
        }
      });
      
      // Add styling to disabled dates after calendar is created
      setTimeout(() => {
        const bookedDates = JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]");
        
        const calendar = document.querySelector('.flatpickr-calendar');
        if (calendar) {
          const days = calendar.querySelectorAll('.flatpickr-day');
          days.forEach(day => {
            const dateStr = day.getAttribute('aria-label');
            if (dateStr) {
              const date = new Date(dateStr);
              const dateKey = date.toISOString().split('T')[0];
              if (bookedDates.includes(dateKey)) {
                day.classList.add('booked-date');
                day.style.backgroundColor = '#ef4444';
                day.style.color = 'white';
                day.style.fontWeight = 'bold';
                day.title = 'This date is already booked';
              }
            }
          });
        }
      }, 100);
    } catch (error) {
      console.error('Error creating flatpickr instance:', error);
    }
  });
}