;;; setup-evil.el --- user evil configuration entry point.

;;; Commentary:

;; This file configures the behavior of evil in emacs
;; here is some resources it refers to
;; https://github.com/cofi/dotfiles/blob/master/emacs.d/config/cofi-evil.el

(require 'yangchenyun-util)
(prelude-require-package 'undo-tree)
(prelude-require-package 'evil-leader)
(prelude-require-package 'evil-nerd-commenter)
(prelude-require-package 'evil)
(prelude-require-package 'surround)
(prelude-require-package 'undo-tree)
(prelude-require-package 'evil-numbers)

(setq evil-find-skip-newlines t)
(setq evil-move-cursor-back nil
      evil-cross-lines t)
(setq evil-default-cursor #'cofi/evil-cursor)
(setq evil-mode-line-format nil)
(setq evil-leader/leader ","
      evil-leader/in-all-states t)
(setq evil-search-module 'evil-search)

(global-evil-leader-mode)
(evilnc-default-hotkeys)

(setq evil-normal-state-tag   (propertize "N" 'face '((:background "green" :foreground "black")))
      evil-emacs-state-tag    (propertize "E" 'face '((:background "orange" :foreground "black")))
      evil-insert-state-tag   (propertize "I" 'face '((:background "red")))
      evil-motion-state-tag   (propertize "M" 'face '((:background "blue")))
      evil-visual-state-tag   (propertize "V" 'face '((:background "grey80" :foreground "black")))
      evil-operator-state-tag (propertize "O" 'face '((:background "purple"))))

(require-and-exec 'surround
  (setq-default surround-pairs-alist '((?\( . ("(" . ")"))
                                       (?\[ . ("[" . "]"))
                                       (?\{ . ("{" . "}"))

                                       (?\) . ("( " . " )"))
                                       (?\] . ("[ " . " ]"))
                                       (?\} . ("{ " . " }"))
                                       (?>  . ("< " . " >"))

                                       (?# . ("#{" . "}"))
                                       (?p . ("(" . ")"))
                                       (?b . ("[" . "]"))
                                       (?B . ("{" . "}"))
                                       (?< . ("<" . ">"))
                                       (?t . surround-read-tag)))

  (defun yangchenyun/surround-add-pair (trigger begin-or-fun &optional end)
    "Add a surround pair.
     If `end' is nil `begin-or-fun' will be treated as a fun."
    (push (cons (if (stringp trigger)
                    (string-to-char trigger)
                  trigger)
                (if end
                    (cons begin-or-fun end)
                  begin-or-fun))
          surround-pairs-alist))

  (global-surround-mode 1)
  (add-to-hooks (lambda ()
                  (yangchenyun/surround-add-pair "`" "`"  "'"))
                '(emacs-lisp-mode-hook lisp-mode-hook))
  (add-to-hooks (lambda ()
                  (yangchenyun/surround-add-pair "~" "``"  "``"))
                '(markdown-mode-hook rst-mode-hook python-mode-hook))
  (add-hook 'LaTeX-mode-hook (lambda ()
                               (yangchenyun/surround-add-pair "~" "\\texttt{" "}")
                               (yangchenyun/surround-add-pair "=" "\\verb=" "=")
                               (yangchenyun/surround-add-pair "/" "\\emph{" "}")
                               (yangchenyun/surround-add-pair "*" "\\textbf{" "}")
                               (yangchenyun/surround-add-pair "P" "\\(" "\\)")))
  (add-to-hooks (lambda ()
                  (yangchenyun/surround-add-pair "c" ":class:`" "`")
                  (yangchenyun/surround-add-pair "f" ":func:`" "`")
                  (yangchenyun/surround-add-pair "m" ":meth:`" "`")
                  (yangchenyun/surround-add-pair "a" ":attr:`" "`")
                  (yangchenyun/surround-add-pair "e" ":exc:`" "`"))
                '(rst-mode-hook python-mode-hook)))

(evil-set-toggle-key "<pause>")
(evil-mode 1)

(defun cofi/evil-cursor ()
  "Change cursor color according to evil-state."
  (let ((default "OliveDrab4")
        (cursor-colors '((insert . "dark orange")
                         (emacs  . "sienna")
                         (visual . "white"))))
    (setq cursor-type (if (eq evil-state 'visual)
                          'hollow
                        'bar))
    (set-cursor-color (def-assoc evil-state cursor-colors default))))

(evil-define-command cofi/evil-maybe-exit ()
  :repeat change
  (interactive)
  (let ((modified (buffer-modified-p))
        (entry-key ?j)
        (exit-key ?j))
    (insert entry-key)
    (let ((evt (read-event (format "Insert %c to exit insert state" exit-key) nil 0.5)))
      (cond
       ((null evt) (message ""))
       ((and (integerp evt) (char-equal evt exit-key))
          (delete-char -1)
          (set-buffer-modified-p modified)
          (push 'escape unread-command-events))
       (t (push evt unread-command-events))))))

(cl-loop for (mode . state) in '((inferior-emacs-lisp-mode     . emacs)
                                 (pylookup-mode                . emacs)
                                 (comint-mode                  . emacs)
                                 (ebib-entry-mode              . emacs)
                                 (ebib-index-mode              . emacs)
                                 (ebib-log-mode                . emacs)
                                 (elfeed-show-mode             . emacs)
                                 (elfeed-search-mode           . emacs)
                                 (gtags-select-mode            . emacs)
                                 (shell-mode                   . emacs)
                                 (term-mode                    . emacs)
                                 (bc-menu-mode                 . emacs)
                                 (magit-branch-manager-mode    . emacs)
                                 (semantic-symref-results-mode . emacs)
                                 (rdictcc-buffer-mode          . emacs)
                                 (erc-mode                     . normal))
         do (evil-set-initial-state mode state))

(fill-keymap evil-normal-state-map
             "Y"     (kbd "y$")
             "+"     'evil-numbers/inc-at-pt
             "-"     'evil-numbers/dec-at-pt
             "SPC"   'evil-ace-jump-char-mode
             "C-SPC" 'evil-ace-jump-word-mode
             "go"    'evil-ace-jump-line-mode
             "C-t"   'transpose-chars
             "gH"    'evil-window-top
             "gL"    'evil-window-bottom
             "gM"    'evil-window-middle
             "H"     'beginning-of-line
             "L"     'end-of-line
             "C-u"   'evil-scroll-up
             "C-;"   'eval-expression
             )

(fill-keymap evil-motion-state-map
             "y"     'evil-yank
             "Y"     (kbd "y$")
             "_" 'evil-first-non-blank
             "C-e"   'end-of-line
             "C-S-d" 'evil-scroll-up
             "C-S-f" 'evil-scroll-page-up
             "_"     'evil-first-non-blank
             "C-y"   nil)

(fill-keymap evil-insert-state-map
             "j"   'cofi/evil-maybe-exit
             "C-h" 'backward-delete-char
             "C-k" 'kill-line
             "C-y" 'yank
             "C-e" 'end-of-line)

(fill-keymaps (list evil-operator-state-map
                    evil-visual-state-map)
             "SPC"   'evil-ace-jump-char-mode
             "C-SPC" 'evil-ace-jump-word-mode)

(defun cofi/clear-empty-lines ()
  (let ((line (buffer-substring (point-at-bol) (point-at-eol))))
    (when (string-match "^ +$" line)
      (delete-region (point-at-bol) (point-at-eol)))))

(add-hook 'evil-insert-state-exit-hook #'cofi/clear-empty-lines)

(evil-leader/set-key
  "w" 'save-buffer
  "W" 'save-some-buffers
  "k" 'kill-current-buffer
  "K" 'kill-buffer-and-window
  "f" 'dired-jump

  "m" 'compile

  "s" 'cofi/split-shell
  "S" 'eshell

  "." 'evil-ex)

;;; C-w related window cmds
(require 'cofi-windowing)
;; allow C-w to be shadowed in emacs-state -- `evil-want-C-w-in-emacs-state' doesn't allow this
(global-set-key (kbd "C-w") evil-window-map)
;; alternative if shadowed
(global-set-key (kbd "C-c w") evil-window-map)
;; Windowing
(fill-keymap evil-window-map
    "C-h" nil
    "d" 'cofi/window-toggle-dedicate
    ;; Splitting
    "s" 'cofi/smart-split
    "\\" 'split-window-vertically
    "|" 'split-window-horizontally
    "/" 'cofi/multi-split

    ;; Deleting
    "D"   'delete-window
    "C-d" 'delete-window
    "1"   'delete-other-windows

    ;; Sizing
    "RET" 'enlarge-window
    "-"   'shrink-window-horizontally
    "="   'enlarge-window-horizontally

    ;; Moving
    "<left>"  'evil-window-left
    "<down>"  'evil-window-down
    "<up>"    'evil-window-up
    "<right>" 'evil-window-right

    ;; Swapping
    "M-h"       'swap-with-left
    "M-j"       'swap-with-down
    "M-k"       'swap-with-up
    "M-l"       'swap-with-right
    "S-<left>"  'swap-with-left
    "S-<down>"  'swap-with-down
    "S-<up>"    'swap-with-up
    "S-<right>" 'swap-with-right
    "SPC"       'swap-window

    "g" 'cofi/goto-window

    ;; winner-mode
    "u" 'winner-undo
    "C-r" 'winner-redo
    ;; shadow rotating in evil-window-map
    "C-R" 'winner-redo)

(provide 'setup-evil)
;;; setup-evil.el ends here