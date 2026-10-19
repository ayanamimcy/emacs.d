;;; init-vcs.el --- git -*- lexical-binding: t; -*-

;;; Commentary:
;; magit（C-x g）、改动标记（diff-hl）。

;;; Code:

(require 'init-funcs)

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-c g" . magit-file-dispatch))   ; 当前文件：blame、历史等
  :custom (magit-diff-refine-hunk t))       ; diff 里标出具体改了哪几个字

;; magit 的命令菜单（transient）也用浮动窗口显示，终端里退回底部。
;; 和 which-key 一样是全局开关，每次切换窗口都重新判断
(defun my-transient-posframe-setup (&rest _)
  "图形界面里 transient 菜单用浮动窗口显示，终端里用底部。状态没变时什么都不做。"
  (let ((want (childframe-completion-workable-p)))
    (unless (eq want (bound-and-true-p transient-posframe-mode))
      (transient-posframe-mode (if want 1 -1)))))

(use-package transient-posframe
  :hook ((emacs-startup server-after-make-frame window-selection-change-functions)
         . my-transient-posframe-setup)
  :custom
  (transient-posframe-border-width posframe-border-width)
  (transient-posframe-min-width 80)
  (transient-posframe-poshandler #'posframe-poshandler-frame-center-near-bottom)
  (transient-posframe-parameters '((left-fringe . 8) (right-fringe . 8)))
  :custom-face
  (transient-posframe-border ((t (:inherit posframe-border :background unspecified)))))

;; 行号旁边标出改过的行，未保存的改动也实时显示
(use-package diff-hl
  :hook ((after-init . global-diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode 1)
  ;; 终端里没有 fringe，标在左边空白处（daemon 以图形窗口为主，不改）
  (unless (or (display-graphic-p) (daemonp))
    (diff-hl-margin-mode 1)))

(provide 'init-vcs)

;;; init-vcs.el ends here
