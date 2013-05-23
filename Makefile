# convenience makefile to boostrap & run buildout
# use `make options=-v` to run buildout with extra options

version = 2.7
python = bin/python
options =

all: docs tests

coverage: htmlcov/index.html

htmlcov/index.html: src/tribuna/buildout/*.py bin/coverage
	@bin/coverage run --source=./src/tribuna/buildout/ --branch bin/test
	@bin/coverage html -i
	@touch $@
	@echo "Coverage report was generated at '$@'."

docs: docs/html/index.html

docs/html/index.html: docs/*.rst src/tribuna/buildout/*.py src/tribuna/buildout/browser/*.py src/tribuna/buildout/tests/*.py bin/sphinx-build
	bin/sphinx-build docs docs/html
	@touch $@
	@echo "Documentation was generated at '$@'."

bin/sphinx-build: .installed.cfg
	@touch $@

.installed.cfg: bin/buildout buildout.cfg buildout.d/*.cfg setup.py
	bin/buildout $(options)

bin/buildout: $(python) buildout.cfg bootstrap.py
	$(python) bootstrap.py -d
	@touch $@

$(python):
	virtualenv -p python$(version) --no-site-packages .
	@touch $@

tests: .installed.cfg
	@bin/test
	@bin/flake8 setup.py
	@bin/flake8 src/tribuna/buildout
	@for pt in `find src/tribuna/buildout -name "*.pt"` ; do bin/zptlint $$pt; done
	@for xml in `find src/tribuna/buildout -name "*.xml"` ; do bin/zptlint $$xml; done
	@for zcml in `find src/tribuna/buildout -name "*.zcml"` ; do bin/zptlint $$zcml; done

clean:
	@rm -rf .coverage .installed.cfg .mr.developer.cfg bin docs/html htmlcov parts develop-eggs \
		src/tribuna.buildout.egg-info lib include .Python

.PHONY: all docs tests clean
