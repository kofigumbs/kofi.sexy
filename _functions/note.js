function decode(param) {
  try {
    return decodeURIComponent(param || "").replace(/[<>]/g, "");
  } catch {
    return "";
  }
}

exports.handler = function(event, _, callback) {
  const content = decode(event.queryStringParameters.q);
  callback(null, {
    statusCode: 200,
    headers: {},
    body: `<!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width,minimum-scale=1,initial-scale=1">
          <link rel="stylesheet" href="/styles.css">
        </head>
        <body>
          <header>
            <textarea ${content.length ? "" : "autofocus"} placeholder="What's happening?">${content}</textarea>
          </header>
          <script type="text/javascript">
            const textarea = document.querySelector("textarea");
            textarea.addEventListener("input", function() { resize(); save(); });
            resize();
            function save() {
              window.history.replaceState(null, null, "?q=" + encodeURIComponent(textarea.value));
            }
            function resize() {
              textarea.style.height = 0;
              textarea.style.height = textarea.scrollHeight + "px";
            }
          </script>
        </body>
      </html>`,
  });
};
