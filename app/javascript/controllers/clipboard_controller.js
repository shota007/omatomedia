import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static values = {
    content: String
  }

  connect(){
    this.originalContent = this.element.innerHTML
  }
  
  copy() {
    console.log(this.element)
    navigator.clipboard.writeText(this.contentValue).then(
      () => {
        this.element.textContent = "URL copied!"
        setTimeout(()=>{
          this.element.innerHTML = this.originalContent
        }, 2000)
      },
      () => {
        alert("クリップボードにコピー出来ませんでした。")
      }
    )
  }
}