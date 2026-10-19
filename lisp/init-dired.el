;;; init-dired.el --- 文件管理 -*- lexical-binding: t; -*-

;;; Commentary:
;; dired：C-x d 打开目录，C-x C-j 打开当前文件所在的目录。

;;; Code:

(require 'init-const)
(require 'init-custom)

(use-package dired
  :ensure nil
  :custom
  (dired-dwim-target t)                          ; 两个 dired 并排时，复制/移动默认到另一个
  (dired-kill-when-opening-new-dired-buffer t)   ; 进子目录不多开 buffer
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'top)
  (dired-auto-revert-buffer #'dired-buffer-stale-p)
  (dired-mouse-drag-files t)                     ; 可以把文件拖到别的程序里
  :config
  ;; 目录排在前面、大小显示成 K/M。Mac 自带的 ls 不支持，装了 coreutils 就用 gls
  (when-let* ((ls (if sys/macp (executable-find "gls") "ls")))
    (setq insert-directory-program ls
          dired-listing-switches "-alh --group-directories-first"))
  (unless (string-search "--group" dired-listing-switches)
    (setq dired-listing-switches "-alh")))

;; C-x C-q 把文件列表当文本改（批量重命名），也能改权限
(use-package wdired
  :ensure nil
  :custom (wdired-allow-to-change-permissions t))

;; 文件图标、按类型上色
(use-package nerd-icons-dired
  :when my-icon
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package diredfl
  :hook (dired-mode . diredfl-mode))

(provide 'init-dired)

;;; init-dired.el ends here
