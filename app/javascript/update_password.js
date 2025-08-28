// app/javascript/update_password.js
import { getAuth, EmailAuthProvider, reauthenticateWithCredential, updatePassword } from "https://www.gstatic.com/firebasejs/11.1.0/firebase-auth.js";

document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("update-password-form");
  if (!form) return;

  const currentPasswordInput = document.getElementById("current-password");
  const newPasswordInput     = document.getElementById("new-password");
  const confirmPasswordInput = document.getElementById("confirm-password");
  const errorBox             = document.getElementById("password-update-errors");
  const updateBtn            = document.getElementById("update-password-btn");

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    errorBox.classList.add("d-none");
    errorBox.innerHTML = "";

    const currentPassword = currentPasswordInput.value.trim();
    const newPassword     = newPasswordInput.value.trim();
    const confirmPassword = confirmPasswordInput.value.trim();

    // 1) 新しいパスワードと確認入力が合っているかチェック
    if (newPassword !== confirmPassword) {
      errorBox.innerHTML = "新しいパスワードが一致しません。";
      errorBox.classList.remove("d-none");
      return;
    }

    // 2) Firebase の currentUser を取得
    const auth = getAuth();
    const user = auth.currentUser;
    if (!user) {
      errorBox.innerHTML = "ユーザーがサインインされていません。再度ログインしてください。";
      errorBox.classList.remove("d-none");
      return;
    }

    // 3) 再認証：現在のパスワードを使って Credential を作成
    const email = user.email;
    const credential = EmailAuthProvider.credential(email, currentPassword);

    try {
      // 3-1) reauthenticateWithCredential を呼び出して直近の認証を済ませる
      await reauthenticateWithCredential(user, credential);

      // 4) updatePassword で新パスワードを設定
      await updatePassword(user, newPassword);

      // 5) 成功メッセージなどを表示
      alert("パスワードを更新しました。");
      // 必要に応じて画面をリダイレクト
      window.location.href = "/"; // たとえばトップページへ戻す
    } catch (err) {
      console.error("パスワード更新エラー：", err);
      let msg = "パスワードの更新に失敗しました。";

      // Firebase Auth が返すエラーコード例
      switch (err.code) {
        case "auth/wrong-password":
          msg = "現在のパスワードが間違っています。";
          break;
        case "auth/weak-password":
          msg = "新しいパスワードは 6 文字以上にしてください。";
          break;
        case "auth/requires-recent-login":
          msg = "セキュリティ保護のため、再度ログインが必要です。もう一度ログインしてから再試行してください。";
          break;
        default:
          msg = err.message;
      }

      errorBox.innerHTML = msg;
      errorBox.classList.remove("d-none");
    }
  });
});