require 'ndr_import'
require 'ndr_import/universal_importer_helper'
require 'parquet'

# Reads file using NdrImport ETL logic and loads in Mongodb
class ArrowImporter
  include NdrImport::UniversalImporterHelper

  def initialize(filename, table_mappings)
    @filename = filename
    @table_mappings = YAML.load_file table_mappings

    ensure_all_mappings_are_tables
  end

  def load
    record_count = 0
    extract(@filename).each do |table, rows|
      docs = []
      table.transform(rows).each_slice(50) do |records|
        rawtexts = records.map { |(_klass, fields, _index)| fields[:rawtext] }
        docs.concat(rawtexts)
        record_count += rawtexts.count
      end

      fieldnames = docs.first.keys
      schema = Arrow::Schema.new(fieldnames.map { |fieldname| Arrow::Field.new(fieldname, :string) })
      
      arrow_table = Arrow::Table.new(schema, docs.map(&:values))
      arrow_table.save("#{@filename}.parquet")
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
end
