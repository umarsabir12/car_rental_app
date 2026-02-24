import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["logo", "title", "content", "border", "dots"]

    connect() {
        this.animateEntrance()
    }

    animateEntrance() {
        // Initial hidden state is handled by CSS classes (opacity-0, etc.)

        // 1. Animate Borders
        if (this.hasBorderTargets) {
            this.borderTargets.forEach((border, index) => {
                setTimeout(() => {
                    border.classList.remove('translate-x-full', '-translate-x-full', 'scale-x-0')
                    border.classList.add('translate-x-0', 'scale-x-100')
                }, 100 * index)
            })
        }

        // 2. Animate Logo
        if (this.hasLogoTarget) {
            setTimeout(() => {
                this.logoTarget.classList.remove('opacity-0', 'scale-95')
                this.logoTarget.classList.add('opacity-100', 'scale-100')
            }, 300)
        }

        // 3. Animate Title (Thank You)
        if (this.hasTitleTarget) {
            setTimeout(() => {
                this.titleTarget.classList.remove('opacity-0', 'translate-y-10')
                this.titleTarget.classList.add('opacity-100', 'translate-y-0')
            }, 500)
        }

        // 4. Animate Content (Buttons, Text)
        if (this.hasContentTarget) {
            setTimeout(() => {
                this.contentTarget.classList.remove('opacity-0', 'translate-y-10')
                this.contentTarget.classList.add('opacity-100', 'translate-y-0')
            }, 800)
        }

        // 5. Start subtle dot movement
        this.startFloatingDots()
    }

    startFloatingDots() {
        if (!this.hasDotsTargets) return

        const animationClasses = [
            'animate-float-1',
            'animate-float-2',
            'animate-float-3',
            'animate-float-4',
            'animate-float-slow',
            'animate-float-slow-2'
        ]

        this.dotsTargets.forEach((dots, index) => {
            // Use index to select animation, looping back if more targets than classes
            const animationClass = animationClasses[index % animationClasses.length]
            dots.classList.add(animationClass)

            // Add a random delay to make it look more organic
            const delay = Math.random() * 2
            dots.style.animationDelay = `${delay}s`
        })
    }
}
