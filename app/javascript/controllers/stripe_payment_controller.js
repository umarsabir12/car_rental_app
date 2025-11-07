import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // This will be implemented when Stripe is configured
    // For now, we'll show a placeholder in the card element
    this.initializePlaceholder()
  }

  initializePlaceholder() {
    const cardElement = document.getElementById('card-element')
    if (cardElement) {
      cardElement.innerHTML = `
        <div class="text-center py-4">
          <i class="fas fa-credit-card text-gray-300 text-3xl mb-2"></i>
          <p class="text-sm text-gray-500">Card input field will appear here</p>
          <p class="text-xs text-gray-400 mt-1">Stripe integration pending</p>
        </div>
      `
    }
  }

  submit(event) {
    event.preventDefault()
    
    const submitButton = document.getElementById('submit-payment')
    const buttonText = document.getElementById('button-text')
    const loading = document.getElementById('loading')
    
    // Disable button and show loading
    submitButton.disabled = true
    buttonText.classList.add('hidden')
    loading.classList.remove('hidden')
    
    // TODO: When Stripe is configured, add actual payment processing here
    // For now, simulate processing
    setTimeout(() => {
      alert('Payment processing will be implemented once Stripe is configured')
      submitButton.disabled = false
      buttonText.classList.remove('hidden')
      loading.classList.add('hidden')
    }, 2000)
  }
}