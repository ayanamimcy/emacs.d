;;; init-const.el --- 常量 -*- lexical-binding: t; -*-

;;; Commentary:
;; 系统判断和配置文件路径。别的模块里用 `sys/macp' 等，不直接写 `system-type'。

;;; Code:

(defconst sys/macp (eq system-type 'darwin)
  "是否是 macOS。")

(defconst sys/linuxp (eq system-type 'gnu/linux)
  "是否是 Linux。")

(defconst my-custom-example-file (locate-user-emacs-file "custom-example.el")
  "custom.el 的模板，第一次启动时复制成 custom.el。")

(defconst my-custom-post-file (locate-user-emacs-file "custom-post.el")
  "所有模块加载完之后再加载的本机设置。")

(provide 'init-const)

;;; init-const.el ends here
