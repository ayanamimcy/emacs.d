;;; init-calendar.el --- 日历和节假日 -*- lexical-binding: t; -*-

;;; Commentary:
;; M-x calendar 打开日历。节假日要在 agenda 里显示，见 README。
;; 日历里按 p C 查看农历。

;;; Code:

(require 'init-custom)

(use-package calendar
  :ensure nil
  :custom
  (calendar-week-start-day 1)           ; 周一开始
  (calendar-mark-holidays-flag t))

(when my-chinese-calendar
  (use-package cal-china-x
    :after calendar
    :autoload cal-china-x-setup
    :init (cal-china-x-setup)
    :config
    (setq cal-china-x-important-holidays cal-china-x-chinese-holidays
          cal-china-x-general-holidays '((holiday-lunar 1 15 "元宵节")
                                         (holiday-lunar 7 7 "七夕节"))
          calendar-holidays (append cal-china-x-important-holidays
                                    cal-china-x-general-holidays))))

(when my-japanese-holidays
  (use-package japanese-holidays
    :after calendar
    :config
    (setq calendar-holidays (append calendar-holidays japanese-holidays))))

(provide 'init-calendar)

;;; init-calendar.el ends here
