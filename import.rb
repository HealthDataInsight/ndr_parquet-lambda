require 'rubygems'
require 'bundler/setup'
require 'ndr_parquet_generator'

# Configure SafePath
SafePath.configure!(File.join('.', 'filesystem_paths.yml'))

filename = SafePath.new('gist_root').join('ABC_Collection-June-2020_03.xlsm')
table_mappings = SafePath.new('gist_root').join('national_collection.yml')
importer = NdrParquetGenerator.new(filename, table_mappings)
importer.load
