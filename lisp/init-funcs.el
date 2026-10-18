;;; init-funcs.el --- 工具函数 -*- lexical-binding: t; -*-

;;; Commentary:
;; 各模块共用的小函数，和管理配置用的命令。

;;; Code:

(defun font-available-p (name)
  "字体 NAME 是否可用。"
  (find-font (font-spec :name name)))

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
