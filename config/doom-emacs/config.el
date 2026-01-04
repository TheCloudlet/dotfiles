;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General User Information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq user-full-name "Cloudlet"
      user-mail-address "yipingp@outlook.com")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Environment Detection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq work-computer-p (string= (or (getenv "MYCOMPUTER") "") "WORK"))

(if work-computer-p
    (message "Running on WORK computer, using minimal setup")
  (message "Running on HOME computer, using full setup"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance Tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Use gcmh package (Garbage Collector Magic Hack) - already included in Doom
;; Use gcmh package (Garbage Collector Magic Hack)
(after! gcmh
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 1024 1024 1024)  ;; 1GB when idle
        gcmh-low-cons-threshold (* 16 1024 1024)))  ;; 16MB when in use

;; Faster file operations
(setq process-adaptive-read-buffering nil)
(setq fast-but-imprecise-scrolling t)
(setq auto-window-vscroll nil)
(setq inhibit-compacting-font-caches t)
(setq frame-inhibit-implied-resize t)
(setq auto-mode-case-fold nil)

;; Reduce I/O operations
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq auto-save-default nil)

;; Performance improvements for large files & syntax checking
(global-so-long-mode 1)  ;; Avoid performance issues in large files
(setq flycheck-check-syntax-automatically '(save))
(setq vc-handled-backends '(Git)) ;; Only enable Git backend for version control
(setq find-file-visit-truename nil) ;; Don't resolve symlinks

;; Improve LSP performance
(setq read-process-output-max (* 4 1024 1024)) ;; 4MB buffer size for process data
(setq lsp-log-io nil) ;; Avoid performance hits from excessive logging

;; Optimize LSP performance further
;; Optimize LSP performance further
(setq lsp-use-plists t)
(after! lsp-mode
  (setq lsp-idle-delay 0.5)
  (setq lsp-response-timeout 5)
  (setq lsp-enable-file-watchers nil)
  (setq lsp-signature-auto-activate nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-sideline-enable nil)
  ;; Disable expensive features
  (setq lsp-lens-enable nil)
  (setq lsp-enable-symbol-highlighting nil)
  (setq lsp-semantic-tokens-enable nil))

;; Evil mode performance
(after! evil-escape
  (setq evil-escape-key-sequence nil)) ;; Disable escape sequence detection
(setq evil-esc-delay 0.001) ;; Reduce delay for ESC in terminal

;; Company mode optimization
;; Company mode optimization
(after! company
  (setq company-idle-delay 0.5)  ;; Increase delay to reduce overhead
  (setq company-minimum-prefix-length 2)
  (setq company-selection-wrap-around t)
  (setq company-tooltip-limit 10)
  (setq company-tooltip-minimum-width 15))

;; Flyspell optimization
(after! flyspell
  (setq flyspell-issue-message-flag nil) ;; Don't show messages for every word
  (add-hook 'prog-mode-hook (lambda () (flyspell-mode -1)))  ;; Disable in coding modes
  (add-hook 'text-mode-hook 'flyspell-mode))  ;; Enable in text-related modes only


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI & Appearance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq doom-theme 'gruber-darker)

;; Font priority: Intel One Mono (variants) > JetBrains Mono
(setq doom-font (cond
                 ((find-font (font-spec :family "Intel One Mono"))
                  (font-spec :family "Intel One Mono" :size 15))
                 ((find-font (font-spec :family "IntelOne Mono"))
                  (font-spec :family "IntelOne Mono" :size 15))
                 (t
                  (font-spec :family "JetBrains Mono" :size 15))))

;; Window size on startup
(setq default-frame-alist '((width . 100) (height . 40)))

;; Line numbers
(setq display-line-numbers-type 'absolute)
(global-display-line-numbers-mode)

;; Highlight column 80 - only in programming modes
(setq-default display-fill-column-indicator-column 80)
(remove-hook 'doom-first-buffer-hook #'global-display-fill-column-indicator-mode)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Reduce display overhead
(setq idle-update-delay 1.0)
(setq redisplay-skip-fontification-on-input t)

;; Enable soft word wrap in text modes
(add-hook 'text-mode-hook #'visual-line-mode)

;; Remove GUI elements for minimal work setup
(when work-computer-p
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-mode Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar notes-home (getenv "NOTES_HOME"))

;; Handle missing NOTES_HOME
(unless notes-home
  (error "NOTES_HOME environment variable is not set"))

(setq org-directory notes-home)

(after! org
  (setq org-log-done 'time) ; Log task completion times
  (setq org-log-into-drawer t)) ; Store logs in a dedicated drawer

(unless work-computer-p
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((haskell . t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Development: LSP & Clangd Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar clangd-binary (getenv "MY_CLANGD"))

(if clangd-binary
    (progn
      (setq lsp-clients-clangd-executable clangd-binary)
      (message "Custom Clangd path is set to %s" clangd-binary))
  (message "Using default Clangd path"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copilot Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package! copilot
  :commands copilot-mode
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keybindings & Miscellaneous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default tab-width 4)
