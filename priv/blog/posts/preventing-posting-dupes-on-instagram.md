%{
    title: "Preventing posting dupes on Instagram",
    tags: ~w(side-project machine-learning instagram photography),
    date: "2024-09-27",
}
---
# What's now simple

One of the things I've done continuously for a while is photography. Recently, I did my first paid shoot, at an art gallery opening, for one of the artists. Otherwise, it's simply things from my life, like anyone. I've almost posted a photo twice before, if it's from a previous month or year.

As with others, I was recently reminded of XKCD 1425 (Tasks) [^1] by Simon Willison [^2]. That means that I can easily solve this problem for myself.

# Models considered

Considering that I may want to do this on my iPhone, I looked at well-known models that could be run. ResNet-50 and MobileCLIP came up as suitable solutions. ResNet-50 requires a modification, since its architecture is to classify an image into 1 of 1,000 distinct classes. I remove that final layer to get a model, where I can get the embeddings from. Here is a common example of the architecture [^3].

![ResNet-50 architecture](/images/blog/resnet-50.jpg)

MobleCLIP was used as is

# Embedding similarity distribution analysis

As someone relatively new to the more in-depth analysis of ML model performance, I did a rather simple attempt. Simply as well, I was curious how similar my photos are. I used a similarity matrix, created through Torch. I used just the dot product for similarity. This is simple, possibly a little wrong, but sufficient.

The code is available in a repository online: [jesse-c/instagram-image-already-posted-check](https://github.com/jesse-c/instagram-image-already-posted-check).

Distribution of image similarities for ResNet-50:

![Similarity distribution: ResNet-50](/images/blog/instagram_dupe_check_similarity_distribution_resnet50.png)

Distribution of image similarities for MobileCLIP (S2):

S2 was picked, based on general recommendations read online, for similar tasks.

![Similarity distribution: Mobile](/images/blog/instagram_dupe_check_similarity_distribution_mobileclip.png)

## I _had_ posted a dupe

When running the analysis, and looking at the most similar pair, I did discover that I had posted a dupe! It was the same photo, albeit with slightly different editing.

## Why ResNet-50 may be preferable

There's higher similarity scores, with the distribution being centered around higher similarity values. This suggests it may be more sensitive to subtle differences.

A tighter distribution means that it could be easier to set a clear threshold, for determining if a candidate photo is a dupe. Ultimately, this would still be a manual process, but in an automated sense, you'd want to avoid surfacing candidates for a manual check.

The symmetry indicates that there isn't bias towards any particular kind of photo.

# Using it on a candidate photo

Here's the candidate photo and the top k similar images. Fundamentally, it was helpful! Here are the results:

![Top 5 similar images to candidate photo](/images/blog/instagram-embeddings-check-dupe.jpg)

# Next steps

Often if I'm editing photos, I'm not at my computer. Having this available as a private online service for myself would be helpful. Even better would be an offline iOS app! This could possibly be used by others.

[^1]: [https://xkcd.com/1425/](https://xkcd.com/1425/)

[^2]: [https://simonwillison.net/2024/Sep/24/xkcd-1425-turns-ten-years-old-today](https://simonwillison.net/2024/Sep/24/xkcd-1425-turns-ten-years-old-today)

[^3]: [https://medium.com/@nitishkundu1993/exploring-resnet50-an-in-depth-look-at-the-model-architecture-and-code-implementation-d8d8fa67e46f](https://medium.com/@nitishkundu1993/exploring-resnet50-an-in-depth-look-at-the-model-architecture-and-code-implementation-d8d8fa67e46f)
