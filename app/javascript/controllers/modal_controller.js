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
    const dateInputs = this.element.querySelectorAll('.flatpickr')

    console.log('Found flatpickr inputs:', dateInputs.length)

    dateInputs.forEach((input, index) => {
      if (input._flatpickr) {
        input._flatpickr.destroy()
      }

      flatpickr(input, {
        dateFormat: "Y-m-d",
        minDate: "today",
        disable: bookedDates,
        onChange: function(_, dateStr) {
          const event = new Event('change')
          input.dispatchEvent(event)
        }
      })

      console.log(`Flatpickr initialized for input ${index}`)
    })
  }
}
