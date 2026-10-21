;;; init-org.el --- 日程、任务、工作记录 -*- lexical-binding: t; -*-

;;; Commentary:
;; 文件（都在 `my-org-directory'）：
;;   inbox.org    所有临时想法、任务先记到这里（C-c c）
;;   tasks.org    整理后的任务和日程，agenda 读 inbox 和 tasks
;;   journal.org  工作记录，按日期自动分层
;;
;; 习惯：想到什么都先 C-c c 记进 inbox，每天或每周用 C-c C-w 整理到 tasks.org。
;;
;; 图片：截图复制后在 org 文件里 C-c y 粘贴，或者把图片文件拖进来，
;; 都复制到 org 文件旁边的 img/ 目录，插入相对路径的链接。

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

(defun my-org-image-file-name ()
  "粘贴图片的文件名（不含扩展名）：文件名-日期-时间，比如 journal-20261021-103512。"
  (concat (if buffer-file-name (file-name-base buffer-file-name) "img")
          (format-time-string "-%Y%m%d-%H%M%S")))

(defun my-org-show-images (beg end)
  "显示 BEG 到 END 之间的图片。"
  (if (fboundp 'org-link-preview-region)            ; Org 9.8（Emacs 31）
      (org-link-preview-region nil t beg end)
    (org-display-inline-images nil t beg end)))

(defun my-org-paste-image ()
  "把剪贴板里的截图存到 img/ 并插入链接，马上显示出来。"
  (interactive)
  (let ((beg (line-beginning-position)))
    (yank-media)
    (my-org-show-images beg (line-end-position))))

(defun my-org-dnd-image (urls action)
  "拖进来的图片复制到 img/，一张一行，重名时加 -1、-2；其他文件交给 Org 处理（会问怎么处理）。"
  (let ((beg (line-beginning-position)))
    (dolist (url urls)
      (let ((file (dnd-get-local-file-name url t)))
        (if (not (and file (string-match-p (image-file-name-regexp) file)))
            (org--dnd-local-file-handler url action)
          (let* ((base (file-name-base file))
                 (ext (file-name-extension file t))
                 (dest (expand-file-name (concat base ext) "img/"))
                 (n 1))
            (while (file-exists-p dest)
              (setq dest (expand-file-name (format "%s-%d%s" base n ext) "img/")
                    n (1+ n)))
            (make-directory "img/" t)
            (copy-file file dest)
            (unless (bolp) (insert "\n"))
            (insert (org-link-make-string (concat "file:" (file-relative-name dest))) "\n")))))
    (my-org-show-images beg (point))
    'copy))
(put 'my-org-dnd-image 'dnd-multiple-handler t)

(defun my-org-dnd-setup ()
  "拖放文件时先用 `my-org-dnd-image'。"
  (setq-local dnd-protocol-alist
              (mapcar (lambda (h)
                        (if (eq (cdr h) 'org--dnd-multi-local-file-handler)
                            (cons (car h) 'my-org-dnd-image)
                          h))
                      dnd-protocol-alist)))

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
         ("C-c o b" . org-switchb)
         :map org-mode-map
         ("C-c y"   . my-org-paste-image))    ; 粘贴截图
  :hook ((org-mode . visual-line-mode)
         (org-mode . my-org-dnd-setup))
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
  ;; 图片：打开时就显示；默认原始大小，但不超过窗口宽度；
  ;; 链接上面一行写 #+attr_org: :width 300 可以单独指定宽度
  (org-startup-with-inline-images t)
  (org-image-actual-width nil)
  (org-image-max-width 'window)
  ;; 粘贴的图片存到当前文件旁边的 img/（相对路径，跟着文件走）
  (org-yank-image-save-method "img/")
  (org-yank-image-file-name-function #'my-org-image-file-name)

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
