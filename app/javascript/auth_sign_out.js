console.log("auth_sign_out.jsが読み込まれました");

import { initializeApp } from "https://www.gstatic.com/firebasejs/11.1.0/firebase-app.js";
import { getAuth, signInWithPopup, GoogleAuthProvider, createUserWithEmailAndPassword, signInWithEmailAndPassword, signOut } from "https://www.gstatic.com/firebasejs/11.1.0/firebase-auth.js";

//sign out
document.addEventListener("DOMContentLoaded", function() {
    const btn = document.getElementById("sign-out");
    if (!btn) { console.warn("sign-out ボタンが見つかりません"); return; }
  
    btn.addEventListener("click", function(e) {
      console.log("auth_sign_out.js が動いています");
      e.preventDefault();
  
      const csrfToken = document.querySelector('[name="csrf-token"]').content;
      signOut(auth).then(() => {
        return fetch("/logout", {
          method: "DELETE",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": csrfToken
          },
        });
      })
      .then(response => {
        if (response.redirected) {
          window.location.href = response.url;
        } else {
          console.log("Signed out, but no redirect", response);
        }
      })
      .catch(err => console.error("sign out error:", err));
    });
  });
