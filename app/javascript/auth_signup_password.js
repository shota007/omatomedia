// auth_signup_password.js
console.log("auth_signup_password.jsが読み込まれました");

import { initializeApp } from "https://www.gstatic.com/firebasejs/11.1.0/firebase-app.js";
import { getAuth, signInWithPopup, GoogleAuthProvider, createUserWithEmailAndPassword, signInWithEmailAndPassword, signOut, sendEmailVerification,sendSignInLinkToEmail, isSignInWithEmailLink } from "https://www.gstatic.com/firebasejs/11.1.0/firebase-auth.js";

const firebaseConfig = {
    apiKey: "AIzaSyAJttMOEQxjhfJZmeNhuyrJUJmMzFahPOo",
    authDomain: "obrest-4005c.firebaseapp.com",
    projectId: "obrest-4005c",
    storageBucket: "obrest-4005c.firebasestorage.app",
    messagingSenderId: "349152284643",
    appId: "1:349152284643:web:673ed8c3a110cf1b391ad6",
    measurementId: "G-444V4EJ2ZM"
    };
const app      = initializeApp(firebaseConfig);
const auth     = getAuth(app);
const provider = new GoogleAuthProvider();

// FirebaseUI の設定
const uiConfig = {
    signInSuccessUrl: "/",
    signInOptions: [GoogleAuthProvider.PROVIDER_ID],
    callbacks: {
        signInSuccessWithAuthResult: authResult => {
            const user      = authResult.user;
            const csrfToken = document.querySelector('[name="csrf-token"]').content;
            return fetch("/users", {
              method: "POST",
              headers: { "Content-Type": "application/json", "X-CSRF-Token":  csrfToken, "Accept": "application/json" },
              body: JSON.stringify({
                user: { uid:   user.uid, name:  user.displayName, email: user.email }
              })
            })
            .then(res => {
              if (res.redirected) window.location.href = res.url;
            })
            .catch(console.error)
            .then(() => false);
            return false;
        }      
    }
  };

  function initFirebaseUI() {
    const container = document.getElementById("firebaseui-auth-container");
    if (!container) return;
  
    // 1) 既存インスタンスを取得。なければ new で生成。
    const ui = window.firebaseui.auth.AuthUI.getInstance() 
               || new window.firebaseui.auth.AuthUI(auth);
  
    // 2) コンテナをクリア（前回の状態をリセット）
    container.innerHTML = "";
  
    // 3) 再度 UI を起動
    ui.start("#firebaseui-auth-container", uiConfig);
  }


// signup form
document.addEventListener('DOMContentLoaded', bindSignUpForm);
document.addEventListener('turbo:load',       bindSignUpForm);

function bindSignUpForm() {
  const form = document.getElementById('sign-up-form');
  if (!form) return;
  form.removeEventListener('submit', signUpHandler);
  form.addEventListener('submit',    signUpHandler);
}

async function signUpHandler(e) {
  e.preventDefault();
  const email    = document.getElementById('user_email').value;
  const errEl    = document.getElementById('error_message');
  if (errEl) { errEl.textContent = ""; }

  // ① Rails へ問い合わせ
  const resp = await fetch(
    `/users/check_email?email=${encodeURIComponent(email)}`,
    { headers: { 'Accept': 'application/json' } }
  );
  const { exists } = await resp.json();
  if (exists) {
    // 既存ユーザーならここでストップ
    errEl.textContent = 'このメールアドレスはすでに登録されています';
    return;
  }

  // ② 未登録なら Firebase にサインインリンク送信
  const actionCodeSettings = {
    url: `${window.location.origin}/users/finish_sign_up`,
    handleCodeInApp: true
  };
  try {
    await sendSignInLinkToEmail(auth, email, actionCodeSettings);
    window.localStorage.setItem("emailForRegistration", email);
    window.location.href = "/signup_sent";
  } catch (err) {
    console.error(err);
    let msg = err.message;
    if (err.code === "auth/invalid-email") {
      msg = "メールアドレスの形式が正しくありません";
    }
    if (errEl) {
      errEl.textContent = msg;
    } else {
      alert(msg);
    }
  }
}

//signin
function bindSignInForm() {
    const form = document.getElementById("sign-in-form");
    if (!form) return console.warn("sign-in-form が見つかりません");
    form.removeEventListener("submit", signInHandler);
    form.addEventListener("submit", signInHandler);
  }
  
  function signInHandler(e) {
    e.preventDefault();
    console.log("sign-in-form が submit されました");
    const email     = document.getElementById("email").value;
    const password  = document.getElementById("password").value;
    const csrfToken = document.querySelector('[name="csrf-token"]').content;
  
    signInWithEmailAndPassword(auth, email, password)
      .then(userCredential => {
        // Firebase 認証が通ったら Rails に POST
        return fetch("/login", {
          method:  "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token":  csrfToken,
            "Accept":        "application/json"
          },
          body: JSON.stringify({ session: { email, password } })
        });
      })
      .then(res => res.json())
      .then(data => {
        if (data.status === "ok") {
          window.location.href = data.redirect_url;
        } else {
          // Rails 側で認証失敗したときもこちら
          document.getElementById("error_message").textContent = data.message;
        }
      })
      .catch(error => {
        // Firebase 側のエラー
        console.error("firebase error:", error);
        console.log("★ Firebase error.code:", error.code);
        console.log("★ Firebase error.message:", error.message);
        let msg;
        switch (error.code) {
          case "auth/invalid-credential":
            msg = "認証情報が無効です。再度お試しください。";
            break;
          case "auth/wrong-password":
          case "auth/user-not-found":
            msg = "メールアドレスまたはパスワードが違います";
            break;
          case "auth/invalid-email":
            msg = "メールアドレスの形式が正しくありません";
            break;
          default:
            msg = "ログインに失敗しました";
        }
        // document.getElementById("error_message").textContent = msg;
        const errEl = document.getElementById("error_message");
        errEl.textContent   = msg;
        errEl.style.display = "block";
      });
  }
  
  // 初回ロードと Turbo 遷移の両方で bind
  document.addEventListener("DOMContentLoaded", bindSignInForm);
  document.addEventListener("turbo:load",        bindSignInForm);

//sign out
document.addEventListener("turbo:load", function() {
    const btn = document.getElementById("sign-out");
    if (!btn) { console.warn("sign-out ボタンが見つかりません"); return; }

    btn.addEventListener("click", function(e) {
    console.log("auth_sign_outが動いています");
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
