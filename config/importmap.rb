# config/importmap.rb
pin "application", preload: true

pin "@hotwired/turbo-rails",      to: "turbo.min.js", preload: true
pin "@hotwired/stimulus",         to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# Bootstrap（bundle は Popper 同梱）
pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"

# 任意ライブラリ
pin "nprogress",      to: "https://esm.sh/nprogress@0.2.0"
pin "nprogress_init", to: "nprogress_init.js"

# 自作モジュール
pin "preview",              to: "preview.js"
pin "auth_signup_password", to: "auth_signup_password.js", preload: true
pin "dropdown",             to: "dropdown.js"
pin "update_password",      to: "update_password.js"

# Stimulus controllers（application.js が `import "controllers"` で使う）
pin_all_from "app/javascript/controllers", under: "controllers"