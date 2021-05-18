image:
	docker build -t lambda-ruby2.7 .

shell:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-ruby2.7

clean:
	rm -rf .bundle/
	rm -rf vendor/
	
aws-setup:
	aws --endpoint-url='http://localhost:4566' s3 mb 's3://ruby-etl-lambda-inbox' 
	aws --endpoint-url='http://localhost:4566' s3 mb 's3://ruby-etl-lambda-outbox'
	aws --endpoint-url='http://localhost:4566' s3 cp 'test/resources/ABC_Collection-June-2020_03.xlsm' 's3://ruby-etl-lambda-inbox/ABC_Collection-June-2020_03.xlsm'

aws-teardown:
	aws --endpoint-url='http://localhost:4566' s3 rb 's3://ruby-etl-lambda-inbox' --force
	aws --endpoint-url='http://localhost:4566' s3 rb 's3://ruby-etl-lambda-outbox' --force
	
docker-up:
	docker-compose up -d
	
docker-down:
	docker-compose down

lambda-test:
	curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{"input_bucket":"ruby-etl-lambda-inbox","output_bucket":"ruby-etl-lambda-outbox","object_key":"ABC_Collection-June-2020_03.xlsm","mappings":"---\n- !ruby/object:NdrImport::Table\n  canonical_name: two_week_wait\n  filename_pattern: !ruby/regexp /.*/i\n  tablename_pattern: !ruby/regexp /Backsheet/i\n  header_lines: 1\n  footer_lines: 0\n  klass: Hash\n  columns:\n  - column: :filename\n    mappings:\n    - field: providercode\n      replace:\n      - ? !ruby/regexp /_Collection-.*-20.*\\.xlsm\\z/\n        : ''\n  - column: SQU03_5_3_1:N\n    mappings:\n    - field: SQU03_5_3_1\n      arrow_data_type: :int32\n  - column: SQU03_5_3_2:N\n    mappings:\n    - field: SQU03_5_3_2\n      arrow_data_type: :int32\n  - column: SQU03_6_2_1:N\n    mappings:\n    - field: SQU03_6_2_1\n      arrow_data_type: :int32\n  - column: SQU03_6_2_2:N\n    mappings:\n    - field: SQU03_6_2_2\n      arrow_data_type: :int32\n  - column: K1n:N\n    mappings:\n    - field: K1N\n      arrow_data_type: :boolean\n  - column: K1m:N\n    mappings:\n    - field: K1M\n  - column: K150:N\n    mappings:\n    - field: K150\n  - column: K190:N\n    mappings:\n    - field: K190\n  - column: F1n:N\n    mappings:\n    - field: F1N\n  - column: F1t:N\n    mappings:\n    - field: F1T\n  - column: F1m:N\n    mappings:\n    - field: F1M\n  - column: F190:N\n    mappings:\n    - field: F190\n  - column: P1b:N\n    mappings:\n    - field: P1B\n  - column: P1n:N\n    mappings:\n    - field: P1N\n"}'

