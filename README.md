# Sharpen The Saw

> Live as if you were to die tomorrow. Learn as if you were to live forever.

― <cite>Mahatma Gandhi</cite>

---

The title and the quote above summarize well my personal goals for this blog.
I hope the content will help others sharpen their saw.

## Run locally for development:

Add the following lines to the `Gemfile` to avoid [a known issue with webrick](https://github.com/BretFisher/jekyll-serve#known-issues):
```gemfile
gem "sdbm"
gem "webrick"
gem "net-telnet"
gem "xmlrpc"
```

Then using docker:
```bash
docker run --rm --volume="$PWD:/srv/jekyll:Z" --publish [::1]:4000:4000 jekyll/jekyll jekyll serve
```

Or even better with docker-compose:
```bash
docker-compose up -d
```
