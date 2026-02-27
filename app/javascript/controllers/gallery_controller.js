console.log("Gallery controller file evaluation BASE START");
import { Controller } from "@hotwired/stimulus"

console.log("Gallery controller file evaluation start");

export default class extends Controller {
    static targets = ["container", "lightbox", "lightboxImage", "counter", "thumbnail", "lightboxCounter"]

    connect() {
        this.initializeSwiper()
        this.updateThumbnails(0)
    }

    initializeSwiper() {
        if (!window.Swiper) return

        this.swiper = new Swiper(this.containerTarget, {
            loop: true,
            navigation: {
                nextEl: '.swiper-button-next',
                prevEl: '.swiper-button-prev',
            },
            pagination: {
                el: '.swiper-pagination',
                clickable: true,
                dynamicBullets: true,
            },
            slidesPerView: 1,
            speed: 600,
            effect: 'fade',
            on: {
                slideChange: () => {
                    if (this.hasCounterTarget) {
                        this.counterTarget.textContent = this.swiper.realIndex + 1
                    }
                    this.updateThumbnails(this.swiper.realIndex)
                }
            }
        })
    }

    openLightbox(event) {
        const url = event.currentTarget.dataset.url
        const index = parseInt(event.currentTarget.dataset.swiperSlideIndex || event.currentTarget.dataset.index || 0)

        if (this.hasLightboxImageTarget && this.hasLightboxTarget) {
            this.lightboxImageTarget.src = url
            this.lightboxTarget.classList.remove('hidden')
            document.body.style.overflow = 'hidden'
            this.updateLightboxCounter(index + 1)
        }
    }

    closeLightbox() {
        if (this.hasLightboxTarget) {
            this.lightboxTarget.classList.add('hidden')
            document.body.style.overflow = ''
        }
    }

    updateLightboxCounter(current) {
        const total = this.thumbnailTargets.length
        if (this.hasLightboxCounterTarget) {
            this.lightboxCounterTarget.textContent = `${current} / ${total}`
        }
    }

    selectThumbnail(event) {
        const index = parseInt(event.currentTarget.dataset.slideIndex)
        this.swiper.slideToLoop(index)
        this.updateThumbnails(index)
    }

    updateThumbnails(activeIndex) {
        this.thumbnailTargets.forEach((thumb, index) => {
            if (index === activeIndex) {
                thumb.classList.add('border-blue-600', 'shadow-lg', 'scale-105')
                thumb.classList.remove('border-gray-300')
                thumb.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' })
            } else {
                thumb.classList.remove('border-blue-600', 'shadow-lg', 'scale-105')
                thumb.classList.add('border-gray-300')
            }
        })
    }
}
