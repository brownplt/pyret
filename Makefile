PORT=5150

serve:
	raco pollen start . ${PORT} &
	open http://localhost:${PORT}/index.ptree

clean:  # clears the Pollen cache — often the culprit when reloading a file doesn't show a change
	raco pollen reset

ps:
	ps -ef | grep ${PORT} | grep pollen | grep -v grep

docs/horizon:
	git clone --branch horizon https://github.com/brownplt/pyret-docs horizon-docs
	cd horizon-docs; npm install; make
	mkdir -p site/docs/
	cp -r horizon-docs/build/docs site/docs/horizon

docs/latest:
	git clone --branch master https://github.com/brownplt/pyret-docs latest-docs
	cd latest-docs; npm install; make
	mkdir -p site/docs/
	cp -r latest-docs/build/docs site/docs/latest

site/docs/index.html:
	mkdir -p site/docs/
	cp src/docs-redirect.html site/docs/index.html

docs: site/docs/index.html docs/horizon docs/latest

# .Phony: all
# all: pages

# site/js/codemirror.js: node_modules/codemirror/lib/codemirror.js
# 	cp $< $@

# site/js/pyret.js: node_modules/pyret-codemirror-mode/mode/pyret.js
# 	cp $< $@

# site/js/runmode.js: node_modules/codemirror/addon/runmode/runmode.js
# 	cp $< $@

# docs/horizon:
# 	git clone --branch horizon https://github.com/brownplt/pyret-docs horizon-docs
# 	cd horizon-docs; npm install; make
# 	mkdir -p site/docs/
# 	cp -r horizon-docs/build/docs site/docs/horizon

# docs/latest:
# 	git clone --branch master https://github.com/brownplt/pyret-docs latest-docs
# 	cd latest-docs; npm install; make
# 	mkdir -p site/docs/
# 	cp -r latest-docs/build/docs site/docs/latest

# site/docs/index.html:
# 	mkdir -p site/docs/
# 	cp src/docs-redirect.html site/docs/index.html

# CM_JS = site/js/codemirror.js site/js/pyret.js site/js/runmode.js

# .Phony: pages
# pages: $(CM_JS)
# 	raco frog -b

# .Phony: pages-and-docs
# pages-and-docs: pages docs/horizon docs/latest site/docs/index.html

# .Phony: serve
# serve:
# 	raco frog -s

# .Phony: clean
# clean:
# 	raco frog --clean
