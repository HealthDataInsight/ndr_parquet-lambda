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
      arrow_fields = arrow_field_types(table)
      rawtext_column_names = rawtext_names(table)
      output_rows = {}
      rawtext_rows = {}

      table.transform(rows).each_slice(50) do |records|
        records.each do |(instance, fields, _index)|
          klass = instance.split('#').first

          # Convert the fields to an Arrow table "row", with appropriate casting.
          # Unfortunately, Arrow can't do it implicitly.
          output_rows[klass] ||= []
          row = arrow_fields[klass].map do |fieldname, type|
            value = fields[fieldname]
            cast_to_arrow_datatype(value, type)
          end
          output_rows[klass] << row

          rawtext_rows[klass] ||= []
          rawtext_row = rawtext_column_names[klass].map do |rawtext_column_name|
            fields[:rawtext][rawtext_column_name]
          end
          rawtext_rows[klass] << rawtext_row
        end
        record_count += records.count
      end

      basename = File.basename(@filename, File.extname(@filename))
      schemas = arrow_schemas(table)

      output_rows.each do |klass, records|
        # Save the mapped parquet file
        arrow_table = Arrow::Table.new(schemas[klass], records)
        arrow_table.save("#{basename}.#{klass.underscore}.mapped.parquet")
      end

      rawtext_rows.each do |klass, records|
        # Save the rawtext parquet file
        raw_schema = Arrow::Schema.new(rawtext_column_names[klass].map { |fieldname| Arrow::Field.new(fieldname, :string) })
        raw_arrow_table = Arrow::Table.new(raw_schema, rawtext_rows[klass])
        raw_arrow_table.save("#{basename}.#{klass.underscore}.raw.parquet")
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

    def arrow_field_types(table)
      field_types = {}

      masked_mappings = table.send(:masked_mappings)
      masked_mappings.each do |instance, columns|
        klass = instance.split('#').first
        field_types[klass] ||= {}
      
        columns.each do |column|
          next if column['mappings'].nil? || column['mappings'] == []
        
          column['mappings'].each do |mapping|
            field = mapping['field']
            arrow_data_type = mapping['arrow_data_type'] || :string
            field_types[klass][field] = arrow_data_type
          end
        end
      end

      field_types
    end
  
    def arrow_schemas(table)
      schemas = {}

      arrow_field_types(table).each do |klass, field_type_hash|
        field_array = field_type_hash.map { |fieldname, type| Arrow::Field.new(fieldname, type) }
        schemas[klass] = Arrow::Schema.new(field_array)
      end

      schemas
    end

    def rawtext_names(table)
      names = {}

      masked_mappings = table.send(:masked_mappings)
      masked_mappings.each do |instance, columns|
        klass = instance.split('#').first

        names[klass] ||= []
          columns.each do |column|
            rawtext_column_name = column[NdrImport::Mapper::Strings::RAWTEXT_NAME] ||
                                  column[NdrImport::Mapper::Strings::COLUMN]
                                
            next if rawtext_column_name.nil?
          
            names[klass] << rawtext_column_name.downcase
          end
      end

      names
    end

    def cast_to_arrow_datatype(value, type)
      return nil if value.nil?

      # puts "value: " + value.inspect
      # puts "type: " + type.inspect
      # puts
      case type
      when :int32
        Integer(value)
      when :boolean
        ActiveRecord::Type::Boolean.new.cast(value)
      when :string
        value.to_s
      else
        raise "Unrecognised type: #{type.inspect}"
      end
    end
end

# ActiveModel::Type::BigInteger
# ActiveModel::Type::Binary
# ActiveModel::Type::Boolean
# Type::Date
# Type::DateTime
# ActiveModel::Type::Decimal
# ActiveModel::Type::Float
# ActiveModel::Type::Integer
# ActiveModel::Type::ImmutableString
# ActiveRecord::Type::Json
# ActiveModel::Type::String
# Type::Time
# # ActiveModel::Type::Value
