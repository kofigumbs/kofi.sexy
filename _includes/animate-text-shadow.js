var maxShadow = 5;
var root = document.documentElement;
var h1 = document.querySelector("h1");
var lastRequestId;

log = (x) => { console.log(x); return x }

function calculateShadow(rawCursor, length) {
  var ratio = Math.max(0, rawCursor) / length;
  return maxShadow - (ratio * maxShadow * 2);
}

h1.addEventListener("mousemove", function(e) {
  if (lastRequestId) cancelAnimationFrame(lastRequestId);
  lastRequestId = requestAnimationFrame(function() {
    root.style.setProperty("--text-shadow-x", calculateShadow(e.clientX - h1.offsetLeft, h1.clientWidth));
    root.style.setProperty("--text-shadow-y", calculateShadow(e.clientY - h1.offsetTop, h1.clientHeight));
    cancelAnimationFrame(lastRequestId);
  });
});
