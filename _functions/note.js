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
            document.querySelector("textarea").addEventListener("input", function(event) {
              event.target.style.height = 0;
              event.target.style.height = event.target.scrollHeight + "px";
              window.history.replaceState(null, null, "?q=" + encodeURIComponent(event.target.value));
            });
          </script>
        </body>
      </html>`,
  });
};
