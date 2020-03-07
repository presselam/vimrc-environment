
diff :
	diff -rw src/.vimrc ${HOME}/.vimrc  || true
	diff -rw src/.vim ${HOME}/.vim      || true

fake :
	rsync --dry-run -avhc src/ ${HOME}

install :
	rsync -avhc src/ ${HOME}
