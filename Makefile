image:
	docker build -t lambda-ruby2.7 .

shell:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-ruby2.7

install:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-ruby2.7 make _install

import:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-ruby2.7 make _import

# Commands that start with underscore are run *inside* the container.

_install:
	bundle config --local silence_root_warning true
	bundle config --local path 'vendor/bundle'
	bundle config set --local clean 'true'
	bundle install

_import:
	ruby import.rb
