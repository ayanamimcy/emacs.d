;;; init-claude.el --- Claude Code（claude-code-ide） -*- lexical-binding: t; -*-

;;; Commentary:
;; claude-code-ide：在 Emacs 里跑 Claude Code CLI，通过 MCP 和 Emacs 双向连接。
;; Claude 能看到当前文件和选中的行，改代码时用 ediff 给出方案（可以先改再接受），
;; 还能调用 Emacs 的 xref（LSP）、imenu、tree-sitter、project。
;; 需要本机装好 Claude Code CLI（`claude' 在 PATH 里，第一次在终端里运行 claude 登录）。
;; 包不在软件源里，用 use-package 的 :vc 从 GitHub 装（Emacs 30 起才有），升级：
;; M-x package-vc-upgrade RET claude-code-ide。
;;
;; 按键：C-c i c 打开菜单（开会话、继续/恢复对话、切换窗口、停止等）。
;; 在 Claude 终端里：C-c C-x 不再把当前文件 / 选中的行告诉 Claude。

;;; Code:

(use-package claude-code-ide
  :if (>= emacs-major-version 30)
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :commands (claude-code-ide claude-code-ide-menu)
  :bind ("C-c i c" . claude-code-ide-menu)
  :custom
  (claude-code-ide-terminal-backend 'eat) ; 和 init-shell.el 用同一个终端，不用编译 vterm
  :config
  (claude-code-ide-emacs-tools-setup))   ; 让 Claude 能用 xref、imenu、tree-sitter、project

(provide 'init-claude)

;;; init-claude.el ends here
