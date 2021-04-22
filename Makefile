image:
	docker build -t lambda-ruby2.7 .

shell:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-ruby2.7

clean:
	rm -rf .bundle/
	rm -rf vendor/
