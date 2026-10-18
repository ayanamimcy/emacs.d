;;; init-completion.el --- 补全和搜索 -*- lexical-binding: t; -*-

;;; Commentary:
;; vertico（候选列表）+ orderless（匹配方式）+ marginalia（说明）
;; + consult（搜索和切换）+ embark（对候选项执行动作）。

;;; Code:

(require 'init-custom)

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

;; 竖排候选列表
(use-package vertico
  :custom
  (vertico-count 15)
  (vertico-cycle t)
  :init (vertico-mode 1))

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

(provide 'init-completion)

;;; init-completion.el ends here
