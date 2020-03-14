function q(event) {
  try {
    return decodeURIComponent(event.queryStringParameters.q || "").replace(/[<>]/g, "");
  } catch {
    return "";
  }
}

exports.handler = function(event, _, callback) {
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
            <div contenteditable style="white-space: pre-line">${q(event)}</div>
            <br>
          </header>
          <script type="text/javascript">
            document.querySelector("div").addEventListener("input", function(event) {
              window.history.replaceState(null, null, "?q=" + encodeURIComponent(event.target.innerText));
            });
          </script>
        </body>
      </html>`,
  });
};
