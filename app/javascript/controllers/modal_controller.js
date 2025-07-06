import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    console.log("✅ ModalController connected")

    this.element.addEventListener('show.bs.modal', () => {
      console.log("Modal about to show, initializing flatpickr")
      this.initializeFlatpickr()
    })
  }

  initializeFlatpickr() {
    const bookedDates = JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]")
    const startInput = this.element.querySelector('#startDateInput')
    const endInput = this.element.querySelector('#endDateInput')

    // Destroy previous instances if any
    if (startInput && startInput._flatpickr) startInput._flatpickr.destroy()
    if (endInput && endInput._flatpickr) endInput._flatpickr.destroy()

    // Initialize start date picker
    flatpickr(startInput, {
      dateFormat: "Y-m-d",
      minDate: "today",
      disable: bookedDates,
      onChange: function(selectedDates, dateStr) {
        const event = new Event('change')
        startInput.dispatchEvent(event)
        // Update end date picker's minDate
        if (endInput && endInput._flatpickr) {
          endInput._flatpickr.set('minDate', dateStr)
        }
      }
    })

    // Initialize end date picker
    flatpickr(endInput, {
      dateFormat: "Y-m-d",
      minDate: "today",
      disable: bookedDates,
      onChange: function(_, dateStr) {
        const event = new Event('change')
        endInput.dispatchEvent(event)
      }
    })

    console.log('Flatpickr initialized for start and end date inputs')
  }
}
