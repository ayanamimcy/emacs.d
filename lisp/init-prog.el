;;; init-prog.el --- 写代码 -*- lexical-binding: t; -*-

;;; Commentary:
;; 项目（project.el）、tree-sitter 语法高亮、eglot（LSP：跳转、补全、报错）、flymake。
;; 语言服务器要自己装（见 README），装了的语言打开文件时自动启动 eglot。

;;; Code:

;; 项目：C-x p 开头，git 仓库就是一个项目
(use-package project
  :ensure nil
  :bind (:map project-prefix-map
         ("g" . consult-ripgrep)               ; 全文搜索，边输入边出结果
         ("m" . magit-project-status)
         ("t" . my-term-toggle))
  :custom
  ;; C-x p p 选完项目后接着做什么
  (project-switch-commands '((project-find-file "找文件" ?f)
                             (consult-ripgrep "搜索" ?g)
                             (project-dired "目录" ?d)
                             (magit-project-status "Magit" ?m)
                             (my-term-toggle "终端" ?t))))

;; 按 .editorconfig 设置缩进等
(use-package editorconfig
  :ensure nil
  :hook (after-init . editorconfig-mode))

;; tree-sitter：更准确的语法高亮和缩进。第一次打开某种语言的文件时询问是否下载语法
;; （需要 C 编译器：Mac 上是 Xcode Command Line Tools）
(use-package treesit-auto
  :hook (after-init . global-treesit-auto-mode)
  :custom (treesit-auto-install 'prompt)
  :config
  ;; Emacs 没有自带模式的语言（Go、Rust 等）直接用 tree-sitter 模式打开，打开时才会询问下载语法。
  ;; 有自带模式的（Python 等）由 treesit-auto 决定：有语法就切换，没有就询问，不下载就保持原来的模式
  (treesit-auto-add-to-auto-mode-alist
   (seq-keep (lambda (recipe)
               (unless (seq-some #'fboundp (ensure-list (treesit-auto-recipe-remap recipe)))
                 (treesit-auto-recipe-lang recipe)))
             treesit-auto-recipe-list))
  ;; 语法还没装时的"Cannot activate tree-sitter"只记到 *Warnings*，不弹窗口
  (add-to-list 'warning-suppress-types '(treesit)))

;; LSP
(defun my-eglot-ensure ()
  "能找到这种语言的语言服务器时才启动 eglot，没装的语言不提示。"
  (require 'eglot)
  (when (ignore-errors
          (let ((program (car (nth 3 (eglot--guess-contact)))))
            (and (stringp program) (executable-find program))))
    (eglot-ensure)))

(use-package eglot
  :ensure nil
  :hook (prog-mode . my-eglot-ensure)
  :bind (:map eglot-mode-map
         ("C-c e a" . eglot-code-actions)
         ("C-c e r" . eglot-rename)
         ("C-c e f" . eglot-format-buffer))
  :custom
  (eglot-autoshutdown t)                    ; 项目的文件都关了就停掉语言服务器
  (eglot-events-buffer-config '(:size 0)))  ; 不记通信日志，快一些

;; 报错：M-n / M-p 跳到下一个 / 上一个错误
(use-package flymake
  :ensure nil
  :bind (:map flymake-mode-map
         ("M-n" . flymake-goto-next-error)
         ("M-p" . flymake-goto-prev-error)))

(provide 'init-prog)

;;; init-prog.el ends here
