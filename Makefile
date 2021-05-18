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
	curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{"input_bucket":"ruby-etl-lambda-inbox","output_bucket":"ruby-etl-lambda-outbox","object_key":"ABC_Collection-June-2020_03.xlsm","mappings": File.open('test/resources/national_collection.yml', 'r').read}'

