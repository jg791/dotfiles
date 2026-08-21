;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; .emacs - Jeff Griffin (jeffgriffin0@fastmail.com)
;;;;
;;;; My current setup on macOS (assumes packages are installed via Homebrew)
;;;;
;;;; Has special plugins to work with: Common Lisp, OCaml and Markdown
;;;;
;;;;  Prereqs:
;;;;  - $ brew install sbcl # Steel Bank Common Lisp
;;;;  - $ brew install pandoc # Pandoc (for Markdown/HTML conversion)
;;;;  - $ brew install ispell # for spell checking
;;;;  - $ touch ~/.emacs.custom.el
;;;;  - Install the JetBrains Mono Font (https://www.jetbrains.com/lp/mono/)
;;;;
;;;;  This config should work the first time you open Emacs
;;;;
;;;;  On the first run, you will be prompted to "trust" the theme.
;;;;  Select 'y' on both prompts.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; Base Editor Settings

;; don't dump custom-set-variables stuff into our .emacs file - store it separately
(setq custom-file "~/.emacs.custom.el") ; note: you may need to touch this file if it does not exist
(load custom-file)

;;;; Package setup
(require 'package)

;; set our package sources to use MELPA's repo - https://melpa.org/
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; don't show package compilation warnings/errors in third party packages
(setq native-comp-async-report-warnings-errors 'silent)

;; initialize packages
(package-initialize)

;; refresh package archives
(unless package-archive-contents
  (package-refresh-contents))

;; make sure use-package is install, then require it
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; check package installations at every startup
(setq use-package-always-ensure t)

;; add our mandatory packages

; add a Sublime/neovim/VS Code/etc. style sidebar for file navigation
(use-package dired-sidebar
  :bind (("C-x C-n" . dired-sidebar-toggle-sidebar)) ; toggle sidebar with C-x C-n
  :ensure t
  :commands (dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)
  (setq dired-sidebar-subtree-line-prefix "__")
  (setq dired-sidebar-theme 'icons)
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-custom-font t)
  ; macOS does not support the --dired option for ls, so disable it
  (when (string= system-type "darwin")       
    (setq dired-use-ls-dired nil)))

(use-package monokai-pro-theme) ; custom theme
(use-package highlight-indent-guides) ; minor mode for showing indent levels - see L110
(use-package all-the-icons-dired) ; adds icon set for dired-sidebar
(use-package dired-subtree) ; adds intuitive tree-like behavior for dired-sidebar
(use-package slime) ; Superior Lisp Interaction Mode for Emacs (Common Lisp)
(use-package neocaml) ; modern OCaml mode, replaces tuareg-mode
(use-package git-modes) ; syntax highlight git files such as .gitignore, .gitconfig, etc.
(use-package markdown-mode) ; interactive mode for working with .md (Markdown) files
(use-package rainbow-delimiters) ; highlight and colorize delimiters based on depth - see L117

;;;; UI

;; turn off unnecessary Emacs splash screen
(setq inhibit-startup-screen t)

;; remove ugly GUI toolbar
(tool-bar-mode -1)

;; load theme
(load-theme 'monokai-pro-ristretto)

;; load font
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-12"))

;; set linespacing
(add-to-list 'default-frame-alist '(line-spacing . 0.2))

;; display line numbers on lefthand side of the screen
(global-display-line-numbers-mode)

;; display column number (in addition to existing line number) on the modeline
(setq column-number-mode 1)

;; start column number from 1 instead of 0, to make it consistent
(setq column-number-indicator-zero-based nil)

;; Configure highlight-indent-guides minor mode, for showing indentation levels visually
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode) ; add to all programming modes
(setq highlight-indent-guides-method 'bitmap) ; use dots, similar to Sublime
(setq highlight-indent-guides-auto-character-face-perc 100) ; 100% luminosity
(setq highlight-indent-guides-responsive 'top) ; light up the current highlighted block's indent guide brighter than the rest
(setq highlight-indent-guides-delay 0) ; update guides instantly - remove default "delay"

;; Configure rainbow-delimiters, for coloring delimiters based on depth
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode) ; add to all programming modes

;;;; Editor Behavior

;; automatically update a buffer when the file on disk changes
(global-auto-revert-mode t)
(setq auto-revert-use-notify nil)

;;;; Language/Tool Specific Setup

;; set SBCL for Common Lisp/SLIME usage
(when (string= system-type "darwin") ; use Homebrew on macOS
  (setq inferior-lisp-program "/opt/homebrew/bin/sbcl"))

;; set Markdown processor
(when (string= system-type "darwin") ; use Homebrew on macOS
  (setq markdown-command "/opt/homebrew/bin/pandoc"))

;; set spellechecker
(when (string= system-type "darwin") ; use Homebrew on macOS
  (setq ispell-program-name "/opt/homebrew/bin/ispell"))
