require 'ndr_import'
require 'ndr_import/universal_importer_helper'
require 'mongo'

# All files are safe!
class SafeFile
  def self.verify(*_args)
    true
  end
end

# Reads file using NdrImport ETL logic and loads in Mongodb
class MongoDbImporter
  include NdrImport::UniversalImporterHelper

  def initialize(filename, table_mappings)
    @filename = filename
    @table_mappings = YAML.load_file table_mappings
  end

  def load
    ensure_all_mappings_are_tables

    client = Mongo::Client.new(['127.0.0.1:27017'], database: 'test')
    total = 0
    extract(@filename).each do |table, rows|
      collection = client[table.canonical_name.to_sym]
      table.transform(rows).each_slice(50) do |records|
        docs = records.map { |(_klass, fields, _index)| fields }
        result = collection.insert_many(docs)
        puts "Inserted #{result.inserted_count}"
        total += result.inserted_count
      end
    end
    puts "Inserted #{total} records in total"
  end

  private

  def extract(source_file, &block)
    return enum_for(:extract, source_file) unless block

    files = NdrImport::File::Registry.files(source_file)
    files.each do |filename|
      # now at the individual file level, can we find the table mapping?
      table_mapping = get_table_mapping(filename, nil)

      tables = NdrImport::File::Registry.tables(filename,
                                                table_mapping.try(:format),
                                                nil)
      yield_tables_and_their_content(filename, tables, &block)
    end
  end

  def ensure_all_mappings_are_tables
    return if @table_mappings.all? { |table| table.is_a?(NdrImport::Table) }
    raise 'Mappings must be inherit from NdrImport::Table'
  end

  def get_notifier(_value)
  end
end # class MongoDbImporter
