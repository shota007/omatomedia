document.addEventListener('DOMContentLoaded', () => {
  console.log("preview.jsが読み込まれました");
  const inputs     = document.querySelectorAll('.js-file-select-preview');
  // プレビュー領域
  const previewDiv = document.getElementById('file-preview');
  if (!inputs.length || !previewDiv) return;
  inputs.forEach(input => {
    input.addEventListener('change', (e) => {
      const file = e.target.files[0];
      if (!file) {
        // 選択解除されたら何も表示しない
        previewDiv.innerHTML = '';
        return;
      }
      const reader = new FileReader();
      reader.onloadend = () => {
        // Rails の image_tag と同じ HTML をここで出力
        previewDiv.innerHTML =
          `<img src="${reader.result}"
                class="rounded-circle d-inline-block"
                width="100" height="100" />`;
      };
      reader.readAsDataURL(file);
    });
  });

    const element2s = document.querySelectorAll('.js-file-select-preview2')

    if (!element2s) return
    const preview_div2 = document.getElementById("file-preview2")
    element2s.forEach((element2) => {
        const previewElement2 = document.querySelector(element2.dataset.target)
        element2.addEventListener('change', (e) => {
            const reader2  = new FileReader();
            reader2.onloadend = function(e) {
                preview_div2.innerHTML = "<img src=" + e.target.result + " width=480 height=320 />";
            }
            const file2 = e.target.files[0];
            if (file2) {
                reader2.readAsDataURL(file2);
            }
        })
    })
})