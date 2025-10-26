// app/javascript/controllers/infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sentinel"]

  connect() {
    if (!("IntersectionObserver" in window)) return
    this.loading = false
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) this.load()
      })
    }, { rootMargin: "200px 0px" })

    if (this.hasSentinelTarget) {
      this.observer.observe(this.sentinelTarget)
      // Load immediately if sentinel already visible
      const r = this.sentinelTarget.getBoundingClientRect()
      if (r.top < window.innerHeight && r.bottom >= 0) this.load()
    }
  }

  disconnect() {
    if (this.observer && this.hasSentinelTarget) this.observer.unobserve(this.sentinelTarget)
  }

  load() {
    if (this.loading) return
    const link = this.element.querySelector("#companies-load-more")
    if (!link) return
    this.loading = true

    fetch(link.href, { headers: { "Accept": "text/vnd.turbo-stream.html" } })
      .then(r => r.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
        this.loading = false
      })
      .catch(() => { this.loading = false })
  }
}
