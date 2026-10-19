;;; init-shell.el --- 终端 -*- lexical-binding: t; -*-

;;; Commentary:
;; eat：Emacs 里的终端，能跑 htop、vim 等全屏程序，不用编译。
;; C-`（终端里的 Emacs 用 C-c t）在底部弹出 / 收起。

;;; Code:

(defun my-term-toggle ()
  "在底部弹出或收起终端。在项目里时目录是项目根目录，每个项目一个终端。"
  (interactive)
  (if (derived-mode-p 'eat-mode)
      (quit-window)
    (if (project-current)
        (eat-project)
      (eat))))

(keymap-global-set "C-`" #'my-term-toggle)
(keymap-global-set "C-c t" #'my-term-toggle)

;; 终端显示在底部，占三分之一高
(add-to-list 'display-buffer-alist
             '("\\*\\(?:.*-\\)?eat\\*\\'"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.33)))

(use-package eat
  :hook ((eshell-load . eat-eshell-mode)                 ; eshell 里也能跑全屏程序
         (eshell-load . eat-eshell-visual-command-mode))
  :custom (eat-kill-buffer-on-exit t)
  :config
  ;; 终端里按 C-` 也能收起，不发给 shell
  (add-to-list 'eat-semi-char-non-bound-keys [?\C-`])
  (eat-update-semi-char-mode-map))

(provide 'init-shell)

;;; init-shell.el ends here
