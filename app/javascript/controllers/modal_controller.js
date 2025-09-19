import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    // Listen for Bootstrap modal events
    this.element.addEventListener('shown.bs.modal', () => {
      // Use setTimeout to ensure DOM is ready
      setTimeout(() => {
        this.initializeFlatpickr()
      }, 200)
    })
  }

  initializeFlatpickr() {
    const bookedDates = JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]")
    const startInput = this.element.querySelector('#startDateInput')
    const endInput = this.element.querySelector('#endDateInput')

    if (!startInput || !endInput) {
      console.error('Date inputs not found in modal')
      return
    }

    // Destroy previous instances
    if (startInput._flatpickr) {
      startInput._flatpickr.destroy()
    }
    if (endInput._flatpickr) {
      endInput._flatpickr.destroy()
    }

    // Initialize start date picker
    try {
      flatpickr(startInput, {
        dateFormat: "Y-m-d",
        minDate: "today",
        disable: bookedDates,
        static: true, // Keep calendar in modal
        appendTo: this.element,
        onChange: function(selectedDates, dateStr) {
          const event = new Event('change')
          startInput.dispatchEvent(event)
          // Update end date picker's minDate
          if (endInput._flatpickr) {
            endInput._flatpickr.set('minDate', dateStr)
          }
        }
      })
    } catch (error) {
      console.error('Error creating start date picker:', error)
    }

    // Initialize end date picker
    try {
      flatpickr(endInput, {
        dateFormat: "Y-m-d",
        minDate: "today",
        disable: bookedDates,
        static: true, // Keep calendar in modal
        appendTo: this.element,
        onChange: function(_, dateStr) {
          const event = new Event('change')
          endInput.dispatchEvent(event)
        }
      })
    } catch (error) {
      console.error('Error creating end date picker:', error)
    }
  }
}
