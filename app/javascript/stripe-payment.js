// app/javascript/packs/stripe-payment.js
// Simple Stripe payment handler - no dependencies on other files

document.addEventListener('DOMContentLoaded', function() {
  console.log('💳 Payment script loaded');

  // Get data from HTML attributes
  const paymentData = document.getElementById('payment-data');
  const publishableKey = paymentData?.dataset.publishableKey;
  const invoiceId = paymentData?.dataset.invoiceId;

  console.log('Invoice ID:', invoiceId);
  console.log('Key configured:', !!publishableKey);

  let stripe = null;
  let elements = null;
  let cardElement = null;

  // Load and initialize Stripe
  function initializeStripe() {
    if (!window.Stripe) {
      console.error('Stripe not loaded');
      return;
    }

    if (!publishableKey) {
      console.error('No publishable key');
      showError('Payment system not configured');
      return;
    }

    try {
      stripe = Stripe(publishableKey);
      elements = stripe.elements();
      
      cardElement = elements.create('card', {
        style: {
          base: {
            fontSize: '16px',
            color: '#424770',
            fontFamily: 'system-ui, -apple-system, sans-serif',
            '::placeholder': { color: '#aab7c4' }
          },
          invalid: { color: '#fa755a', iconColor: '#fa755a' }
        }
      });

      const cardElementDiv = document.getElementById('card-element');
      cardElement.mount('#card-element');

      cardElement.on('change', (event) => {
        const errorDiv = document.getElementById('card-errors');
        if (event.error) {
          errorDiv.textContent = event.error.message;
          errorDiv.classList.remove('hidden');
        } else {
          errorDiv.textContent = '';
          errorDiv.classList.add('hidden');
        }
      });

      document.getElementById('paymentStatus').innerHTML = 
        '<p class="text-sm text-green-700"><i class="fas fa-check-circle mr-2"></i>Payment form ready</p>';
      document.getElementById('submitPayment').disabled = false;

      console.log('✅ Stripe initialized');
    } catch (e) {
      console.error('Error initializing Stripe:', e);
      showError(e.message);
    }
  }

  // Modal controls
  document.getElementById('openPaymentBtn')?.addEventListener('click', () => {
    document.getElementById('paymentModal').classList.remove('hidden');
    document.body.style.overflow = 'hidden';
    
    if (!stripe) {
      initializeStripe();
    }
  });

  document.getElementById('closePaymentBtn')?.addEventListener('click', () => {
    document.getElementById('paymentModal').classList.add('hidden');
    document.body.style.overflow = 'auto';
  });

  // Close on background click
  document.getElementById('paymentModal')?.addEventListener('click', (e) => {
    if (e.target.id === 'paymentModal') {
      document.getElementById('closePaymentBtn').click();
    }
  });

  // Close on Escape
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      const modal = document.getElementById('paymentModal');
      if (modal && !modal.classList.contains('hidden')) {
        document.getElementById('closePaymentBtn').click();
      }
    }
  });

  // Form submission
  document.getElementById('paymentForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();

    if (!stripe || !cardElement) {
      showError('Payment form not ready');
      return;
    }

    const name = document.getElementById('cardholderName').value.trim();
    const email = document.getElementById('email').value.trim();

    if (!name || !email) {
      showError('Name and email are required');
      return;
    }

    setLoading(true);

    try {
      const { paymentMethod, error } = await stripe.createPaymentMethod({
        type: 'card',
        card: cardElement,
        billing_details: { name, email }
      });

      if (error) {
        showError(error.message);
        setLoading(false);
        return;
      }

      // Send to server
      const response = await fetch(`/vendors/invoices/${invoiceId}/confirm_payment`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ payment_method_id: paymentMethod.id })
      });

      const data = await response.json();

      if (!response.ok) {
        showError(data.error || 'Payment failed');
        setLoading(false);
        return;
      }

      if (data.success) {
        showSuccess('Payment successful! Redirecting...');
        setTimeout(() => {
          window.location.href = data.redirect_url;
        }, 2000);
      } else {
        showError(data.message || 'Payment failed');
        setLoading(false);
      }
    } catch (err) {
      console.error('Payment error:', err);
      showError('An error occurred during payment');
      setLoading(false);
    }
  });

  function showError(message) {
    const errorDiv = document.getElementById('card-errors');
    errorDiv.textContent = message;
    errorDiv.classList.remove('hidden');
  }

  function showSuccess(message) {
    const toast = document.createElement('div');
    toast.className = 'fixed top-4 right-4 bg-green-500 text-white px-6 py-4 rounded-lg shadow-lg z-50';
    toast.textContent = message;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
  }

  function setLoading(isLoading) {
    const submitBtn = document.getElementById('submitPayment');
    submitBtn.disabled = isLoading;
    document.getElementById('buttonText').classList.toggle('hidden', isLoading);
    document.getElementById('loadingText').classList.toggle('hidden', !isLoading);
  }

  // Initialize when Stripe script loads
  if (window.Stripe) {
    initializeStripe();
  } else {
    // Wait for Stripe to load
    const checkStripe = setInterval(() => {
      if (window.Stripe) {
        clearInterval(checkStripe);
        initializeStripe();
      }
    }, 100);
  }
});