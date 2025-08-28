// app/javascript/controllers/application.js
import { Application } from "@hotwired/stimulus"

export const application = Application.start()
application.debug = false

// デバッグ用（コンソールで window.Stimulus が見える）
window.Stimulus = application
console.log("[Stimulus] Application started")