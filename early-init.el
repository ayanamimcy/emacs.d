;;; early-init.el --- 启动早期设置 -*- lexical-binding: t; no-byte-compile: t -*-

;;; Commentary:
;; 在包系统和图形界面初始化之前加载。

;;; Code:

;; 启动期间暂停 GC，启动完由 gcmh 接管（见 init-base.el）
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

;; 有 .el 比 .elc 新时加载 .el
(setq load-prefer-newer noninteractive)

;; 界面：不要工具栏和滚动条；Mac 的菜单栏在屏幕顶部，保留
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq tool-bar-mode nil
      scroll-bar-mode nil)
(unless (eq system-type 'darwin)
  (push '(menu-bar-lines . 0) default-frame-alist)
  (setq menu-bar-mode nil))
(when (eq system-type 'darwin)
  (push '(ns-transparent-titlebar . t) default-frame-alist))

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil
      frame-inhibit-implied-resize t
      frame-resize-pixelwise t)

;;; early-init.el ends here
