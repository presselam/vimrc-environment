INCLUDE=--include='.vim/***' --include='.templates/***' --include='bin'

BIN_FILES=$(patsubst src/%,%,$(wildcard src/bin/*))
INCLUDE += $(addprefix --include=, $(BIN_FILES))

EXCLUDE=--exclude='*' --exclude='*/.git/' --exclude='*.bak'
RSYC_OPT=-avhc

BUNDLE=$(patsubst src/.vim/bundle/%, %, $(wildcard src/.vim/bundle/*))

diff :
	diff -rwa src/.vim ${HOME}/.vim      || true

brief :
	diff -rwaq src/.vim ${HOME}/.vim      || true

fake :
	rsync --dry-run $(RSYC_OPT) $(EXCLUDE) $(INCLUDE) src/ ${HOME}/

sync :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) ${HOME}/ src/

install :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/

pathogen:
	installBundles.sh

.PHONY: bundles $(BUNDLE)
bundles: $(addprefix bundle-, $(BUNDLE))
	echo $()

bundle-%:
	git submodule update --init --recursive
	git submodule update --remote --merge
	cd src/.vim/bundle/$*; git pull origin master
