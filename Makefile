# python-gantt Makefile

VERSION=$(shell $(PYTHON) setup.py --version)
ARCHIVE=$(shell $(PYTHON) setup.py --fullname)
PYTHON=python3
PANDOC=/usr/bin/pandoc

install:
	@$(PYTHON) setup.py install

check_version_consistency:
	SETUPVERSION=$(shell python setup.py --version 2> /dev/null)
	PYTHOVERSION=$(shell python -c 'import gantt; print(gantt.__version__)')
ifneq ($(shell python setup.py --version 2> /dev/null), $(shell python -c 'import gantt; print(gantt.__version__)'))
	$(error VERSION INCONSISTENCY between setup.py and gantt/gantt.py)
endif

archive: readme changelog
	@$(PYTHON) setup.py sdist
	@echo Archive is create and named dist/$(ARCHIVE).tar.gz
	@echo -n md5sum is :
	@md5sum dist/$(ARCHIVE).tar.gz

license:
	@$(PYTHON) setup.py --license

readme:
	@$(PANDOC) -f org -t markdown_github org2gantt/README.org -o org2gantt/README.txt
	@$(PANDOC) -f markdown -t rst README.md -o README.txt

changelog:
	@hg shortlog |~/.cabal/bin/pandoc -f org -t plain > CHANGELOG


test:
	nosetests gantt
	export PYTHONPATH=$(shell pwd)/gantt; $(PYTHON) org2gantt/org2gantt.py  org2gantt/example.org -r -g test.py 
	export PYTHONPATH=$(shell pwd)/gantt; $(PYTHON) test.py
	rm test.py

tox:
	tox

toxtest:
	nosetests gantt
	export PYTHONPATH=$(shell pwd)/gantt; $(PYTHON) org2gantt/org2gantt.py  org2gantt/example.org -r -g test.py 
	export PYTHONPATH=$(shell pwd)/gantt; $(PYTHON) test.py
	rm test.py

conformity:
	pyflakes org2gantt/org2gantt.py
	pyflakes gantt/gantt.py
	flake8 org2gantt/org2gantt.py
	flake8 gantt/gantt.py

release: check_version_consistency tox doc changelog

