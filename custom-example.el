;;; custom.el --- 本机设置 -*- lexical-binding: t; no-byte-compile: t -*-

;;; Commentary:
;; 第一次启动时从 custom-example.el 复制而来，不进 git，每台机器各改各的。
;; 改完重启 Emacs。要在所有模块加载完之后覆盖某些设置，写到 custom-post.el。
;; M-x customize 保存的设置也会追加到这个文件末尾。

;;; Code:

;; (setq my-org-directory "~/org/")              ; org 文件目录
;; (setq my-package-archives 'melpa)             ; 软件源：melpa、tuna、ustc
;; (setq my-font "Sarasa Mono SC")               ; 字体（中英文 2:1 的等宽字体）
;; (setq my-font-size 150)                       ; 字号，1/10 pt（默认 Mac 150，其他 110）
;; (setq my-theme 'system)                       ; system（跟随 macOS）、light、dark 或主题名
;; (setq my-theme-light 'doom-one-light)
;; (setq my-theme-dark 'doom-one)
;; (setq my-completion-style 'minibuffer)        ; 补全列表在底部显示（默认 childframe：窗口中间浮动）
;; (setq my-icon nil)                            ; 不显示图标
;; (setq my-chinese-calendar nil)                ; 不显示农历和中国节日
;; (setq my-japanese-holidays nil)               ; 不显示日本节假日
;; (setq my-use-exec-path-from-shell nil)        ; Mac 上不从 shell 读取 PATH

;; 启动时最大化
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))

;;; custom.el ends here
