;;; init-ai.el --- AI 助手（gptel） -*- lexical-binding: t; -*-

;;; Commentary:
;; gptel：在任意 buffer 里和大模型对话、改写选中的文字。
;; 后端（地址、key、模型）全部由下面的选项决定，代码里不写死；每台机器在 custom.el 里设
;; `my-ai-backends' 和 `my-ai-default'。没设后端时 gptel 照常加载，只是没有可用的后端。
;;
;; 按键（C-c i 前缀）：
;;   C-c i i  打开对话 buffer（org 格式）       C-c i s  发送（光标前的内容或选中的文字）
;;   C-c i m  gptel 菜单：换模型/后端、加系统提示等  C-c i r  改写选中的文字
;;   C-c i a  把选中的文字 / 当前 buffer 加进上下文  C-c i k  中止正在进行的请求

;;; Code:

(require 'cl-lib)
(require 'init-custom)

;; gptel 在 use-package 里按需加载，这里只告诉编译器这些名字
(defvar gptel-backend)
(defvar gptel-model)
(declare-function gptel-backend-models "gptel")

(defgroup my-ai nil
  "AI 助手（gptel）。"
  :group 'my)

(defcustom my-ai-backends nil
  "gptel 后端列表。每项是 (名字 . 参数)，参数是 plist：

  :type      后端类型：openai（默认，所有 OpenAI 兼容接口，包括 llama.cpp、
             vLLM、各种代理）、anthropic、gemini、ollama
  :host      主机名[:端口]，如 \"api.openai.com\"、\"192.168.1.10:8080\"
  :protocol  \"https\"（默认）或 \"http\"
  :endpoint  请求路径，openai 类型默认 \"/v1/chat/completions\"
  :key       API key：字符串、返回字符串的函数；不需要 key 的本地服务不写。
             写成 `gptel-api-key-from-auth-source' 就从 ~/.authinfo(.gpg) 里按 host 读
  :models    可选的模型列表，符号或字符串都行
  :stream    是否流式输出，默认 t

其余参数原样传给对应的 gptel-make-* 函数。例子见 custom-example.el。"
  :type '(alist :key-type string :value-type plist))

(defcustom my-ai-default nil
  "默认用的后端和模型：(后端名 . 模型)。
nil 时用 `my-ai-backends' 第一个后端的第一个模型。"
  :type '(choice (const :tag "第一个后端的第一个模型" nil)
                 (cons (string :tag "后端名") (symbol :tag "模型"))))

(defcustom my-ai-default-mode 'org-mode
  "新开的对话 buffer 用什么模式：org-mode、markdown-mode 或 text-mode。"
  :type '(choice (const org-mode) (const markdown-mode) (const text-mode)))

(defun my-ai--make-backend (name args)
  "按 ARGS（见 `my-ai-backends'）创建名为 NAME 的 gptel 后端。"
  (let* ((type (or (plist-get args :type) 'openai))
         (make (pcase type
                 ('openai #'gptel-make-openai)
                 ('anthropic #'gptel-make-anthropic)
                 ('gemini #'gptel-make-gemini)
                 ('ollama #'gptel-make-ollama)
                 (_ (user-error "my-ai-backends: %s 的 :type %S 不认识" name type))))
         (params (copy-sequence args)))
    (cl-remf params :type)
    (when (plist-member params :models)
      (setq params (plist-put params :models
                              (mapcar (lambda (m) (if (stringp m) (intern m) m))
                                      (plist-get params :models)))))
    (unless (plist-member params :stream)
      (setq params (plist-put params :stream t)))
    (apply make name params)))

(defun my-ai-setup ()
  "按 `my-ai-backends' 创建后端，并按 `my-ai-default' 选默认的后端和模型。
改了 custom.el 里的设置后可以 M-x my-ai-setup 重新加载，不用重启。"
  (interactive)
  (let (backends)
    (dolist (entry my-ai-backends)
      (push (cons (car entry) (my-ai--make-backend (car entry) (cdr entry))) backends))
    (setq backends (nreverse backends))
    (when backends
      (let* ((name (or (car my-ai-default) (caar backends)))
             (backend (or (cdr (assoc name backends))
                          (user-error "my-ai-default：没有叫 %s 的后端" name)))
             (model (or (cdr my-ai-default) (car (gptel-backend-models backend)))))
        (setq gptel-backend backend
              gptel-model (if (stringp model) (intern model) model))
        (when (called-interactively-p 'any)
          (message "gptel：%s / %s" name gptel-model))))))

(use-package gptel
  :commands (gptel gptel-send gptel-menu gptel-rewrite gptel-add gptel-abort)
  :bind (("C-c i i" . gptel)
         ("C-c i s" . gptel-send)
         ("C-c i m" . gptel-menu)
         ("C-c i r" . gptel-rewrite)
         ("C-c i a" . gptel-add)
         ("C-c i k" . gptel-abort))
  :init
  (setq gptel-default-mode my-ai-default-mode)
  :config
  (my-ai-setup))

(provide 'init-ai)

;;; init-ai.el ends here
