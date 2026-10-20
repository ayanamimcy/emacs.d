;;; init-org.el --- 日程、任务、工作记录 -*- lexical-binding: t; -*-

;;; Commentary:
;; 文件（都在 `my-org-directory'）：
;;   inbox.org    所有临时想法、任务先记到这里（C-c c）
;;   tasks.org    整理后的任务和日程，agenda 读 inbox 和 tasks
;;   journal.org  工作记录，按日期自动分层
;;
;; 习惯：想到什么都先 C-c c 记进 inbox，每天或每周用 C-c C-w 整理到 tasks.org。

;;; Code:

(require 'init-custom)

(defun my-org-file (name)
  "`my-org-directory' 里的文件 NAME。"
  (expand-file-name name my-org-directory))

(defun my-org-today ()
  "今天的视图：日程 + 正在做 + 收件箱。"
  (interactive)
  (org-agenda nil "d"))

(defun my-org-open-inbox ()
  "打开 inbox.org。"
  (interactive)
  (find-file (my-org-file "inbox.org")))

(defun my-org-open-tasks ()
  "打开 tasks.org。"
  (interactive)
  (find-file (my-org-file "tasks.org")))

(defun my-org-search ()
  "在 org 目录里全文搜索。"
  (interactive)
  (consult-ripgrep my-org-directory))

(use-package org
  :ensure nil
  :bind (("C-c a"   . org-agenda)
         ("C-c c"   . org-capture)
         ("C-c l"   . org-store-link)
         ("C-c o d" . my-org-today)
         ("C-c o i" . my-org-open-inbox)
         ("C-c o t" . my-org-open-tasks)
         ("C-c o s" . my-org-search)
         ("C-c o h" . consult-org-agenda)   ; 在所有 agenda 文件的标题里跳转
         ("C-c o b" . org-switchb))
  :hook (org-mode . visual-line-mode)
  :custom
  (org-directory my-org-directory)
  (org-default-notes-file (my-org-file "inbox.org"))
  (org-agenda-files (list (my-org-file "inbox.org") (my-org-file "tasks.org")))
  (org-agenda-skip-unavailable-files t)  ; 文件还没建时不报错

  ;; 任务状态：@ = 切换时写原因，! = 记录时间
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (org-todo-keyword-faces '(("NEXT" . warning) ("WAIT" . shadow)))
  (org-log-done 'time)
  (org-log-into-drawer t)                ; 状态记录收进 :LOGBOOK:

  ;; C-c C-w 把条目移到 agenda 文件的某个标题下
  (org-refile-targets '((org-agenda-files :maxlevel . 2)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  (org-refile-allow-creating-parent-nodes 'confirm)

  ;; 显示
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-ellipsis " ▾")
  (org-pretty-entities t)                  ; \alpha 显示成 α
  ;; 只有 a_{b} / a^{b} 才算上下标，a_b（变量名等）原样显示和导出
  (org-use-sub-superscripts '{})
  (org-export-with-sub-superscripts '{})
  (org-image-actual-width '(600))

  (org-capture-templates
   '(("t" "任务" entry (file "inbox.org")
      "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
     ("n" "随手记" entry (file "inbox.org")
      "* %?\n%U\n")
     ("j" "工作记录" entry (file+olp+datetree "journal.org")
      "* %<%H:%M> %?")
     ("m" "会议" entry (file+olp+datetree "journal.org")
      "* %<%H:%M> 会议：%^{主题}\n%?" :clock-in t :clock-resume t)))

  ;; agenda
  (org-agenda-window-setup 'current-window)
  (org-agenda-restore-windows-after-quit t)
  (org-agenda-custom-commands
   '(("d" "今天"
      ((agenda "" ((org-agenda-span 'day)))
       (todo "NEXT" ((org-agenda-overriding-header "正在做")))
       (tags "LEVEL=1"
             ((org-agenda-files (list (my-org-file "inbox.org")))
              (org-agenda-overriding-header "收件箱（待整理）"))))))))

;; 标题、列表、标签、时间戳等的美化
(use-package org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda)))

;; 隐藏了 *粗体* 等标记，光标移过去时才显示出来
(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom (org-appear-autolinks t))

(provide 'init-org)

;;; init-org.el ends here
