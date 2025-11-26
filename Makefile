RSYC_OPT=-avhc
EXCLUDE=--exclude='*/.git' --exclude='*/.git/' --exclude='*.bak'

diff :
	diff -rwa src/ ${HOME}/.vim/      || true

brief :
	diff -rwaq src/ ${HOME}/.vim/     || true

fake :
	rsync --dry-run $(RSYC_OPT) $(EXCLUDE) src/ ${HOME}/.vim/

sync :
	rsync --delete $(RSYC_OPT) --exclude='bundle/' $(EXCLUDE) ${HOME}/.vim/ src/

install :
	rsync --delete $(RSYC_OPT) $(EXCLUDE) src/ ${HOME}/.vim/
