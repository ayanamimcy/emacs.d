;;; init-base.el --- 基础设置 -*- lexical-binding: t; -*-

;;; Commentary:
;; 编码、备份、历史记录、server、Mac 键位等。

;;; Code:

(require 'init-const)
(require 'init-custom)
(require 'init-funcs)

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

;; 包在 :when 不满足时也会被安装，所以外面再包一层，只在 Mac 上装
(when (and my-use-exec-path-from-shell sys/macp)
  (use-package exec-path-from-shell
    :when (memq window-system '(mac ns))
    :config (exec-path-from-shell-initialize)))

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

;; 浮动窗口（child frame）的公共设置，vertico-posframe 等都用它
(use-package posframe
  :hook (after-load-theme . posframe-delete-all) ; 换主题后重建，用上新颜色
  :init
  (defface posframe-border
    '((t (:inherit region)))
    "浮动窗口边框的颜色。"
    :group 'posframe)
  (defvar posframe-border-width 2
    "浮动窗口边框的宽度。")
  :custom-face
  (child-frame-border ((t (:inherit posframe-border))))
  :config
  (defun posframe-poshandler-frame-center-near-bottom (info &optional height)
    "把浮动窗口放在水平居中、垂直方向中间偏下的位置。
放不下时往上移，底部不压住最下面的 mode-line 和回显区。HEIGHT 是预计的高度（像素）：
posframe 传进来的高度有时是调整大小之前的旧值（X 下调整大小是异步的），
所以调用方知道高度时要传进来。"
    (let* ((parent-height (plist-get info :parent-frame-height))
           (line-height (plist-get info :font-height))
           (height (max (or height 0) (plist-get info :posframe-height))))
      (cons (/ (- (plist-get info :parent-frame-width)
                  (plist-get info :posframe-width))
               2)
            (max 0 (min (/ (+ parent-height (* 2 line-height)) 2)
                        (- parent-height (* 2 line-height) height)))))))

;; 按键提示也用浮动窗口显示，终端里退回底部显示。which-key-posframe 是全局开关，
;; daemon 同时开着图形窗口和终端窗口时，每次切换窗口都要重新判断
(defun my-which-key-posframe-max-dimensions (_)
  "提示框最多占窗口下半部分（扣掉中间偏下的 1 行、mode-line、回显区和边框）。
放不下时 which-key 会分页（C-h n 翻页）。"
  (cons (max 5 (- (/ (frame-height) 2) 4))
        (frame-width)))

(defun my-which-key-posframe-setup (&rest _)
  "图形界面里 which-key 用浮动窗口显示，终端里用底部。状态没变时什么都不做。"
  (let ((want (and which-key-mode (childframe-completion-workable-p))))
    (unless (eq want (bound-and-true-p which-key-posframe-mode))
      (if want
          (progn
            (which-key-posframe-mode 1)
            ;; which-key-posframe 默认允许整个窗口高，换成上面的函数（关闭模式时它会恢复原值）
            (setq which-key-custom-popup-max-dimensions-function
                  #'my-which-key-posframe-max-dimensions))
        (which-key-posframe-mode -1)))))

(use-package which-key-posframe
  :hook ((emacs-startup server-after-make-frame window-selection-change-functions)
         . my-which-key-posframe-setup)
  :custom
  (which-key-posframe-border-width posframe-border-width)
  (which-key-posframe-poshandler #'posframe-poshandler-frame-center-near-bottom)
  (which-key-posframe-parameters '((left-fringe . 8) (right-fringe . 8)))
  :custom-face
  (which-key-posframe-border ((t (:inherit posframe-border :background unspecified)))))

;; 通过 SSH 在终端里用（emacsclient -t）时，复制的内容送到本地剪贴板（OSC 52）
(use-package clipetty
  :hook (after-init . global-clipetty-mode))

(provide 'init-base)

;;; init-base.el ends here
