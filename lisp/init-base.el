;;; init-base.el --- 基础设置 -*- lexical-binding: t; -*-

;;; Commentary:
;; 编码、备份、历史记录、server、Mac 键位等。

;;; Code:

(require 'init-const)
(require 'init-custom)

(set-language-environment "UTF-8")
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80)

(setq ring-bell-function #'ignore
      use-short-answers t
      sentence-end-double-space nil
      kill-do-not-save-duplicates t
      delete-by-moving-to-trash t)

;; 备份和自动保存文件集中放在配置目录里，不留在 ~/org 等同步目录里
(setq backup-directory-alist `(("." . ,(locate-user-emacs-file "backups")))
      backup-by-copying t
      create-lockfiles nil)
(let ((dir (locate-user-emacs-file "auto-save/")))
  (make-directory dir t)
  (setq auto-save-file-name-transforms `((".*" ,dir t))))

;; Mac：Cmd 当 Meta，Option 当 Super
(when sys/macp
  (with-no-warnings
    (setq mac-command-modifier 'meta
          mac-option-modifier 'super)))

;; 空闲时才做 GC
(use-package gcmh
  :hook (emacs-startup . gcmh-mode)
  :custom
  (gcmh-idle-delay 'auto)
  (gcmh-auto-idle-delay-factor 10)
  (gcmh-high-cons-threshold #x4000000)) ; 64MB

(use-package exec-path-from-shell
  :when (and my-use-exec-path-from-shell (memq window-system '(mac ns)))
  :config (exec-path-from-shell-initialize))

;; 让 emacsclient 能连上。Linux 上用 systemd 的 emacs.service（daemon）
(use-package server
  :ensure nil
  :unless (daemonp)
  :config
  (unless (server-running-p)
    (server-start)))

(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :custom
  (recentf-max-saved-items 300)
  (recentf-exclude '("/elpa/" "/tmp/" "COMMIT_EDITMSG\\'" "\\.cache/")))

(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode)
  :custom
  (history-length 1000)
  (savehist-additional-variables '(kill-ring search-ring regexp-search-ring)))

(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))

;; 按了前缀键停一下，提示后面能按什么
(use-package which-key
  :ensure nil
  :hook (after-init . which-key-mode))

;; 通过 SSH 在终端里用（emacsclient -t）时，复制的内容送到本地剪贴板（OSC 52）
(use-package clipetty
  :hook (after-init . global-clipetty-mode))

(provide 'init-base)

;;; init-base.el ends here
