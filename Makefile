INCLUDE=--include='.vim/***' --include='.templates/***' --include='bin'

BIN_FILES=$(patsubst src/%,%,$(wildcard src/bin/*))
INCLUDE += $(addprefix --include=, $(BIN_FILES))

EXCLUDE=--exclude='*' --exclude='*/.git/' --exclude='*.bak'
RSYC_OPT=-avhc

diff :
	diff -rw src/.vim ${HOME}/.vim      || true

fake :
	rsync --dry-run $(RSYC_OPT) $(EXCLUDE) $(INCLUDE) src/ ${HOME}/

sync :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) ${HOME}/ src/

install :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/

pathogen:
	installBundles.sh
