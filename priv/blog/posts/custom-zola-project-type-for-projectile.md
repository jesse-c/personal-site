%{
    title: "Custom Zola project type for Projectile",
    tags: ~w(zolag emacs),
    date_created: "2022-11-06",
}
---
I currently use Zola for this website and use Emacs as my editor with [Projectile](https://github.com/bbatsov/projectile). Here's a snippet from my dotfiles to add support for Zola projects to Projectile[^1].

```diff
diff --git a/home/private_dot_config/emacs/init.el b/home/private_dot_config/emacs/init.el
index c8d15dc..a3f9260 100644
--- a/home/private_dot_config/emacs/init.el
+++ b/home/private_dot_config/emacs/init.el
@@ -797,7 +797,19 @@
   :config
   (setq projectile-project-search-path '("~/Documents/projects/" ("~/src/" . 3)))
   (setq projectile-auto-discover nil)
-  :init (counsel-projectile-mode))
+  :init (counsel-projectile-mode)
+  (projectile-register-project-type
+   'zola
+   '("config.toml" "content" "static" "templates" "themes")
+   :project-file "config.toml"
+   :compile "zola build"
+   :test "zola check"
+   :run "zola server"))

 ;; Make Ivy a bit more friendly by adding information to ivy buffers, e.g. description of commands in Alt-x, meta info when switching buffers, etc.
 (use-package ivy-rich
```

[^1]: [https://docs.projectile.mx/projectile/projects.html](https://docs.projectile.mx/projectile/projects.html)
