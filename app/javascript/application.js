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

// Reinitialize calendar when pricing period changes
window.addEventListener('pricing:period_changed', (e) => {
  initializeFlatpickr(e.detail?.period);
});

// Rebuild calendars when booking modal becomes visible
document.addEventListener('DOMContentLoaded', () => {
  const bookingModal = document.getElementById('bookingModal');
  if (bookingModal) {
    bookingModal.addEventListener('shown.bs.modal', function() {
      initializeFlatpickr();
    });
  }
});

// Function to initialize flatpickr for elements outside modals
function initializeFlatpickr(selectedPeriod = (document.getElementById('selectedPeriodInput')?.value || 'daily')) {
  const startInput = document.getElementById('startDateInput');
  const endInput = document.getElementById('endDateInput');
  const bookedDates = JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]");

  const dateKey = (d) => {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const da = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${da}`;
  };

  // Destroy existing instances
  [startInput, endInput].forEach((input) => {
    if (input && input._flatpickr) input._flatpickr.destroy();
  });

  const disableStartByPeriod = (date) => {
    const start = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const period = selectedPeriod || 'daily';
    const daysToCheck = period === 'weekly' ? 7 : (period === 'monthly' ? 30 : 1);
    for (let i = 0; i < daysToCheck; i++) {
      const d = new Date(start);
      d.setDate(start.getDate() + i);
      const key = dateKey(d);
      if (bookedDates.includes(key)) return true; // disable if any day is booked
    }
    return false;
  };

  const rangeHasBooking = (startDate, endDate) => {
    // inclusive check across range
    const start = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
    const end = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate());
    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
      const key = dateKey(d);
      if (bookedDates.includes(key)) return true;
    }
    return false;
  };

  // Start picker
  if (startInput) {
    try {
      flatpickr(startInput, {
        dateFormat: "Y-m-d",
        minDate: "today",
        disable: [disableStartByPeriod],
        onChange: function() {
          // when start changes, rebuild end picker
          initializeEndPicker(selectedPeriod);
        }
      });
    } catch (error) {
      console.error('Error creating start flatpickr instance:', error);
    }
  }

  // End picker depends on selected start
  initializeEndPicker(selectedPeriod);

  // helper to highlight booked days (optional visual)
  setTimeout(() => {
    const calendar = document.querySelector('.flatpickr-calendar');
    if (calendar) {
      const days = calendar.querySelectorAll('.flatpickr-day');
      days.forEach(day => {
        const dateStr = day.getAttribute('aria-label');
        if (dateStr) {
          const date = new Date(dateStr);
          const key = dateKey(date);
          if (bookedDates.includes(key)) {
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
}

// Expose for any external triggers
window.initializeBookingCalendars = initializeFlatpickr;

function initializeEndPicker(selectedPeriod = (document.getElementById('selectedPeriodInput')?.value || 'daily')) {
  const startInput = document.getElementById('startDateInput');
  const endInput = document.getElementById('endDateInput');
  const bookedDates = JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]");

  if (!endInput) return;

  if (endInput._flatpickr) endInput._flatpickr.destroy();

  const startStr = startInput?.value;
  const start = startStr ? new Date(startStr) : null;

  const periodLen = selectedPeriod === 'weekly' ? 7 : (selectedPeriod === 'monthly' ? 30 : 1);

  const rangeHasBooking = (startDate, endDate) => {
    const s = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
    const e = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate());
    for (let d = new Date(s); d <= e; d.setDate(d.getDate() + 1)) {
      const key = (function(dd){
        const y = dd.getFullYear();
        const m = String(dd.getMonth() + 1).padStart(2, '0');
        const da = String(dd.getDate()).padStart(2, '0');
        return `${y}-${m}-${da}`;
      })(d);
      if (bookedDates.includes(key)) return true;
    }
    return false;
  };

  try {
    flatpickr(endInput, {
      dateFormat: "Y-m-d",
      minDate: start ? startStr : "today",
      disable: [function(date) {
        // If no start selected, disable all dates
        if (!start) return true;
        const candidate = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        // End date must be >= start
        if (candidate < new Date(start.getFullYear(), start.getMonth(), start.getDate())) return true;

        const diffMs = candidate - start;
        const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24)) + 1; // inclusive length

        if (periodLen === 1) {
          // daily: allow any span with no bookings in range
          return rangeHasBooking(start, candidate);
        } else {
          // weekly/monthly: allow only multiples of periodLen (>= periodLen)
          if (diffDays < periodLen) return true;
          if (diffDays % periodLen !== 0) return true;
          return rangeHasBooking(start, candidate);
        }
      }]
    });
  } catch (error) {
    console.error('Error creating end flatpickr instance:', error);
  }
}