var raf, scrollTop;

window.addEventListener(
  "scroll",
  function(e) {
    scrollTop = window.scrollY;

    if (raf) return;

    raf = window.requestAnimationFrame(function() {
      console.log("scrolled");
      if (scrollTop > 5) {
        document.body.classList.add("scrolled");
      } else {
        document.body.classList.remove("scrolled");
      }
      raf = null;
    });
  },
  { passive: true }
);
