;;; init-completion.el --- 补全和搜索 -*- lexical-binding: t; -*-

;;; Commentary:
;; vertico（候选列表）+ orderless（匹配方式）+ marginalia（说明）
;; + consult（搜索和切换）+ embark（对候选项执行动作）。

;;; Code:

(require 'init-custom)
(require 'init-funcs)

;; 空格分隔多个关键词，不分先后（"org cap" 能匹配 org-capture）
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; 用拼音首字母匹配中文（"gzjl" 能匹配"工作记录"）
(use-package pinyinlib
  :after orderless
  :config
  (defun my-orderless-regexp-pinyin (component)
    "把 COMPONENT 当作拼音首字母匹配。"
    (orderless-regexp (pinyinlib-build-regexp-string component)))
  (add-to-list 'orderless-matching-styles #'my-orderless-regexp-pinyin))

;; 竖排候选列表。在 after-init 时启用，下面 vertico-posframe 挂在 vertico-mode 上才会触发
(use-package vertico
  :custom
  (vertico-count 15)
  (vertico-cycle t)
  :hook (after-init . vertico-mode))

;; 补全列表显示在窗口中间的浮动窗口里。daemon 每开一个图形窗口判断一次
(defun my-vertico-posframe-setup ()
  "图形界面里补全列表用浮动窗口显示。"
  (when (childframe-completion-workable-p)
    (vertico-posframe-mode 1)))

(defun my-vertico-posframe-poshandler (info)
  "中间偏下，按 `vertico-count' 预留高度（候选 + 提示行 + 边框），窗口矮时往上移。"
  (posframe-poshandler-frame-center-near-bottom
   info (* (+ vertico-count 2) (plist-get info :font-height))))

(use-package vertico-posframe
  :hook ((vertico-mode server-after-make-frame) . my-vertico-posframe-setup)
  :custom
  (vertico-posframe-poshandler #'my-vertico-posframe-poshandler)
  (vertico-posframe-parameters '((left-fringe . 8) (right-fringe . 8)))
  :custom-face
  (vertico-posframe-border ((t (:inherit posframe-border :background unspecified)))))

;; 选文件时 DEL 删一整级目录
(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
         ("RET" . vertico-directory-enter)
         ("DEL" . vertico-directory-delete-char)
         ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; 候选项旁边显示说明（命令的文档、文件大小等）
(use-package marginalia
  :init (marginalia-mode 1))

(use-package nerd-icons-completion
  :when my-icon
  :after marginalia
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config (nerd-icons-completion-mode 1))

(use-package consult
  :bind (("C-x b"   . consult-buffer)          ; 切换 buffer，同时列出最近的文件
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x r b" . consult-bookmark)
         ("M-y"     . consult-yank-pop)        ; 从剪贴历史里选
         ("M-g g"   . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g i"   . consult-imenu)           ; 跳到标题/函数
         ("M-g o"   . consult-outline)
         ("M-s l"   . consult-line)            ; 在当前文件里搜索
         ("M-s r"   . consult-ripgrep)         ; 在目录里全文搜索（需要 rg）
         ("M-s f"   . consult-find))
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref))

;; C-. 对当前候选项（或光标处的东西）执行动作：打开、复制路径、删除……
(use-package embark
  :bind (("C-." . embark-act)
         ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;;; 文件里的补全（代码、路径、buffer 里出现过的词）

;; 写代码时输入两个字符自动弹出候选；其他地方（写中文时）按 TAB 或 C-M-i 才弹出
(defun my-corfu-auto-setup ()
  "在当前 buffer 里自动弹出补全。要在 `corfu-mode' 打开之前调用。"
  (setq-local corfu-auto t))

(use-package corfu
  :hook ((after-init . global-corfu-mode)
         (prog-mode . my-corfu-auto-setup)
         (global-corfu-mode . corfu-popupinfo-mode)  ; 停一下显示候选项的文档
         (global-corfu-mode . corfu-history-mode))   ; 常用的排在前面
  :custom
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (tab-always-indent 'complete)              ; 已经缩进好时 TAB 补全
  (text-mode-ispell-word-completion nil)     ; 写文字时不补全英文单词
  :config
  (with-eval-after-load 'savehist
    (add-to-list 'savehist-additional-variables 'corfu-history)))

;; Emacs 30 的终端里没有浮动窗口，换成用文字画的弹出框
(unless (featurep 'tty-child-frames)
  (use-package corfu-terminal
    :hook (global-corfu-mode . corfu-terminal-mode)))

(use-package nerd-icons-corfu
  :when my-icon
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; 补全文件路径、buffer 里出现过的词
(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90))

(provide 'init-completion)

;;; init-completion.el ends here
