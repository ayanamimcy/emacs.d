;;; init-ui.el --- 界面 -*- lexical-binding: t; -*-

;;; Commentary:
;; 字体、主题、mode-line、图标。

;;; Code:

(require 'cl-lib)
(require 'init-const)
(require 'init-custom)
(require 'init-funcs)

;;; 字体

(defun my-setup-fonts ()
  "设置字体。daemon 下每开一个图形窗口都会调用。"
  (when (display-graphic-p)
    (let ((font (cl-find-if #'font-available-p
                            (list my-font "SF Mono" "Menlo" "Hack" "DejaVu Sans Mono"))))
      (when font
        (set-face-attribute 'default nil :family font :height my-font-size)
        (set-face-attribute 'fixed-pitch nil :family font)
        ;; 中文、日文也用这个字体，不让系统挑别的 CJK 字体（宽度会对不齐）
        (dolist (charset '(han kana cjk-misc bopomofo))
          (set-fontset-font t charset (font-spec :family font)))))
    (cl-loop for font in '("Apple Color Emoji" "Noto Color Emoji")
             when (font-available-p font)
             return (set-fontset-font t 'emoji (font-spec :family font) nil 'prepend))))

(my-setup-fonts)
(add-hook 'window-setup-hook #'my-setup-fonts)
(add-hook 'server-after-make-frame-hook #'my-setup-fonts)

;;; 主题

(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (doom-themes-org-config))

(defun my-load-theme (theme)
  "关掉其他主题，加载 THEME。"
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t))

(defun my-apply-system-theme (appearance)
  "按 macOS 的外观 APPEARANCE（light 或 dark）切换主题。"
  (my-load-theme (if (eq appearance 'dark) my-theme-dark my-theme-light)))

(defun my-toggle-theme ()
  "在亮色和暗色主题之间切换。"
  (interactive)
  (my-load-theme (if (memq my-theme-dark custom-enabled-themes)
                     my-theme-light
                   my-theme-dark)))

(pcase my-theme
  ('system
   ;; emacs-plus 提供 ns-system-appearance 和外观变化时的 hook
   (if (boundp 'ns-system-appearance-change-functions)
       (progn
         (my-apply-system-theme (bound-and-true-p ns-system-appearance))
         (add-hook 'ns-system-appearance-change-functions #'my-apply-system-theme))
     (my-load-theme my-theme-light)))
  ('light (my-load-theme my-theme-light))
  ('dark (my-load-theme my-theme-dark))
  (_ (my-load-theme my-theme)))

(keymap-global-set "<f5>" #'my-toggle-theme)

;;; mode-line 和图标

(use-package nerd-icons
  :when my-icon)

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-icon my-icon)
  (doom-modeline-minor-modes nil)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project))

;;; 其他

(setq frame-title-format '("%b — Emacs"))
(column-number-mode 1)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(pixel-scroll-precision-mode 1)

(provide 'init-ui)

;;; init-ui.el ends here
