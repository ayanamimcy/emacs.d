;;; init-custom.el --- 可在 custom.el 里修改的选项 -*- lexical-binding: t; -*-

;;; Commentary:
;; 每台机器可能不同的设置都定义成选项，在 custom.el 里用 setq 修改，
;; 模块代码里不写死。

;;; Code:

(require 'init-const)

(defgroup my nil
  "个人配置。"
  :group 'convenience)

(defcustom my-org-directory (expand-file-name "~/org/")
  "org 文件目录（日程、任务、工作记录）。"
  :type 'directory)

(defcustom my-package-archives-alist
  '((melpa . (("gnu"    . "https://elpa.gnu.org/packages/")
              ("nongnu" . "https://elpa.nongnu.org/nongnu/")
              ("melpa"  . "https://melpa.org/packages/")))
    (tuna  . (("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
              ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
              ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
    (ustc  . (("gnu"    . "https://mirrors.ustc.edu.cn/elpa/gnu/")
              ("nongnu" . "https://mirrors.ustc.edu.cn/elpa/nongnu/")
              ("melpa"  . "https://mirrors.ustc.edu.cn/elpa/melpa/"))))
  "可选的软件源。"
  :type '(alist :key-type symbol :value-type (alist :key-type string :value-type string)))

(defcustom my-package-archives 'melpa
  "使用 `my-package-archives-alist' 里的哪一组软件源。"
  :type 'symbol)

(defcustom my-font "Sarasa Mono SC"
  "默认字体。中英文宽度 2:1 的等宽字体，org 表格才能对齐。"
  :type 'string)

(defcustom my-font-size (if sys/macp 150 110)
  "默认字号，单位 1/10 pt。"
  :type 'integer)

(defcustom my-theme 'dark
  "主题：dark（默认）、light、system 跟随 macOS 亮/暗（其他系统用亮色），或者具体的主题名。"
  :type '(choice (const system) (const light) (const dark) symbol))

(defcustom my-theme-light 'doom-one-light
  "亮色主题。"
  :type 'symbol)

(defcustom my-theme-dark 'doom-one
  "暗色主题。"
  :type 'symbol)

(defcustom my-completion-style 'childframe
  "补全列表、按键提示的显示方式：childframe（窗口中间的浮动窗口）或 minibuffer（底部）。
终端里用不了浮动窗口，会自动退回底部显示。"
  :type '(choice (const childframe) (const minibuffer)))

(defcustom my-icon t
  "是否显示图标（需要 Symbols Nerd Font）。"
  :type 'boolean)

(defcustom my-chinese-calendar t
  "日历里显示农历和中国节日。"
  :type 'boolean)

(defcustom my-japanese-holidays t
  "日历里显示日本节假日。"
  :type 'boolean)

(defcustom my-use-exec-path-from-shell sys/macp
  "从登录 shell 读取 PATH（Mac 上从 Dock 启动的 Emacs 拿不到 shell 的 PATH）。"
  :type 'boolean)

(provide 'init-custom)

;;; init-custom.el ends here
