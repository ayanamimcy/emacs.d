;;; init-edit.el --- 编辑 -*- lexical-binding: t; -*-

;;; Commentary:
;; 自动重新载入、撤销树、快速跳转（支持拼音首字母）。

;;; Code:

;; 中文没有空格，visual-line-mode 下按字换行
(setq word-wrap-by-category t)

;; 别的设备同步过来修改了文件，自动重新载入
(use-package autorevert
  :ensure nil
  :hook (after-init . global-auto-revert-mode)
  :custom (global-auto-revert-non-file-buffers t))

;; 选中后输入直接替换
(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

;; 括号自动配对只在写代码时开，写中文时会碍事
(use-package elec-pair
  :ensure nil
  :hook (prog-mode . electric-pair-local-mode))

;; 超长行的文件不卡
(use-package so-long
  :ensure nil
  :hook (after-init . global-so-long-mode))

;; 撤销树：C-x u 可视化地回到任意历史状态
(use-package vundo
  :bind ("C-x u" . vundo)
  :custom (vundo-glyph-alist vundo-unicode-symbols))

;; C-a / C-e 先到行首第一个字符 / 行尾代码末尾，再按一次到真正的行首行尾
(use-package mwim
  :bind (([remap move-beginning-of-line] . mwim-beginning)
         ([remap move-end-of-line] . mwim-end)))

;; 快速跳转：输入两个字符，在屏幕上的位置旁出现字母，按字母跳过去
(use-package avy
  :bind (("C-;" . avy-goto-char-2)
         ("M-g w" . avy-goto-word-1)
         ("M-g l" . avy-goto-line))
  :custom
  (avy-all-windows nil)
  (avy-background t))

;; avy 支持拼音首字母：输入 z 能跳到"中"
(use-package ace-pinyin
  :after avy
  :config (ace-pinyin-global-mode 1))

(provide 'init-edit)

;;; init-edit.el ends here
