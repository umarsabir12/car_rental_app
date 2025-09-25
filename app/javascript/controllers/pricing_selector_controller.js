import { Controller } from "@hotwired/stimulus"

// Handles selecting pricing tier and updating UI + hidden inputs
export default class extends Controller {
  static targets = [
    "card",
    "includedMileage",
    "additionalCharge",
    "requirement",
    "selectedPeriod",
    "selectedPrice",
    "selectedMileage"
  ]

  connect() {
    // Default select the first card (daily)
    if (this.cardTargets.length > 0) {
      this.selectCard(this.cardTargets[0])
    }
  }

  select(event) {
    const card = event.currentTarget
    this.selectCard(card)
  }

  selectCard(card) {
    const price = card.getAttribute('data-price') || '0'
    const period = card.getAttribute('data-period') || 'daily'
    const mileage = card.getAttribute('data-mileage') || '0'

    // Visual state
    this.cardTargets.forEach(c => {
      c.classList.remove('ring-2', 'ring-[#3a6363]', 'bg-teal-50')
    })
    card.classList.add('ring-2', 'ring-[#3a6363]', 'bg-teal-50')

    // Update text
    if (this.hasIncludedMileageTarget) {
      this.includedMileageTarget.textContent = `${mileage} km`
    }

    // additionalChargeTarget is static from template; nothing to compute here

    if (this.hasRequirementTarget) {
      const req = this.requirementText(period)
      this.requirementTarget.textContent = req
    }

    // Hidden inputs
    if (this.hasSelectedPeriodTarget) this.selectedPeriodTarget.value = period
    if (this.hasSelectedPriceTarget) this.selectedPriceTarget.value = price
    if (this.hasSelectedMileageTarget) this.selectedMileageTarget.value = mileage

    // Notify calendar to re-evaluate available dates
    try {
      window.dispatchEvent(new CustomEvent('pricing:period_changed', { detail: { period } }))
    } catch (_) {}
  }

  requirementText(period) {
    switch (period) {
      case 'weekly':
        return 'Required in 7 days rental'
      case 'monthly':
        return 'Required in 30 days rental'
      case 'daily':
      default:
        return 'Required in 1 day rental'
    }
  }
}


