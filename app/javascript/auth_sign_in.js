console.log("auth_sign_in.jsが読み込まれました");
import { getAuth, signInWithEmailAndPassword } from "https://www.gstatic.com/firebasejs/11.1.0/firebase-auth.js";
const auth = getAuth();

document.getElementById('sign-in-form').addEventListener('submit', function(e) {
    e.preventDefault();

    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const csrfToken = document.querySelector('[name="csrf-token"]').content;
    console.log('email', email)

signInWithEmailAndPassword(auth, email, password)
  .then((userCredential) => {
    // Signed in 
    const user = userCredential.user;
    console.log('Signed in:', user);

    fetch("/sessions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({
            user: {
                email: user.email,
                password: password
            }
        })
    })
        .then(response => {
            if (response.redirected) {
                window.location.href = response.url;
            } else {
                console.log("User signed in:", response);
            }
        })
    
  })
  .catch((error) => {
    const errorCode = error.code;
    const errorMessage = error.message;
    console.log('error message',errorMessage)
    document.getElementById("error_message").textContent = error.message;
  });
});