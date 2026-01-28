import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["drawer", "title", "content"]
    static values = {
        insurance: String
    }

    open(event) {
        const type = event.currentTarget.dataset.policy
        const contentMap = {
            mileage: {
                title: 'Mileage Policy',
                content: 'Most rentals come with a daily mileage limit (200-250 km per day). Exceeding this limit will result in additional charges of AED 0.50 per extra kilometer.'
            },
            fuel: {
                title: 'Fuel Policy',
                content: 'The vehicle will be provided with a full tank of fuel. You are required to return the vehicle with the same fuel level.'
            },
            rental: {
                title: 'Rental Policy',
                content: "Renters must be at least 21 years old. UAE residents need a valid UAE driving license, and tourists must provide an International Driving Permit."
            },
            insurance: {
                title: 'Insurance Policy',
                content: this.insuranceValue || "No Insurance Provided"
            }
        }

        const policy = contentMap[type]
        if (!policy) return

        this.titleTarget.textContent = policy.title
        this.contentTarget.innerHTML = `<p>${policy.content}</p>`
        this.drawerTarget.setAttribute('aria-hidden', 'false')
        this.drawerTarget.classList.remove('translate-x-full')
    }

    close() {
        this.drawerTarget.setAttribute('aria-hidden', 'true')
        this.drawerTarget.classList.add('translate-x-full')
    }
}
