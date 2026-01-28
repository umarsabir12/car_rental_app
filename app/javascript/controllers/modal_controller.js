import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    this.element.addEventListener('shown.bs.modal', () => {
      this.initializeCalendars()
    })

    // Listen for period changes to re-init calendars if they are already open
    this.periodChangedHandler = (e) => this.initializeCalendars(e.detail?.period)
    window.addEventListener('pricing:period_changed', this.periodChangedHandler)
  }

  disconnect() {
    window.removeEventListener('pricing:period_changed', this.periodChangedHandler)
  }

  initializeCalendars(period = null) {
    const selectedPeriod = period || document.getElementById('selectedPeriodInput')?.value || 'daily'
    const bookedDates = JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]")
    const startInput = this.element.querySelector('#startDateInput')
    const endInput = this.element.querySelector('#endDateInput')

    if (!startInput) return

    console.log(`📅 Initializing calendars for period: ${selectedPeriod}`)

    // Clean up old instances
    if (startInput._flatpickr) startInput._flatpickr.destroy()
    if (endInput && endInput._flatpickr) endInput._flatpickr.destroy()

    const periodLen = selectedPeriod === 'weekly' ? 7 : (selectedPeriod === 'monthly' ? 30 : 1)

    // Setup Start Picker
    const startFp = flatpickr(startInput, {
      dateFormat: "Y-m-d",
      minDate: "today",
      disable: bookedDates,
      static: true,
      appendTo: this.element.querySelector('.modal-content'),
      onChange: (selectedDates, dateStr) => {
        startInput.dispatchEvent(new Event('change', { bubbles: true }))
        this.updateEndPicker(endInput, dateStr, periodLen, bookedDates)
      }
    })

    // Initial end picker setup
    this.updateEndPicker(endInput, startInput.value, periodLen, bookedDates)
  }

  updateEndPicker(endInput, startDateStr, periodLen, bookedDates) {
    if (!endInput) return
    if (endInput._flatpickr) endInput._flatpickr.destroy()

    const start = startDateStr ? new Date(startDateStr) : null

    flatpickr(endInput, {
      dateFormat: "Y-m-d",
      minDate: startDateStr || "today",
      disable: [
        (date) => {
          if (!start) return true
          const candidate = new Date(date.getFullYear(), date.getMonth(), date.getDate())
          const diffDays = Math.floor((candidate - start) / (1000 * 60 * 60 * 24)) + 1

          if (periodLen > 1) {
            if (diffDays < periodLen || diffDays % periodLen !== 0) return true
          }

          // Check for bookings in range
          return this.rangeHasBooking(start, candidate, bookedDates)
        }
      ],
      static: true,
      appendTo: this.element.querySelector('.modal-content'),
      onChange: () => {
        endInput.dispatchEvent(new Event('change', { bubbles: true }))
      }
    })
  }

  rangeHasBooking(start, end, bookedDates) {
    const s = new Date(start)
    const e = new Date(end)
    for (let d = new Date(s); d <= e; d.setDate(d.getDate() + 1)) {
      const y = d.getFullYear()
      const m = String(d.getMonth() + 1).padStart(2, '0')
      const da = String(d.getDate()).padStart(2, '0')
      const key = `${y}-${m}-${da}`
      if (bookedDates.includes(key)) return true
    }
    return false
  }
}
