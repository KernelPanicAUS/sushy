BUNDLE=sushy.zip

repl:
	PYTHONPATH=$(BUNDLE) hy

deps:
	pip -r requirements.txt

clean:
	rm -f *.zip
	rm -f sushy/*.pyc

bundle: clean
	hyc sushy/*.hy
	zip -r9 $(BUNDLE) . -i *.py *.pyc

serve: bundle
	PYTHONPATH=$(BUNDLE) CONTENT_PATH=pages python -m sushy
