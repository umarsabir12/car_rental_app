import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitBtn", "startInput", "endInput"]
  static values = {
    carId: String,
    withDriver: Boolean
  }

  submit(event) {
    event.preventDefault()
    const startValue = this.startInputTarget.value
    const endValue = this.withDriverValue ? startValue : (this.hasEndInputTarget ? this.endInputTarget.value : startValue)

    if (!startValue || (!this.withDriverValue && !endValue)) {
      alert("Please select " + (this.withDriverValue ? "a pickup date." : "both dates."))
      return
    }

    if (this.submitBtnTarget.id === "continueToLoginLink") {
      this.redirectToLogin(startValue, endValue)
    } else {
      this.createBooking(startValue, endValue)
    }
  }

  redirectToLogin(start, end) {
    const params = new URLSearchParams({
      car_id: this.carIdValue,
      start_date: start,
      end_date: end,
      selected_period: document.getElementById("selectedPeriodInput")?.value || "daily",
      selected_price: document.getElementById("selectedPriceInput")?.value || "0",
      selected_mileage_limit: document.getElementById("selectedMileageInput")?.value || "0",
      delivery_option: document.querySelector('input[name="delivery_option"]:checked')?.value || ""
    })
    window.location.href = `/users/sign_in?${params.toString()}`
  }

  async createBooking(start, end) {
    this.submitBtnTarget.disabled = true
    this.submitBtnTarget.textContent = "Creating..."

    const formData = new FormData()
    formData.append('booking[car_id]', this.carIdValue)
    formData.append('booking[start_date]', start)
    formData.append('booking[end_date]', end)
    formData.append('booking[selected_period]', document.getElementById("selectedPeriodInput")?.value || 'daily')
    formData.append('booking[selected_price]', document.getElementById("selectedPriceInput")?.value || '0')
    formData.append('booking[selected_mileage_limit]', document.getElementById("selectedMileageInput")?.value || '0')
    formData.append('booking[delivery_option]', document.querySelector('input[name="delivery_option"]:checked')?.value || "")

    try {
      const response = await fetch('/bookings', {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })

      if (response.redirected) {
        window.location.href = response.url
      } else {
        throw new Error('Booking failed')
      }
    } catch (error) {
      console.error(error)
      alert('There was an error creating your booking.')
      this.submitBtnTarget.disabled = false
      this.submitBtnTarget.textContent = "Create Booking"
    }
  }
}
