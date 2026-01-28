import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
    static values = {
        minDate: { type: String, default: "today" },
        dateFormat: { type: String, default: "Y-m-d" }
    }

    connect() {
        this.initializeFlatpickr()
    }

    disconnect() {
        if (this.fp) {
            this.fp.destroy()
        }
    }

    initializeFlatpickr() {
        const bookedDates = JSON.parse(document.querySelector('meta[name="booked-dates"]')?.content || "[]")

        this.fp = flatpickr(this.element, {
            minDate: this.minDateValue,
            dateFormat: this.dateFormatValue,
            disable: bookedDates,
            static: true,
            appendTo: this.element.closest('.modal-content') || document.body,
            onChange: (selectedDates, dateStr) => {
                // Trigger a native change event so other listeners (like price calculators) react
                this.element.dispatchEvent(new Event('change', { bubbles: true }))
            }
        })
    }
}
