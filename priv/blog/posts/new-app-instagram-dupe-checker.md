%{
    title: "New app: Check if I would've posted an image on Instagram",
    tags: ~w(side-project machine-learning instagram photography),
    date_created: "2024-10-20",
}
---
This is an implementation[^1] as a follow-up to a previous post[^2] about preventing posting dupes on Instagram, through a simple ML model.

For now, you can upload an image, and it'll give the top k (5, at the moment), images that your image is similar to.

This approach makes it so that I can use it, which is the main priority, and also lets others have fun with it. Usually if I'm editing photos, I have access to the internet as well. I have thought of an offline- and mobily-only version of how it could be built.

Check it out at [Instagram dupe checker](/apps/instagram-dupe-checker).

[^1]: [https://github.com/jesse-c/instagram-image-already-posted-check](https://github.com/jesse-c/instagram-image-already-posted-check)
[^2]: [Preventing posting dupes on Instagram](preventing-posting-dupes-on-instagram)

