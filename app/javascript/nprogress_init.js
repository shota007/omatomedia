// app/javascript/nprogress_init.js
import NProgress from "nprogress";

document.addEventListener("turbo:visit", () => NProgress.start());
document.addEventListener("turbo:load",  () => NProgress.done());