
.PHONY: build

build:
	docker build --file Dockerfile -t  phlummox/firefox-esr:0.1 .	

