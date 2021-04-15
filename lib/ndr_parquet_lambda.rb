require 'aws-sdk-s3'
require 'pathname'

class NdrParquetLambda
  def initialize(safe_dir:)
    @safe_dir = safe_dir
  end

  def materialise_mappings(mappings)
    safe_mapping_path = @safe_dir.join('mapping.yml')
    File.open(safe_mapping_path, 'w') do |file|
      file.write(mappings)
    end

    safe_mapping_path
  end

  def get_object(bucket, key)
    response = s3.get_object(bucket: bucket, key: key)

    safe_input_path = @safe_dir.join(key)
    File.open(safe_input_path, 'wb') do |file|
      file.write(response.body.read)
    end

    safe_input_path
  end

  def put_object(bucket, path)
    key = path.relative_path_from(@safe_dir).to_s

    response = s3.put_object(
      body: File.open(path, 'r'),
      bucket: bucket,
      key: key
    )
    return {
      bucket: bucket,
      etag: response.etag,
      key: key,
      success: !!response.etag
    }
    rescue StandardError => e
      return {
        bucket: bucket,
        key: key,
        message: e.message,
        success: false
      }
  end

  private

    def s3
      @s3 ||= Aws::S3::Client.new
    end
end