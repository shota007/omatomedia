import { Modal } from "bootstrap";

document.addEventListener("turbo:load", () => {
  const btn = document.querySelector("[data-action='open-confirm']");
  const modalEl = document.getElementById("confirmModal");
  const bsModal = new Modal(modalEl);

  // 開いた後に「はい」ボタンへフォーカス移動
  modalEl.addEventListener("shown.bs.modal", () => {
    document.getElementById("confirmSubmit").focus();
  });

  btn.addEventListener("click", () => {
    bsModal.show();
  });
});