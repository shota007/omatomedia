// app/javascript/application.js
import "@hotwired/turbo-rails"
import "bootstrap"

// 自作JS（必要なら残す）
import "preview"
import "auth_signup_password"
import "dropdown"
import "nprogress_init"
import "update_password"

// Stimulus（controllers/ 以下を自動登録）
import "controllers"

console.log("[application.js] loaded")