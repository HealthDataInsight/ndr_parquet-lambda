require 'rubygems'
require 'bundler/setup'

require 'ndr_parquet'
require 'safe_dir'

# Configure SafePath
SafePath.configure!(File.join('.', 'filesystem_paths.yml'))

class LambdaFunction
  VERSION = '0.1.0'

  def self.process(event:, context:)
    # Set object details
    t0 = Time.current

    input_bucket = event['input_bucket']
    output_bucket = event['output_bucket']
    object_key = event['object_key']
    mappings = event['mappings']

    SafeDir.mktmpdir do |safe_dir|
      s3_wrapper = NdrParquet::S3Wrapper.new(safe_dir: safe_dir)

      # Create a temporary copy of the mappings
      table_mappings = s3_wrapper.materialise_mappings(mappings)

      # Create a temporary copy of the S3 file
      safe_input_path = s3_wrapper.get_object(input_bucket, object_key)

      t1 = Time.current

      # Generate the parquet file(s)
      generator = NdrParquet::Generator.new(safe_input_path, table_mappings, safe_dir)
      generator.process

      t2 = Time.current

      results = []

      # Put the output files in the output S3 bucket
      generator.output_files.each do |output_file_hash|
        object_hash = s3_wrapper.put_object(output_bucket, output_file_hash[:path])
        results << object_hash.merge(total_rows: output_file_hash[:total_rows])
      end

      t3 = Time.current

      return {
        results: results,
        timings: {
          s3_get: t1 - t0,
          generator: t2 - t1,
          s3_put: t3 - t2,
          total: t3 - t0
        },
        versions: {
          lambda_function: LambdaFunction::VERSION,
          ndr_import: NdrImport::VERSION,
          ndr_parquet: NdrParquet::VERSION,
          ruby: RUBY_VERSION
        }
      }
    rescue StandardError => e
      return {
        error: {
          class: e.class,
          message: e.message,
          backtrace: e.backtrace
        }
      }
    end
  end
end
