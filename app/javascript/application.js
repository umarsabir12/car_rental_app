// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import flatpickr from "flatpickr"

console.log('Application.js loaded, flatpickr:', flatpickr);

// Make flatpickr available globally
window.flatpickr = flatpickr;

// Initialize flatpickr for any existing elements on page load
document.addEventListener('turbo:load', () => {
  console.log('Turbo load event fired');
  initializeFlatpickr();
});

// Function to initialize flatpickr for elements outside modals
function initializeFlatpickr() {
  console.log('Initializing flatpickr for non-modal elements...');
  const dateInputs = document.querySelectorAll('.flatpickr:not(.modal .flatpickr), .test-flatpickr');
  console.log('Found flatpickr inputs outside modals:', dateInputs.length);
  
  dateInputs.forEach((input, index) => {
    console.log(`Initializing input ${index}:`, input);
    // Destroy existing instance if it exists
    if (input._flatpickr) {
      console.log('Destroying existing flatpickr instance');
      input._flatpickr.destroy();
    }
    
    // Create new instance
    try {
      const instance = flatpickr(input, {
        dateFormat: "Y-m-d",
        minDate: "today",
        disable: JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]"),
        onChange: function(selectedDates, dateStr, instance) {
          console.log('Date selected:', dateStr);
        }
      });
      
      // Add styling to disabled dates after calendar is created
      setTimeout(() => {
        const bookedDates = JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]");
        console.log('Applying styling to booked dates:', bookedDates);
        
        const calendar = document.querySelector('.flatpickr-calendar');
        if (calendar) {
          const days = calendar.querySelectorAll('.flatpickr-day');
          days.forEach(day => {
            const dateStr = day.getAttribute('aria-label');
            if (dateStr) {
              const date = new Date(dateStr);
              const dateKey = date.toISOString().split('T')[0];
              if (bookedDates.includes(dateKey)) {
                console.log('Styling booked date:', dateKey);
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
      
      console.log('Flatpickr instance created:', instance);
    } catch (error) {
      console.error('Error creating flatpickr instance:', error);
    }
  });
}