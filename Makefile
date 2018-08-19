clean:
	@rm -f init.elc README.el README.elc

compile: init.el README.org clean
	@emacs -Q --batch -l 'lisp/compile.el'
