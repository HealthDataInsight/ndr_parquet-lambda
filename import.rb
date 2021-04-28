require 'json'
require_relative 'lambda_function'

event = {
  input_bucket: 'ruby-etl-lambda-inbox',
  output_bucket: 'ruby-etl-lambda-outbox',
  object_key: 'ABC_Collection-June-2020_03.xlsm',
  mappings: File.open('test/resources/national_collection.yml', 'r').read
}
event_json = JSON.generate(event)

puts event_json
puts
puts Handler.process(event: JSON.parse(event_json), context: nil)
