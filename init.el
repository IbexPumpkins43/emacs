;; init.el -*- lexical-binding: t; -*-

;; Index:
;;   1. Packages
;;   2. Interface
;;   3. Indentation and formatting
;;   4. Note taking, Org mode, Denote
;;   5. Housekeeping

;; =================================================================================================
;; 1. Packages
;; =================================================================================================

(require 'package)

(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; =================================================================================================
;; 2. Interface
;; =================================================================================================

(use-package ef-themes
  :ensure t
  :config
  (modus-themes-load-theme 'ef-dark))

(use-package doom-themes :ensure t :defer t)
(use-package base16-themes :ensure t :defer t)

;; Quiet startup
(setq inhibit-startup-echo-area-message "a")
(setq ;; No welcome screen
      inhibit-startup-screen t
      ;; Empty scratch buffer
      initial-scratch-message nil
      ;; No beeping
      ring-bell-function #'ignore
      ;; No popups
      use-dialog-box nil
      use-file-dialog nil)

;; No popups
(tooltip-mode -1)
;; No blinking cursor
(blink-cursor-mode -1)

;; Line numbers
(setq display-line-numbers-width-start t)
(global-display-line-numbers-mode 1)
;; Highlight the current line
(global-hl-line-mode 1)

;; Column guide line at column 100
(setq-default display-fill-column-indicator-column 100)
;; Show the column in the mode line
(column-number-mode 1)

;; Coloured Windows 11 title bar
(load (expand-file-name "lisp/my-coloured-win32-titlebar" user-emacs-directory))

;; Show list of the next keys after a prefix
(which-key-mode 1)
;; Filter as-you-type lists in the minibuffer
(fido-vertical-moded 1)
;; Use y/n for questions
(setq use-short-answers t)

;; =================================================================================================
;; 3. Indentation and formatting
;; =================================================================================================

;; 4 spaces, never tabs
(setq-default indent-tabs-mode nil
              tab-width 4
              standard-indent 4)

;; Ensure that C, C++, C#, Shell and Python all follow the same rules
(setq-default c-basic-offset 4
              sh-basic-offset 4
              python-indent-offset 4)
;; Always 4, never guess
(setq python-indent-guess-indent-offset nil)
(setq c-default-style "k&r")

;; Disable automatic formatting
(electric-indent-mode -1)
(electric-pair-mode -1)
(electric-quote-mode -1)

;; Ensure that automatic formatting is disabled in C-like modes
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (c-toggle-electric-state -1)
            (c-toggle-auto-newline -1)))

;; Ensure that typing << doesn't insert a here-document template
(add-hook 'sh-mode-hook (lambda () (sh-electric-here-document-mode -1)))

(defun my-newline-autoindent ()
  "Start a new line indentned like the line it is comming from. Spaces at the end of the line that
  the cursor is comming from are removed, so that there is no trailing whitespace left."
  (interactive "*")
  (let ((indent (current-indentation)))
    (delete-horizonal-space)
    (newline)
    (indent-to indent)))

;; Ensure that the Emacs uses my autoindent function
(global-set-key (kbd "RET") #'my-newline-autoindent)
(global-set-key [remap newline] #'my-newline-autoindent)
(global-set-key [remap newline-and-indent] #'my-newline-autoindent)

;; RET should replace text that is selected like normal Enter
(delete-selection-mode 1)
(put 'my-newline-autoindent 'delete-selection t)

;; Don't add a final new line when saving
(setq require-final-newline nil
      mode-require-file-newline nil)

;; =================================================================================================
;; 4. Note taking, Org mode, Denote
;; -================================================================================================

(defvar my-note-directory "C:/Users/a/Documents/Org/")
(setq org-directory my-notes-directory)

;; Org buffers with soft wrap, no line numbers and centred text
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'org-mode-hook #'visual-line-mode)

(use-package olivetti
  :ensure t
  :hook (org-mode . olivetti-mode)
  :custom (olivetti-body-width 100))

(use-package org-modern
  :ensure t
  :config (global-org-modern-mode 1))

;; Denote
(use-package denote
  :enusre t
  :bind (("C-c n n" . denote)
         ("C-c n f" . denote-open-or-create)
         ("C-c n l" . denote-link)
         ("C-c n b" . denote-backlinks)
         ("C-c n s" . my-notes-search))
  :config
  (setq denote-directory my-notes-directory
        denote-file-type 'org))

(defun my-note-search (regexp)
  "Function to search the contents of every single note in my notes directory"
  (interactive (list (read-string "Search notes for: ")))
  (rgrep regexp "*.org" my-notes-directory))

;; Allows me to create notes from anywhere in emacs
;;   C-c c n - Denote asks for a title and keywords, then opens a small window to write in.
;;   C-c C-c - Finishes and opens the note
;;   C-c C-k - Cancels C-c C-c
(global-set-key (kbd "C-c c") #'org-capture)
(with-eval-after-load 'org-capture
  (add-to-list 'org-caputre-templates
               '("n" "New note (Denote)" plain
                 (file denote-last-path)
                 #'denote-org-caputre
                 :no-save t
                 :immediate-finish nil
                 :kill-buffer t
                 :jump-to-captured t)))

;; =================================================================================================
;; 5. Housekeeping
;; =================================================================================================

;; No lock files or backup files
(setq create-lockfiles nil
      make-backup-files nil
      backup-inhibited t)

;; Keep all auto-save files in .emacs.d/auto-saves
(let ((dir (expand-file-name "auto-saves/" user-emacs-directory)))
  (make-directory dir t)
  (setq auto-save-file-name-transforms `((".*" ,dir t))
        auto-save-list-file-prefix (concat dir ".saves-")))

;; Reload files that have changed on disk as long as there are no unsaved edits
(global-auto-revert-mode 1)

;; Remember Emacs state
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)

;; No *Warnings * pop-ups while packages compile in the background
(setq native-comp-async-report-warnings-errors 'silent)

;; Settings saved via M-x customize go to custom.el, to keep this file clean
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

(provide 'init)
;; init.el ends here