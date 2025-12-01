import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cardElement", "cardErrors", "submitButton", "buttonText", "loading"]
  static values = { 
    clientSecret: String,
    publishableKey: String
  }

  connect() {
    // Initialize Stripe only if publishable key is available
    if (!this.publishableKeyValue) {
      console.error("Stripe publishable key not found")
      this.showPlaceholder()
      return
    }

    this.setupStripe()
  }

  setupStripe() {
    try {
      // Initialize Stripe
      this.stripe = Stripe(this.publishableKeyValue)
      this.elements = this.stripe.elements()

      // Create and mount card element
      const style = {
        base: {
          fontSize: '16px',
          color: '#424770',
          fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
          '::placeholder': {
            color: '#aab7c4',
          },
        },
        invalid: {
          color: '#fa755a',
          iconColor: '#fa755a'
        }
      }

      this.cardElement = this.elements.create('card', { style })
      
      // Mount to the card element container
      const cardElementTarget = document.getElementById('card-element') || this.cardElementTarget
      this.cardElement.mount(cardElementTarget)

      // Handle real-time validation errors
      this.cardElement.addEventListener('change', (event) => {
        if (event.error) {
          this.showCardError(event.error.message)
        } else {
          this.clearCardError()
        }
      })
    } catch (error) {
      console.error("Error setting up Stripe:", error)
      this.showPlaceholder()
    }
  }

  submit(event) {
    event.preventDefault()

    // Validate that we have Stripe setup
    if (!this.stripe || !this.cardElement) {
      this.showError('Payment system not initialized. Please refresh the page.')
      return
    }

    // Disable button and show loading state
    this.disableSubmitButton()

    // Get cardholder details from form
    const cardholderNameInput = document.querySelector('[name="cardholder_name"]')
    const emailInput = document.querySelector('[name="email"]')

    if (!cardholderNameInput || !emailInput) {
      this.showError('Form fields not found. Please refresh the page.')
      this.enableSubmitButton()
      return
    }

    const cardholderName = cardholderNameInput.value?.trim()
    const email = emailInput.value?.trim()

    // Validate required fields
    if (!cardholderName) {
      this.showCardError('Cardholder name is required')
      this.enableSubmitButton()
      return
    }

    if (!email) {
      this.showCardError('Email is required')
      this.enableSubmitButton()
      return
    }

    // Validate email format
    if (!this.isValidEmail(email)) {
      this.showCardError('Please enter a valid email address')
      this.enableSubmitButton()
      return
    }

    // Get invoice ID from URL
    const invoiceId = this.getInvoiceIdFromURL()
    if (!invoiceId) {
      this.showError('Invoice ID not found')
      this.enableSubmitButton()
      return
    }

    // Create payment method and confirm payment
    this.stripe.createPaymentMethod({
      type: 'card',
      card: this.cardElement,
      billing_details: {
        name: cardholderName,
        email: email
      }
    }).then((result) => {
      if (result.error) {
        this.showCardError(result.error.message)
        this.enableSubmitButton()
      } else {
        // Payment method created successfully, confirm payment
        this.confirmPayment(invoiceId, result.paymentMethod.id)
      }
    }).catch((error) => {
      console.error('Stripe error:', error)
      this.showError(error.message || 'An error occurred. Please try again.')
      this.enableSubmitButton()
    })
  }

  confirmPayment(invoiceId, paymentMethodId) {
    // Get CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    if (!csrfToken) {
      this.showError('Security token not found. Please refresh the page.')
      this.enableSubmitButton()
      return
    }

    // Send confirmation to server
    fetch(`/vendors/invoices/${invoiceId}/confirm_payment`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        payment_method_id: paymentMethodId
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.handlePaymentSuccess(data)
      } else if (data.requiresAction) {
        // Payment requires additional authentication
        this.handlePaymentAction(data, invoiceId)
      } else {
        this.showCardError(data.message || 'Payment failed. Please try again.')
        this.enableSubmitButton()
      }
    })
    .catch(error => {
      console.error('Error confirming payment:', error)
      this.showError(error.message || 'Connection error. Please try again.')
      this.enableSubmitButton()
    })
  }

  handlePaymentAction(data, invoiceId) {
    // Handle 3D Secure or other authentication requirements
    if (data.clientSecret) {
      this.stripe.handleCardAction(data.clientSecret)
        .then((result) => {
          if (result.error) {
            this.showCardError(result.error.message)
            this.enableSubmitButton()
          } else {
            // Action handled, retry payment
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
            fetch(`/vendors/invoices/${invoiceId}/confirm_payment`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
              },
              body: JSON.stringify({
                payment_intent_id: data.clientSecret
              })
            })
            .then(response => response.json())
            .then(paymentData => {
              if (paymentData.success) {
                this.handlePaymentSuccess(paymentData)
              } else {
                this.showCardError(paymentData.message || 'Payment failed. Please try again.')
                this.enableSubmitButton()
              }
            })
          }
        })
    }
  }

  handlePaymentSuccess(data) {
    // Show success message
    this.showSuccess('Payment successful! Your invoice has been paid.')

    // Redirect after 2 seconds
    setTimeout(() => {
      if (data.redirect_url) {
        window.location.href = data.redirect_url
      } else {
        window.location.reload()
      }
    }, 2000)
  }

  showCardError(message) {
    const errorElement = document.getElementById('card-errors') || 
                         (this.hasCardErrorsTarget && this.cardErrorsTarget)
    
    if (errorElement) {
      errorElement.textContent = message
      errorElement.classList.remove('hidden')
    } else {
      console.error('Error:', message)
    }
  }

  clearCardError() {
    const errorElement = document.getElementById('card-errors') || 
                         (this.hasCardErrorsTarget && this.cardErrorsTarget)
    
    if (errorElement) {
      errorElement.textContent = ''
      errorElement.classList.add('hidden')
    }
  }

  showError(message) {
    // Show error in card errors div if available, otherwise alert
    const errorElement = document.getElementById('card-errors') || 
                         (this.hasCardErrorsTarget && this.cardErrorsTarget)
    
    if (errorElement) {
      this.showCardError(message)
    } else {
      alert(`Error: ${message}`)
    }
  }

  showSuccess(message) {
    // Create a toast notification
    const toast = document.createElement('div')
    toast.className = 'fixed top-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-pulse'
    toast.textContent = message
    document.body.appendChild(toast)

    setTimeout(() => toast.remove(), 3000)
  }

  disableSubmitButton() {
    const button = document.getElementById('submit-payment') || 
                   (this.hasSubmitButtonTarget && this.submitButtonTarget)
    const buttonText = document.getElementById('button-text') || 
                       (this.hasButtonTextTarget && this.buttonTextTarget)
    const loading = document.getElementById('loading') || 
                    (this.hasLoadingTarget && this.loadingTarget)

    if (button) button.disabled = true
    if (buttonText) buttonText.classList.add('hidden')
    if (loading) loading.classList.remove('hidden')
  }

  enableSubmitButton() {
    const button = document.getElementById('submit-payment') || 
                   (this.hasSubmitButtonTarget && this.submitButtonTarget)
    const buttonText = document.getElementById('button-text') || 
                       (this.hasButtonTextTarget && this.buttonTextTarget)
    const loading = document.getElementById('loading') || 
                    (this.hasLoadingTarget && this.loadingTarget)

    if (button) button.disabled = false
    if (buttonText) buttonText.classList.remove('hidden')
    if (loading) loading.classList.add('hidden')
  }

  getInvoiceIdFromURL() {
    // Extract invoice ID from URL like /vendors/invoices/123
    const urlParts = window.location.pathname.split('/')
    const invoicesIndex = urlParts.indexOf('invoices')
    if (invoicesIndex !== -1 && invoicesIndex + 1 < urlParts.length) {
      return urlParts[invoicesIndex + 1]
    }
    return null
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  showPlaceholder() {
    const cardElement = document.getElementById('card-element')
    if (cardElement) {
      cardElement.innerHTML = `
        <div class="text-center py-4">
          <i class="fas fa-exclamation-triangle text-yellow-500 text-3xl mb-2"></i>
          <p class="text-sm text-gray-600">Payment system is not configured</p>
          <p class="text-xs text-gray-500 mt-1">Please contact support</p>
        </div>
      `
    }
  }
}