require 'rubygems'
require 'bundler/setup'
require_relative 'arrow_importer'

# Configure SafePath
SafePath.configure!(File.join('.', 'filesystem_paths.yml'))

filename = SafePath.new('gist_root').join('ABC_Collection-June-2020_03.xlsm')
table_mappings = 'national_collection.yml'
importer = ArrowImporter.new(filename, table_mappings)
importer.load
