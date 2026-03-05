import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
    static values = {
        timeout: { type: Number, default: 5000 }
    }

    connect() {
        this.scheduleDismissal()
    }

    scheduleDismissal() {
        if (this.timeoutValue > 0) {
            setTimeout(() => {
                this.dismiss()
            }, this.timeoutValue)
        }
    }

    dismiss() {
        // Add transition classes
        this.element.classList.add('opacity-0', '-translate-x-4')

        // Remove from DOM after transition
        setTimeout(() => {
            this.element.remove()

            // If parent container is empty, we could hide it if needed
            // but usually the fixed container is invisible without children
        }, 500)
    }

    close(event) {
        event.preventDefault()
        this.dismiss()
    }
}
