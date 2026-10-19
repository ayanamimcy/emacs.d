;;; init-funcs.el --- 工具函数 -*- lexical-binding: t; -*-

;;; Commentary:
;; 各模块共用的小函数，和管理配置用的命令。

;;; Code:

(require 'init-custom)

(defun font-available-p (name)
  "字体 NAME 是否可用。"
  (find-font (font-spec :name name)))

;;; 主题

(defvar after-load-theme-hook nil
  "加载主题之后运行的 hook。")

(defun run-after-load-theme-hook (&rest _)
  "运行 `after-load-theme-hook'。"
  (run-hooks 'after-load-theme-hook))

(add-hook 'enable-theme-functions #'run-after-load-theme-hook)

;;; 浮动窗口（child frame）

(defun childframe-workable-p ()
  "当前窗口能否使用浮动窗口。图形界面可以；终端要 Emacs 31 以上。"
  (and (not noninteractive)
       (not emacs-basic-display)
       (or (display-graphic-p)
           (featurep 'tty-child-frames))
       (eq (frame-parameter (selected-frame) 'minibuffer) t)))

(defun childframe-completion-workable-p ()
  "补全列表等是否用浮动窗口显示。"
  (and (eq my-completion-style 'childframe)
       (childframe-workable-p)))

;;; 管理配置

(defun my-open-init ()
  "打开 init.el。"
  (interactive)
  (find-file user-init-file))

(defun my-open-custom ()
  "打开本机设置 custom.el。"
  (interactive)
  (find-file custom-file))

(defun my-update-config ()
  "从 GitHub 拉取最新配置（git pull），重启 Emacs 后生效。"
  (interactive)
  (let ((default-directory user-emacs-directory))
    (message "%s" (string-trim (shell-command-to-string "git pull --ff-only 2>&1")))))

(provide 'init-funcs)

;;; init-funcs.el ends here
