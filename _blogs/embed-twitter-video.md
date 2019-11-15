---
title: Embedding Twitter videos
publish_date: 2019-11-15

---

{% capture frame %}
<!DOCTYPE HTML>
<html>
<body>
<form method="GET" action="https://kofi.sexy/.netlify/functions/embed-twitter-video">
  <code>twitter.com/.../status/</code>
  <input name="tweet" value="1195154216454635521">
  <br>
  <button type="submit">Get Video ID</button>
  <code style="position:absolute;right:0;bottom:0;padding:4px 8px;border-top-left-radius:4px;color:white;background:{{ site.theme_color }}">iframe</code>
</form>
</body>
</html>
{% endcapture %}
<iframe style="width:100%;height:3em;border:solid 2px {{site.theme_color}};border-radius:4px" srcdoc='{{ frame | strip_newlines }}'></iframe>
