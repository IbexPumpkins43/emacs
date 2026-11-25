;; early-init.el -*- lexical-binding: t; -*-

;; Pauses the garbage collector while the config loads, then reset it back to default
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

;; No menu bar, tool bar or scroll bars
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

;; Set the font to Jetbrains Mono NL, Regular, 11pt
(push '(font . "JetBrains Mono NL-11:weight=regular") default-frame-alist)

(provide 'early-init)
;; early-init.el ends here