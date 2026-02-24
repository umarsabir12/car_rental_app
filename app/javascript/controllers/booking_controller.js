import { Controller } from "@hotwired/stimulus"

console.log("DEBUG: booking_controller.js evaluation start")

export default class extends Controller {
    static targets = ["submitBtn", "startInput", "endInput"]
    static values = {
        withDriver: Boolean,
        carId: String
    }

    connect() {
        console.log("✅ Booking controller connected")
        console.log("carIdValue:", this.carIdValue)
        console.log("withDriverValue:", this.withDriverValue)
        this.validateForm()
    }

    validateForm() {
        const startValue = this.startInputTarget.value
        const endValue = this.hasEndInputTarget ? this.endInputTarget.value : null

        let isValid = false
        if (this.withDriverValue) {
            isValid = !!startValue
        } else {
            isValid = !!startValue && !!endValue
        }

        if (this.hasSubmitBtnTarget) {
            this.submitBtnTarget.disabled = !isValid
            if (isValid) {
                this.submitBtnTarget.style.pointerEvents = "auto"
                this.submitBtnTarget.style.opacity = "1"
                this.submitBtnTarget.style.cursor = "pointer"
            } else {
                this.submitBtnTarget.style.pointerEvents = "none"
                this.submitBtnTarget.style.opacity = "0.5"
                this.submitBtnTarget.style.cursor = "not-allowed"
            }
        }
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
        const carId = document.getElementById("bookingCarIdInput")?.value || this.carIdValue || ""
        console.log("Submitting with carId (Login):", carId)
        const params = new URLSearchParams({
            car_id: carId,
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

        const carId = document.getElementById("bookingCarIdInput")?.value || this.carIdValue || ""
        console.log("Submitting with carId (Create):", carId)

        const formData = new FormData()
        formData.append('booking[car_id]', carId)
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
