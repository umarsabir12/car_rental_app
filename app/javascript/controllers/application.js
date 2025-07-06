import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
window.Stimulus   = application
application.debug = false

export { application }
