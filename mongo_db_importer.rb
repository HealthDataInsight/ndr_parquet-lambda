require 'ndr_import'
require 'ndr_import/universal_importer_helper'
require 'mongo'

# Reads file using NdrImport ETL logic and loads in Mongodb
class MongoDbImporter
  include NdrImport::UniversalImporterHelper

  def initialize(filename, table_mappings)
    @filename = filename
    @table_mappings = YAML.load_file table_mappings
    @client = Mongo::Client.new(['127.0.0.1:27017'], database: 'test')

    ensure_all_mappings_are_tables
  end

  def load
    record_count = 0
    extract(@filename, unzip_path).each do |table, rows|
      collection = @client[table.canonical_name.to_sym]
      table.transform(rows).each_slice(50) do |records|
        docs = records.map { |(_klass, fields, _index)| fields }
        result = collection.insert_many(docs)
        record_count += result.inserted_count
      end
    end
    puts "Inserted #{record_count} records in total"
  end

  private

  def ensure_all_mappings_are_tables
    return if @table_mappings.all? { |table| table.is_a?(NdrImport::Table) }
    raise 'Mappings must be inherit from NdrImport::Table'
  end

  def unzip_path
    @unzip_path ||= SafePath.new('unzip_path')
  end

  def get_notifier(_value)
  end
end # class MongoDbImporter
