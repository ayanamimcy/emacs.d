;;; init-package.el --- 包管理 -*- lexical-binding: t; -*-

;;; Commentary:
;; 读入 custom.el，设置软件源和 use-package。
;; 升级所有包：M-x package-upgrade-all

;;; Code:

(require 'init-const)
(require 'init-custom)
(require 'package)

;; 本机设置：没有就从模板复制一份
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (and (not (file-exists-p custom-file))
           (file-exists-p my-custom-example-file))
  (copy-file my-custom-example-file custom-file))
(load custom-file 'noerror 'nomessage)

(setq package-archives
      (or (alist-get my-package-archives my-package-archives-alist)
          (error "未知的软件源：%s" my-package-archives)))

(require 'use-package)
(setq use-package-always-ensure t     ; 没装的包自动安装
      use-package-expand-minimally t
      use-package-enable-imenu-support t)

(provide 'init-package)

;;; init-package.el ends here
