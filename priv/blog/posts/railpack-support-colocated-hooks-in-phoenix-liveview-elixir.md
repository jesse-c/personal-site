%{
    title: "Support for colocated hooks in Phoenix added to Railway",
    tags: ~w(fix railpack railway elixir phoenix go),
    date_created: "2025-08-27",
}
---
I use Railway[^1], and recently upgraded to LiveView 1.1[^2] in my Rom-to-the-Com[^5] side-project. This caused deploying my app via Railpack[^3] to fail.

Fortunately, it was a simple fix of changing the order of the build steps. I submitted a PR[^4]. It was merged in, and my app has been deployed.

Another benefit of source-available software.

[^1]: [Railway](http://railway.com)
[^2]: [rom-to-the-com@85b036768c7487f6d06ad5b0ff121eab27ec8216](https://github.com/jesse-c/rom-to-the-com/commit/85b036768c7487f6d06ad5b0ff121eab27ec8216)0
[^3]: [Railpack](https://railpack.com)
[^4]: [railpack#231](https://github.com/railwayapp/railpack/pull/231)
[^5]: [Rom-to-the-Com](https://rom-to-the-com.com)
