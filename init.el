;; .emacs.d/init.el


;; ===================================
;; MELPA Package Support
;; ===================================

;; Add custom directory to load path
;; (add-to-list 'load-path "custom load path")

;; Enables basic packaging support

(require 'package)

;; Adds the Melpa archive to the list of available repositories
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)


;; Initializes the package infrastructure
(package-initialize)


;; If there are no archived package contents, refresh them
(when (not package-archive-contents)
  (package-refresh-contents))

(set-fringe-mode 15)

;; Installs packages
;;
;; myPackages contains a list of package names

(defvar myPackages
  '(better-defaults                 ;; Set up some better Emacs defaults
    material-theme                  ;; Theme
    flycheck                        ;; On the fly syntax checking
    )
  )

;; Scans the list in myPackages
;; If the package listed is not already installed, install it
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

;; ============================================================================
;; Basic Customization
;; ============================================================================

(load-theme 'material t)            ;; Load material theme
(global-linum-mode t)               ;; Enable line numbers globally
;; Turn on column number mode
(column-number-mode t)

;; Copy line
(defun copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring"
  (interactive "p")
  (kill-ring-save (line-beginning-position)
		  (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))
;; optional key binding
(global-set-key "\C-c\C-l" 'copy-line)

(require 'flyspell)
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'org-mode-hook 'flyspell-mode)

;; Display full path to visited file in frame title
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

;; ============================================================================
;; Org mode Setup
;; ============================================================================
(require 'org)

(add-hook 'org-mode-hook '(lambda () (setq fill-column 80)))
(add-hook 'org-mode-hook 'turn-on-auto-fill)
;; auto new line
;; Increases size of LaTeX fragment previews
(plist-put org-format-latex-options :scale 2)
;;;
;;; ox-hugo settings
;;;
(with-eval-after-load 'ox
  (require 'ox-hugo))

;;;
;;; org-mode settings
;;;
;; Functions to create source, verse, quote and center blocks
(defun add-src-elements (src-lang)
  "
   Make adding #+BEGIN/END _SRC elements easier.
    C-c ' to edit source in a separate frame
  "
  (interactive "sEnter source language:")
  (save-excursion
    (insert (format "#+BEGIN_SRC %s\n" src-lang))
    (newline-and-indent)
    (insert "#+END_SRC\n"))
  (forward-line 1))
    
(defun add-verse-elements ()
  "Make adding #+BEGIN/END _VERSE elements easier"
  (interactive)
  (save-excursion
    (insert "#+BEGIN_VERSE\n\n#+END_VERSE"))
  (forward-line 1))

(defun add-quote-elements ()
  "Make adding #+BEGIN/END _QUOTE elements easier"
  (interactive)
  (save-excursion
    (insert "#+BEGIN_QUOTE\n\n#+END_QUOTE"))
  (forward-line 1))

(defun add-center-elements ()
  "Make adding #+BEGIN/END _CENTER elements easier"
  (interactive)
  (save-excursion
    (insert "#+BEGIN_CENTER\n\n#+END_CENTER"))
  (forward-line 1))

;; set it to keybindings
(with-eval-after-load 'org
  (add-hook 'org-mode-hook
	    (lambda ()
	      (local-set-key (kbd "C-c s") 'add-src-elements))))

(with-eval-after-load 'org
  (add-hook 'org-mode-hook
	    (lambda ()
	      (local-set-key (kbd "C-c v") 'add-verse-elements))))

(with-eval-after-load 'org
  (add-hook 'org-mode-hook
	    (lambda ()
	      (local-set-key (kbd "C-c q") 'add-quote-elements))))

(with-eval-after-load 'org
  (add-hook 'org-mode-hook
	    (lambda ()
	      (local-set-key (kbd "C-c c") 'add-center-elements))))

;; enable gnuplot in org-mode
;; active Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((gnuplot . t)))
;; add additional languages with '((language . t)))

;; Org bullets
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; ============================================================================
;; Development Setup
;; ============================================================================

;; javascript indent level - mainly for json files
(setq js-indent-level 4)

;; Highlight current line
(global-hl-line-mode +1)

;; See matching parens
(show-paren-mode 1)
;; highlight brackets
(setq show-paren-style 'mixed)
;; where to find abbrev defs
(setq abbrev-file-name "~/.emacs.d/abbrev_defs")

;; Set auto save timer
(setq auto-save-timeout 5)

(require 'fill-column-indicator)
(setq fci-rule-width 1)
(setq fci-rule-column 79)
(setq fci-rule-color "lightblue")
(add-hook 'after-change-major-mode-hook 'fci-mode)

(require 'ido)
(ido-mode t)

;; Insert template files based on mode
(auto-insert-mode)

;; enable code folding minor mode
(add-to-list 'load-path "~/.emacs.d/myplugins")
;; (load "hideshowvis.el")
;; (require 'myplugin)

(autoload 'hideshowvis-enable "hideshowvis" "Highlight foldable regions")
(autoload 'hideshowvis-minor-mode
  "hideshowvis"
  "Will indicate regions foldable with hideshow in the fringe."
  'interactive)
(with-eval-after-load 'hideshowvis (hideshowvis-symbols))
(dolist (hook (list 'emacs-lisp-mode-hook
		    'c++-mode-hook
		    'elpy-mode-hook
		    'js-mode-hook))
  (add-hook hook 'hideshowvis-enable))

;; If enabling hideshowvis-minor-mode is slow on your machine use M-x,
;; customize-option, hideshowvis-ignore-same-line and set it to nil. This will
;; then display - icons for foldable regions of one line, too but is faster
;;
;; To enable displaying a + symbol in the fringe for folded regions,
;; use:
;; (autoload 'hideshowvis-symbols)

;; (add-hook 'js-mode-hook 'hs-minor-mode)
;; (add-hook 'elpy-mode-hook 'hs-minor-mode)
(eval-after-load 'hideshow
  '(progn
     (global-set-key (kbd "C-+") 'hs-toggle-hiding)))

;; ============================================================================
;; LSP Setup
;; ============================================================================
(use-package lsp-mode
  :commands
  (lsp lsp-deferred)
  :hook ((python-mode go-mode) . lsp-deferred)
  ((python-mode) .  #'my/add-simple-pydocstring-binding)
  ((python-mode go-mode) . #'hideshowvis-enable)
  ((prog-mode) . highlight-indent-guides-mode)
  
  :demand t
  :init
  (setq lsp-keymap-prefix "C-c l")
  ;; TODO: https://emacs-lsp.github.io/lsp-mode/page/performance/
  ;; also note re "native compilation": <+varemara> it's the
  ;; difference between lsp-mode being usable or not, for me
  :config
  (setq lsp-auto-configure t)
  (setq lsp-prefer-flymake nil)
  (setq lsp-enable-which-key-integration t)
  (setq highlight-indent-guides-method 'character)
  :bind (:map lsp-mode-map
	      ("C-." .  lsp-describe-thing-at-point)
	      ("C-c c" . comment-region)
	      ("C-c u" . uncomment-region)))

(remove-hook 'before-save-hook 'gofmt-before-save)
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(use-package company
  :after lsp-mode
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))
 
;; This gets around a bug on this machine. The tooltip window was tiny.
;; These settings have to come after company setup.
(setq company-tooltip-minimum-width 70)
(setq company-tooltip-maximum-width 70)

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config   (setq lsp-ui-flycheck-enable t)
  (add-to-list 'lsp-ui-doc-frame-parameters '(no-accept-focus . t))
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  (setq lsp-ui-doc-position 'bottom)
  (lsp-ui-sideline))

;; ============================================================================
;; Python setup
;; ============================================================================
;; trailing slash IMPORTANT
(setq auto-insert-directory "~/.emacs.d/templates/")
(define-auto-insert "\.py" "python-template.py")
;; don't prompt before template insertion
(setq auto-insert-query nil)

;; insert python docstring
(defun my/insert-pydocstring ()
  (interactive)
  (save-excursion
    (insert "\"\"\"
This is an example of Google style.

Args:
    param1: This is the first param.
    param2: This is a second param.

Returns:
    This is a description of what is returned.

Raises:
    KeyError: Raises an exception.
\"\"\"")
    ))

(defun my/add-pydocstring-binding ()
   (local-set-key (kbd "<M-f12>") #'my/insert-pydocstring))

;; insert simple python docstring
(defun my/insert-simple-pydocstring ()
  (interactive)
  (save-excursion
    (insert "    \"\"\"
    Docstring
    \"\"\"\n")
    ))

(defun my/add-simple-pydocstring-binding ()
   (local-set-key (kbd "<M-f11>") #'my/insert-simple-pydocstring))

(add-hook 'elpy-mode-hook #'my/add-pydocstring-binding)
(add-hook 'elpy-mode-hook #'my/add-simple-pydocstring-binding)

;;; ===========================================================================
;;; General settings
;;; ===========================================================================

;; create a new random scratch buffer
(defun new-scratch-buffer ()
  "Creates and switches to a new scratch buffer"
  (interactive)
  (switch-to-buffer (concat "*scratch " (current-time-string) "*")))

;; ============================================================================
;; ********** User-Defined init.el ends here **********************************
;; ============================================================================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(company-box-tooltip-minimum-width 260)
 '(highlight-indent-guides-auto-character-face-perc 20)
 '(lsp-ui-doc-alignment (quote window))
 '(lsp-ui-doc-header t)
 '(lsp-ui-doc-max-height 15)
 '(lsp-ui-doc-max-width 120)
 '(lsp-ui-doc-position (quote bottom))
 '(lsp-ui-doc-show-with-cursor nil)
 '(lsp-ui-doc-use-webkit t)
 '(lsp-ui-sideline-diagnostic-max-lines 3)
 '(lsp-ui-sideline-show-code-actions t)
 '(lsp-ui-sideline-show-hover nil)
 '(lsp-ui-sideline-update-mode (quote line))
 '(package-selected-packages
   (quote
    (highlight-indent-guides magit org-bullets ox-reveal go-mode company-box helm-xref helm lsp-ui lsp-mode xref eldoc company gnuplot-mode gnuplot ox-hugo json-mode python-black elpy material-theme better-defaults)))
 '(show-paren-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'narrow-to-region 'disabled nil)
