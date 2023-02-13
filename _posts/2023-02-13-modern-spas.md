---
title: 'Modern SPAs without bundlers, CDNs, or NodeJS'
categories: ['blog']

---

I typically start new front-end prototypes with a single HTML file that I view using a `file://` URL.
I enjoy this practice of incrementally growing my projects, so I'll keep working in that single file for as long as I can.
Once it becomes unwieldy, I'll split out the CSS and JavaScript into dedicated files.
Then when manual DOM manipulation gets too complex, I'll reach for a front-end framework.
Until recently though, I wasn't sure how to make this step feel incremental.
Most framework installations recommend `npm install`, which means my project will now depend on NodeJS.
Some frameworks have a hosted CDN option, but I'm similarly uncomfortable accepting that infrastructural dependency.
Ideally, I'd just grab the framework files, import them from my JavaScript, and then carry on with my `file://` URL.

Well, creating that ideal setup was easier than I expected.
My first key discovery was the [`<script type=importmap>`][] element.
Import maps let you write JavaScript modules that depend on named packages without using a bundler.
The end result is a SPA that feels modern and standard, but without the [need for a compilation step][]:

```html
<!DOCTYPE html>
<script type=importmap>
  {
    "imports": {
      "solid-js": "/node_modules/solid-js/dist/solid.js",
      "solid-js/html": "/node_modules/solid-js/html/dist/html.js",
      "solid-js/web": "/node_modules/solid-js/web/dist/web.js"
    }
  }
</script>
<script type=module>
  // standard import declarations thanks to the import map above
  import html from 'solid-js/html'
  import { render } from 'solid-js/web'

  const HelloWorld = () => {
    // tagged template literals feel close enough to JSX (the defacto standard)
    return html`<div>Hello World!</div>`
  }

  render(HelloWorld, document.getElementById('app'))
</script>
<main id=app></main>
```

That's almost all of it.
This HTML file can be interpreted by most modern browsers, but it references files in `/node_modules/solid-js` which must be installed.
I _could_ do this with `npm install`, but it's surprisingly straightforward to download the package directly:

```bash
download-package() {
  set -eo pipefail
  local PACKAGE_NAME=$1
  local PACKAGE_VERSION=$2
  local PACKAGE_CHECKSUM=$3
  local PACKAGE_FILE="$PACKAGE_NAME-$PACKAGE_VERSION.tgz"

  # download the tarball from NPM's registry
  mkdir -p "node_modules/$PACKAGE_NAME"
  curl "https://registry.npmjs.org/$PACKAGE_NAME/-/$PACKAGE_FILE" > "node_modules/$PACKAGE_FILE"

  # verify the tarball's SHA512 checksum
  local PACKAGE_SHA=`shasum -b -a 512 "node_modules/$PACKAGE_FILE" | awk '{ print $1 }' | xxd -r -p | base64`
  [ "$PACKAGE_SHA" == "$PACKAGE_CHECKSUM" ]

  # uncompress the package into a directory matching its name
  gunzip -dc "node_modules/$PACKAGE_FILE" | tar -xf - --strip-components 1 -C "node_modules/$PACKAGE_NAME"
}

# install by manually providing metadata from https://registry.npmjs.org/solid-js
download-package solid-js 1.6.6 "5x33mEbPI8QLuywvFjQP4krjWDr8xiYFgZx9KCBH7b0ZzypQCHaUubob7bK6i+1u6nhaAqhWtvXS587Kb8DShA=="
```

That's all of it: my bundler-free setup for writing modern JavaScript apps.
When I need to add a dependency, I invoke `download-package` and then declare it in the import map.
I like this setup because it feels like I'm only using the bits of the NodeJS ecosystem that I need right now.
Later in the project, I could opt into more of what NodeJS has to offer, but it's neat that I'm not forced into it just to use a UI framework.

[`<script type=importmap>`]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script/type/importmap
[need for a compilation step]: https://www.solidjs.com/tutorial/introduction_basics
