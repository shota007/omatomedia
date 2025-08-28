import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// controllers/ 以下の *_controller.js を自動登録
eagerLoadControllersFrom("controllers", application)

console.log("[Stimulus] controllers eager-loaded")