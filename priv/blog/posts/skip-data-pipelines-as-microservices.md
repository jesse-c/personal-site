%{
    title: "Skip data/ML pipelines as microservices",
    tags: ~w(pipelines microservices data machine-learning),
    date_created: "2025-05-11",
}
---
You can make the same mistakes with deciding to use microservices, but with data/ML pipelines, instead of the traditionally understood meaning of service. This is where 1 pipeline = 1 microservice.

Similarly with deciding between monoliths and microservices, you can too quickly go for separate _micro-pipelines_, instead of 1, _monolith_ pipeline.

An example of a shared problem is, why introduce network worries (i.e. pipeline A kick off pipeline B)?

Some things that make monolith pipelines comfortable, are:

- Save state regularly (à la checkpoints)
- Go _long_ so many possibly separate pipelines are one, but go _wide_ so they don't conflict with each other AKA scale horizontally
- Have data flow unidirectionally, such as don't write to a DB, then need to read back from it later
- Testing and debugging is simply easier as you can rely upon traditional programming approaches to both

I've found that I've needed to merge pipelines at work, and hope to help you avoid this pain.
