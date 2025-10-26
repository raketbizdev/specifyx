import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button", "mobilePanel", "mobileButton"]

  connect() {
    this.handleKeydown = (e) => { if (e.key === "Escape") this.closeAll() }
    document.addEventListener("keydown", this.handleKeydown)
  }
  disconnect() { document.removeEventListener("keydown", this.handleKeydown) }

  // Avatar dropdown
  toggle() { this.setDropdown(!this.isDropdownOpen()) }
  outside(e) { if (!this.element.contains(e.target)) this.setDropdown(false) }
  isDropdownOpen() { return this.menuTarget?.classList.contains("!visible") }
  setDropdown(show) {
    if (!this.hasMenuTarget || !this.hasButtonTarget) return
    this.buttonTarget.setAttribute("aria-expanded", show ? "true" : "false")
    if (show) {
      this.menuTarget.classList.remove("invisible", "opacity-0", "scale-95")
      this.menuTarget.classList.add("!visible", "opacity-100", "scale-100")
    } else {
      this.menuTarget.classList.remove("!visible", "opacity-100", "scale-100")
      this.menuTarget.classList.add("opacity-0", "scale-95")
      setTimeout(() => this.menuTarget.classList.add("invisible"), 150)
    }
  }

  // Mobile sheet
  toggleMobile() {
    if (!this.hasMobilePanelTarget) return
    const hidden = this.mobilePanelTarget.classList.contains("hidden")
    this.mobilePanelTarget.classList.toggle("hidden", !hidden)
    if (this.hasMobileButtonTarget) {
      this.mobileButtonTarget.setAttribute("aria-expanded", hidden ? "true" : "false")
    }
  }

  closeAll() {
    this.setDropdown(false)
    if (this.hasMobilePanelTarget) {
      this.mobilePanelTarget.classList.add("hidden")
      if (this.hasMobileButtonTarget) this.mobileButtonTarget.setAttribute("aria-expanded", "false")
    }
  }
}