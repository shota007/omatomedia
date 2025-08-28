// app/javascript/controllers/copy_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  connect() {
    console.log("[copy] connected, text:", this.textValue)
  }

  async copy(event) {
    event.preventDefault()
    event.stopPropagation()

    const text = this.textValue || ""
    if (!text) {
      console.warn("[copy] empty text")
      return
    }

    try {
      // HTTPS or localhost なら Clipboard API
      if (window.isSecureContext && navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(text)
        this.flash("Copied!")
        return
      }
      // フォールバック
      this.legacyCopy(text)
      this.flash("Copied!")
    } catch (err) {
      console.error("[copy] failed:", err)
      try {
        this.legacyCopy(text)
        this.flash("Copied!")
      } catch (e2) {
        console.error("[copy] legacy failed:", e2)
        this.flash("Copy failed")
      }
    }
  }

  legacyCopy(text) {
    const ta = document.createElement("textarea")
    ta.value = text
    ta.setAttribute("readonly", "")
    ta.style.position = "fixed"
    ta.style.left = "-9999px"
    document.body.appendChild(ta)
    ta.select()
    document.execCommand("copy")
    document.body.removeChild(ta)
  }

  flash(msg) {
    const btn = this.element.querySelector("button")
    if (!btn) return
    const org = btn.textContent
    btn.textContent = msg
    btn.disabled = true
    setTimeout(() => { btn.textContent = org; btn.disabled = false }, 1200)
  }
}