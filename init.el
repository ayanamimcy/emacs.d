;;; init.el --- 入口 -*- lexical-binding: t; no-byte-compile: t -*-

;;; Commentary:
;; 框架参照 Centaur Emacs（https://github.com/seagle0128/.emacs.d），
;; 只保留日程、写作和轻量写代码用得到的部分。
;;
;; 加载顺序：常量 → 选项 → 工具函数 → 包管理（读入 custom.el）→ 各功能模块
;; → custom-post.el。每台机器不同的设置写在 custom.el（不进 git）。

;;; Code:

(when (version< emacs-version "30.1")
  (error "需要 Emacs 30.1 以上，当前是 %s" emacs-version))

(dolist (dir '("lisp" "site-lisp"))
  (let ((path (locate-user-emacs-file dir)))
    (when (file-directory-p path)
      (add-to-list 'load-path path))))

;; 框架
(require 'init-const)
(require 'init-custom)
(require 'init-funcs)
(require 'init-package)

;; 基础
(require 'init-base)
(require 'init-ui)
(require 'init-edit)
(require 'init-completion)

;; 日程和写作
(require 'init-calendar)
(require 'init-org)
(require 'init-markdown)

;; 所有模块加载完之后，本机的覆盖设置
(when (file-exists-p my-custom-post-file)
  (load my-custom-post-file nil 'nomessage))

;;; init.el ends here
