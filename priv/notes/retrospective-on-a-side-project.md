%{
    title: "Retrospective on a side-project: AutoVolume for macOS",
    tags: ~w(Swift macOS side-project),
    date: "2017-04-19",
}
---
[AutoVolume](http://www.jesseclaven.com/projects/AutoVolume/) is a free and open source app that automatically changes the volume when your Mac wakes from sleep. I'm going to give a brief overview from how it started, to being released.

## Initial idea

From my `idea.md` file for this, one night I had my volume up high because I was watching a TV show, and the next day when I received an email notification it was super loud, which was just a bit shocking and embarrassing. I wrote down the idea of, 'If sleep longer than time period x, show a notification on log in with action to mute'. The end product ended up being similar.

I took this as an opportunity to do a few other little things that I've been wanting to do: design a website for the the first time in a while, create an animation, and code a website using no IDs or classes.

## Finding time

I wrote down the idea on 16-06-26 and the first commit to the repository was on 16-12-18.  The most recent commit was on 17-04-05. From having the idea to releasing something took around 10 months. That wasn't because of difficulty in any part, but because it was very low priority to me&mdash;and that was okay!

Staying true to the original idea and a minimum feature set was key as well. It made it easy to release it sooner and evaluate if people would use it, and how.

A relatively large amount of time was spent on the animation. I searched for different ways to do it (e.g. using an animation code library) and settled on After Effects. While you can easily do it in AE, I was finding parts of the UX (importing lots of layers into AE) tedious. In the end I switched to Photoshop and created the animation in there in a few minutes.

## Evaluation

The common saying of build something for your own problem was true&mdash;and it was satisfying seeing people say thank you, and that it was just what they wanted, either knowingly, or after reading what it did. I personally always have it running and have found it useful.

It reached the #1 spot on Designer News which was cool to see. Someone posted it to Product Hunt on my behalf as well. I posted it to a private forum I'm apart of as well. What was also satisying was seeing all the people star the repository on GitHub.

## What's next

I already have my own TODO items, but people had suggestions from the get go. For now it does it's purpose and works 'perfectly' in that regard, so I'm going to leave it alone for a bit.
