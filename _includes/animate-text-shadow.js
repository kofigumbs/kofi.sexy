var root = document.documentElement;
var h1 = document.querySelector("h1");
var lastRequestId;

function calculateShadow(rawCursor, length) {
  var ratio = Math.max(0, rawCursor) / length;
  return 1 - (ratio * 2);
}

h1.addEventListener("mousemove", function(e) {
  cancelAnimationFrame(lastRequestId);
  lastRequestId = requestAnimationFrame(function() {
    root.style.setProperty("--text-shadow-x", calculateShadow(e.clientX - h1.offsetLeft, h1.clientWidth));
    root.style.setProperty("--text-shadow-y", calculateShadow(e.clientY - h1.offsetTop, h1.clientHeight));
  });
});

h1.addEventListener("mouseleave", function(e) {
  root.style.removeProperty("--text-shadow-x");
  root.style.removeProperty("--text-shadow-y");
});
