import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["form", "results"]

    connect() {
        console.log("Admin filter controller connected")
    }

    submit() {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
            this.element.requestSubmit()
        }, 300)
    }
}
