%{
    title: "Alpha version of Clevis released",
    tags: ~w(side-project documentation rust clevis),
    date_created: "2025-06-08",
}
---
# Release announcement
On 2025-06-08 I wrote about _documentation decay_[^1] and gave a snippet of a program that I began using a little bit.

I'm happy to release the alpha version of the evolution of that, called Clevis[^2]. It's a CLI tool, written in Rust, and there's also a GitHub Action[^3] available.

# Example

Here's a real-world example from my day job:

```diff
From b0611ce5c8031ecc54379630e1143f4f09ef68ee Mon Sep 17 00:00:00 2001
From: Jesse Claven <XXXXX>
Date: Sun, 8 Jun 2025 17:36:00 +0100
Subject: [PATCH] test: Add link checks for README

---
 .github/workflows/ci.yml |  11 ++
 clevis.toml              | 318 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 329 insertions(+)
 create mode 100644 clevis.toml

diff --git a/.github/workflows/ci.yml b/.github/workflows/ci.yml
index 7eba5977..0bb560d3 100644
--- a/.github/workflows/ci.yml
+++ b/.github/workflows/ci.yml
@@ -80,3 +80,14 @@ jobs:
 
       - name: Run tests
         run: just test -v -m "'not flaky_on_ci and not transformers'" --ignore tests/test_argilla_v2.py --ignore tests/test_task_distribution.py
+
+  linker:
+    runs-on: ubuntu-latest
+    name: "Check links"
+    steps:
+      - name: Check out repository code
+        uses: actions/checkout@v4
+
+      - name: Check links throughout the project for decay
+        uses: jesse-c/clevis-action@main
+        continue-on-error: true
diff --git a/clevis.toml b/clevis.toml
new file mode 100644
index 00000000..925fdea3
--- /dev/null
+++ b/clevis.toml
@@ -0,0 +1,318 @@
+[links.install.a]
+kind = "span"
+file_path = "README.md"
+[links.install.a.start]
+line = 10
+column = 6
+[links.install.a.end]
+line = 10
+column = 12
+[links.install.b]
+kind = "span"
+file_path = "justfile"
+[links.install.b.start]
+line = 11
+column = 1
+[links.install.b.end]
+line = 11
+column = 7
+
+[links.list.a]
+kind = "span"
+file_path = "README.md"
+[links.list.a.start]
+line = 16
+column = 6
+[links.list.a.end]
+line = 16
+column = 11
+
+[links.list.b]
+kind = "span"
+file_path = "justfile"
+[links.list.b.start]
+line = 8
+column = 11
+[links.list.b.end]
+line = 8
+column = 16
+
+[links.vespa_dev_setup.a]
+kind = "span"
+file_path = "tests/local_vespa/README.md"
+[links.vespa_dev_setup.a.start]
+line = 10
+column = 6
+[links.vespa_dev_setup.a.end]
+line = 10
+column = 20
+
+[links.vespa_dev_setup.b]
+kind = "span"
+file_path = "tests/local_vespa/local_vespa.just"
+[links.vespa_dev_setup.b.start]
+line = 54
+column = 1
+[links.vespa_dev_setup.b.end]
+line = 54
+column = 15
+
+[links.test.a]
+kind = "span"
+file_path = "docs/docs/developers/justfile.md"
+[links.test.a.start]
+line = 12
+column = 6
+[links.test.a.end]
+line = 12
+column = 9
+
+[links.test.b]
+kind = "span"
+file_path = "justfile"
+[links.test.b.start]
+line = 17
+column = 1
+[links.test.b.end]
+line = 17
+column = 4
+
+[links.get-concept.a]
+kind = "span"
+file_path = "docs/docs/developers/justfile.md"
+[links.get-concept.a.start]
+line = 18
+column = 6
+[links.get-concept.a.end]
+line = 18
+column = 17
+
+[links.get-concept.b]
+kind = "span"
+file_path = "justfile"
+[links.get-concept.b.start]
+line = 51
+column = 1
+[links.get-concept.b.end]
+line = 51
+column = 12
+
+[links.train.a]
+kind = "span"
+file_path = "docs/docs/developers/justfile.md"
+[links.train.a.start]
+line = 24
+column = 6
+[links.train.a.end]
+line = 24
+column = 11
+
+[links.train.b]
+kind = "span"
+file_path = "justfile"
+[links.train.b.start]
+line = 55
+column = 1
+[links.train.b.end]
+line = 55
+column = 6
+
+[links.evaluate.a]
+kind = "span"
+file_path = "docs/docs/developers/justfile.md"
+[links.evaluate.a.start]
+line = 36
+column = 6
+[links.evaluate.a.end]
+line = 36
+column = 14
+
+[links.evaluate.b]
+kind = "span"
+file_path = "justfile"
+[links.evaluate.b.start]
+line = 59
+column = 1
+[links.evaluate.b.end]
+line = 59
+column = 9
+
+[links.promote.a]
+kind = "span"
+file_path = "docs/docs/developers/justfile.md"
+[links.promote.a.start]
+line = 54
+column = 6
+[links.promote.a.end]
+line = 54
+column = 13
+
+[links.promote.b]
+kind = "span"
+file_path = "justfile"
+[links.promote.b.start]
+line = 63
+column = 1
+[links.promote.b.end]
+line = 63
+column = 8
+
+[links.demote.a]
+kind = "span"
+file_path = "docs/docs/developers/justfile.md"
+[links.demote.a.start]
+line = 60
+column = 6
+[links.demote.a.end]
+line = 60
+column = 12
+
+[links.demote.b]
+kind = "span"
+file_path = "justfile"
+[links.demote.b.start]
+line = 67
+column = 1
+[links.demote.b.end]
+line = 67
+column = 7
+
+[links.up-local-wikibase.a]
+kind = "span"
+file_path = "tests/local_wikibase/README.md"
+[links.up-local-wikibase.a.start]
+line = 10
+column = 6
+[links.up-local-wikibase.a.end]
+line = 10
+column = 22
+
+[links.up-local-wikibase.b]
+kind = "span"
+file_path = "tests/local_wikibase/local_wikibase.just"
+[links.up-local-wikibase.b.start]
+line = 2
+column = 1
+[links.up-local-wikibase.b.end]
+line = 2
+column = 17
+
+[links.down-local-wikibase.a]
+kind = "span"
+file_path = "tests/local_wikibase/README.md"
+[links.down-local-wikibase.a.start]
+line = 16
+column = 6
+[links.down-local-wikibase.a.end]
+line = 16
+column = 24
+
+[links.down-local-wikibase.b]
+kind = "span"
+file_path = "tests/local_wikibase/local_wikibase.just"
+[links.down-local-wikibase.b.start]
+line = 6
+column = 1
+[links.down-local-wikibase.b.end]
+line = 6
+column = 19
+
+[links.deploy-classifiers.a]
+kind = "span"
+file_path = "scripts/README.md"
+[links.deploy-classifiers.a.start]
+line = 27
+column = 6
+[links.deploy-classifiers.a.end]
+line = 27
+column = 24
+
+[links.deploy-classifiers.b]
+kind = "span"
+file_path = "justfile"
+[links.deploy-classifiers.b.start]
+line = 159
+column = 1
+[links.deploy-classifiers.b.end]
+line = 159
+column = 19
+
+[links.update-inference-classifiers.a]
+kind = "span"
+file_path = "flows/classifier_specs/README.md"
+[links.update-inference-classifiers.a.start]
+line = 10
+column = 6
+[links.update-inference-classifiers.a.end]
+line = 10
+column = 34
+
+[links.update-inference-classifiers.b]
+kind = "span"
+file_path = "justfile"
+[links.update-inference-classifiers.b.start]
+line = 147
+column = 1
+[links.update-inference-classifiers.b.end]
+line = 147
+column = 29
+
+[links.generate-static-site.a]
+kind = "span"
+file_path = "static_sites/concept_librarian/README.md"
+[links.generate-static-site.a.start]
+line = 18
+column = 6
+[links.generate-static-site.a.end]
+line = 18
+column = 25
+
+[links.generate-static-site.b]
+kind = "span"
+file_path = "justfile"
+[links.generate-static-site.b.start]
+line = 155
+column = 1
+[links.generate-static-site.b.end]
+line = 155
+column = 20
+
+[links.serve-static-site.a]
+kind = "span"
+file_path = "static_sites/concept_librarian/README.md"
+[links.serve-static-site.a.start]
+line = 26
+column = 6
+[links.serve-static-site.a.end]
+line = 26
+column = 22
+
+[links.serve-static-site.b]
+kind = "span"
+file_path = "justfile"
+[links.serve-static-site.b.start]
+line = 151
+column = 1
+[links.serve-static-site.b.end]
+line = 151
+column = 17
+
+[links.predict.a]
+kind = "span"
+file_path = "static_sites/vibe_check/README.md"
+[links.predict.a.start]
+line = 24
+column = 6
+[links.predict.a.end]
+line = 24
+column = 13
+
+[links.predict.b]
+kind = "span"
+file_path = "justfile"
+[links.predict.b.start]
+line = 75
+column = 1
+[links.predict.b.end]
+line = 75
+column = 8
```

[^1]: [From write-up to prototype of static checks for anti-documentation decay](from-write-up-to-prototype-of-static-checks-for-anti-documentation-decay)
[^2]: [Clevis](https://github.com/jesse-c/clevis)
[^3]: [Clevis GitHub Action](https://github.com/jesse-c/clevis-action)
