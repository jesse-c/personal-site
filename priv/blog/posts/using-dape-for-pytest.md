%{
    title: "Using `Dape` for `pytest`",
    tags: ~w(emacs python pytest tip debug-adapter-protocol dape),
    date_created: "2025-05-04",
}
---
DAP is to debugging that LSP is to coding. For Emacs, `Dape`[^1] is to `dap-mode` that Eglot is to `lsp-mode`.

It took me longer than it should've, but, I've now confiused `Dape` for both Python code execution debugging and test debugging[^2]. There's not a huge amount of examples of this configuration around, so I'm sharing it here to help others.

I've based my configs on the default ones for Python, and then hastily adapted them. If you want to use verbose modes for pytest, you could add `"-v"` to the `args` list for the `pytest` config.

```lisp
  (add-to-list 'dape-configs
               `(pytest modes (python-mode python-ts-mode)
                        ensure (lambda (config) (dape-ensure-command config)
                                 (let ((python (dape-config-get config 'command)))
                                   (unless
                                       (zerop
                                        (call-process-shell-command
                                         (format "%s -c \"import debugpy.adapter\"" python)))
                                     (user-error "%s module debugpy is not installed"
                                                 python))))
                        command dap-python-executable
                        command-args ("-m" "debugpy.adapter" "--host" "0.0.0.0" "--port" :autoport)
                        port :autoport
                        :request "launch"
                        :type "python"
                        :mode "test"
                        :cwd dape-cwd
                        :module "pytest"
                        :args [dape-buffer-default]
                        :justMyCode nil
                        :console "integratedTerminal"
                        :showReturnValue t
                        :stopOnEntry nil))
```

[^1]: [Dape](https://github.com/svaante/dape)
[^2]: [https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/init.el#L2138-L2185](https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/init.el#L2138-L2185)
