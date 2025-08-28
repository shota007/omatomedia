document.addEventListener("DOMContentLoaded", function() {
    console.log("dropdown.jsが読み込まれました");
    const button = document.getElementById("dropdownButton");
    const menu   = document.getElementById("dropdownMenu");
    if (!button || !menu) return;  // ボタン or メニューがなければ何もしない

button.addEventListener("click", function(event) {
    event.stopPropagation(); // ボタンクリック時のイベント伝播を止める
    // メニューの表示/非表示を切り替え
    menu.style.display = (menu.style.display === "block") ? "none" : "block";
});

// ページの他の部分をクリックした場合はメニューを閉じる
document.addEventListener("click", function() {
    menu.style.display = "none";
});
});