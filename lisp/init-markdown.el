;;; init-markdown.el --- Markdown -*- lexical-binding: t; -*-

;;; Commentary:
;; 已有的 md 笔记照常编辑。

;;; Code:

(use-package markdown-mode
  :mode ("\\.md\\'" . gfm-mode)
  :hook (markdown-mode . visual-line-mode)
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-header-scaling t))

(provide 'init-markdown)

;;; init-markdown.el ends here
