---
title: Embed Twitter video
categories: ['blog']

---

> Note: the process described here no longer works due to new restrictions in Twitter's API.

Last night, I spent some time exploring Twitter's documentation for embedding tweets.
I needed to embed a tweet with an attached video, play the video programmatically,
and detect when the video finishes.
Twitter has no such API to observe playback state… but HTML5 video does!
Here is my workaround, which hopefully saves you some time:

- Load [Twitter's embed widget](https://developer.twitter.com/en/docs/twitter-for-websites/javascript-api/guides/scripting-factory-functions) using the tweet's ID
- On a server (AWS Lambda in my case) use the [Twitter API](https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-show-id) to lookup the tweet's metadata
- Grab the `.mp4` video URLs from the JSON response
- Replace the tweet widget's media content with a `<video>` tag referencing the `.mp4` URL

You can view the full source code <a href="https://github.com/kofigumbs/kofi.sexy/blob/master/_functions/embed-twitter-video.js">on GitHub</a>.
