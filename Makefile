INCLUDE=--include='.vimrc' --include='.vim/***' --include='.templates/***' --include='bin'

BIN_FILES=$(patsubst src/%,%,$(wildcard src/bin/*))
INCLUDE += $(addprefix --include=, $(BIN_FILES))

EXCLUDE=--exclude='*.bak' --exclude='*'
RSYC_OPT=-avhc

diff :
	diff -rw src/.vimrc ${HOME}/.vimrc  || true
	diff -rw src/.vim ${HOME}/.vim      || true

fake :
	rsync --dry-run $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/

sync :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) ${HOME}/ src/

install :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/
