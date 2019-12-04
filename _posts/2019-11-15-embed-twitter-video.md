---
title: Embed Twitter video
categories: ['blog']

---

Last night, I spent some time exploring Twitter's documentation for embedding tweets.
I needed to embed a tweet with an attached video, play the video programmatically,
and detect when the video finishes.
Twitter has no such API to observe playback state… but HTML5 video does!
Here is my workaround, which hopefully saves you some time:

- Load [Twitter's embed widget](https://developer.twitter.com/en/docs/twitter-for-websites/javascript-api/guides/scripting-factory-functions) using the tweet's ID
- On a server (AWS Lambda in my case) use the [Twitter API](https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-show-id) to lookup the tweet's metadata
- Grab the `.mp4` video URLs from the JSON response: `$.extended_entities.media[*].variants.url`
- Replace the tweet widget's media content with a `<video>` tag referencing the `.mp4` URL

My API, described above, is universally accessible on this site:

```
GET https://kofi.sexy/.netlify/functions/embed-twitter-video?tweet=<YOUR TWEET ID>
```

I'll continue to host it until I run into limitations with Twitter or Netlify.
You can <a href="https://github.com/hkgumbs/kofi.sexy/blob/master/_functions/embed-twitter-video.js">view the source code on GitHub</a> and a live example below:

{% capture frame %}
<!DOCTYPE HTML>
<html>
<body>
<form method="GET" action="https://kofi.sexy/.netlify/functions/embed-twitter-video">
  <code>twitter.com/.../status/</code>
  <input name="tweet" value="1195154216454635521">
  <br>
  <button type="submit">Get Video URL</button>
</form>
</body>
</html>
{% endcapture %}
<div class="frame" style="position:relative;border-radius:0.1em;padding:1em;border:solid 2px {{site.theme_color}};">
  <iframe srcdoc='{{ frame | strip_newlines }}' style="width:100%;height:3em;border:none;margin:0;padding:0;"></iframe>
  <code style="position:absolute;right:0;bottom:0;padding:4px 8px;border-top-left-radius:0.1em;color:white;background:{{ site.theme_color }};">iframe</code>
</div>
