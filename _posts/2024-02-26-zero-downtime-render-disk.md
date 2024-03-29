---
title: "Zero-downtime deploys for Render apps with disk storage"
categories: ['blog']

---

I feel obligated to write this post given how difficult it was to find prior art online.
At one point in the journey, my Google search yielded only a single (albeit helpful) Mastadon toot.
Hopefully, the content here assists the next wandering soul who ventures down this seemingly reasonable path.

**Here's the summary for those just here for the solution:** you can deploy a web server, like Caddy, as a separate Web Service in front of your app.
Caddy [can be configured](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#lb_try_duration) to "hold" incoming requests until it can connect to the downstream app, providing a window for Render to perform the instance swap.
Caddy's default docker image uses `setcap cap_net_bind_service` though, which must be unset before Render can run the image.

## Cloud disk storage is almost perfect

Render, like many PaaS providers today, offers persistent disk storage for their cloud VMs.
This is a significant development since the Heroku days, where any persistence required dedicated services like Postgres, Redis, or S3.
Now, apps with low to moderate traffic can simplify their architecture by storing data on files directly on the app server (glossing over the magic of cloud volume mounting).

Unfortunately, enabling persistent disks comes with some downsides.
Here's how [Render describes the limitations](https://docs.render.com/disks#disk-limitations-and-considerations), which is consistent with other PaaS like Fly.io and Railway:

> Adding a disk to a service prevents zero-downtime deploys. This is because:
> - When you redeploy your service, Render stops the existing instance before bringing up the new instance.
> - This instance swap takes a few seconds, during which your service is unavailable.
> - This is a necessary safeguard to prevent data corruption that can occur when different versions of an app read and write to the same disk simultaneously.

Render has reasonable default behavior here, but the rationale in the last bullet point does not apply to all apps.
My app uses SQLite as its datastore, so as long as I only interact with the disk using concurrency-safe SQLite APIs, there is no risk of data corruption.
Ideally, Render would allow me to opt out of this safeguard, since my technology stack already handles the issue.

## "All problems in computer science can be solved by another level of indirection" [- David Wheeler](https://en.wikipedia.org/wiki/David_Wheeler_%28computer_scientist%29#Quotes)

Stepping back a bit, there's no fundamental reason the instance swap needs to result in system downtime.
Render actually solves this problem for its free tier apps, which go to sleep if they haven't received traffic for some time.
Whenever the app is next pinged, Render will wait for it to start back up before routing the request.
This means that end users experience delays instead of interruptions.

We can model that same behavior by deploying a separate web server in front of our app.
If the web server is ever unable to open a connection to the downstream app, then it will simply wait a bit and try again.
Configuring Caddy with `lb_try_duration 60s` tells it to retry the downstream app for up to 60 seconds before giving up with a 502 response.

At this point, the puzzle is solved in theory, but [trying to run Caddy on Render](https://community.render.com/t/deploying-caddy-to-render/10437) errors with a cryptic message: `exec /usr/bin/caddy: operation not permitted`.
According to Google, this exact error message has only been mentioned once online (hopefully twice now) [by @eisenhorn@hdev.im](https://hdev.im/@eisenhorn/110387793844876245) who nails the root cause:

> Caddy’s container wants NET_BIND_SERVICE. Always... Apparently it comes from the official Dockerfile.

And so, here's the final Dockerfile that removes the unneeded capability and enables zero-downtime deploys to my downstream app:

```dockerfile
FROM caddy
RUN setcap -r /usr/bin/caddy
COPY <<EOF /etc/caddy/Caddyfile
:10000 {
  reverse_proxy http://my-downstream-app:10000 {
    lb_try_duration 60s
  }
}
EOF
```

As a nice bonus, I can now deploy my downstream app as a Private Service since it only receives traffic from Caddy, within my Render private network.
