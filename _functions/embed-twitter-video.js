const https = require("https");
const { TWITTER_CONSUMER_API_KEY, TWITTER_CONSUMER_API_SECRET_KEY } = process.env;

const mediaUrl = id => {
  return "https://api.twitter.com/1.1/statuses/show.json?include_entities=true&id=" + id;
};

const request = (url, options) => {
  return new Promise((resolve) => {
    https
      .request(url, options, response => {
        let body = "";
        response.on("data", x => body += x);
        response.on("end", () => resolve({ statusCode: response.statusCode, body: body }));
      })
      .end(options.body);
  });
};

exports.handler = (event, _, callback) => {
  const credentials =
    encodeURIComponent(TWITTER_CONSUMER_API_KEY)
    + ":"
    + encodeURIComponent(TWITTER_CONSUMER_API_SECRET_KEY);
  request("https://api.twitter.com/oauth2/token", {
    method: "POST",
    body: "grant_type=client_credentials",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
      "Authorization": "Basic " + Buffer.from(credentials).toString("base64"),
    },
  }).then(response => {
    return request(mediaUrl(event.queryStringParameters.tweet), {
      method: "GET",
      headers: {
        Authorization: "Bearer " + JSON.parse(response.body).access_token,
      }
    });
  }).then(response => {
    const [ { url } ] = JSON.parse(response.body).extended_entities.media
      .map(x => x.video_info.variants)
      .reduce((acc, x) => acc.concat(x), [])
      .filter(x => x.content_type === "video/mp4")
      .sort((a, b) => b.bitrate - a.bitrate);
    callback(null, {
      statusCode: 200,
      body: url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "content-type",
      },
    });
  }).catch(err => {
    console.log(err, event);
    callback(null, { statusCode: 500, body: "" });
  });
};
