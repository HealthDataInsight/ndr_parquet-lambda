require_relative 'mongo_db_importer'

# Configure SafePath
SafePath.configure!(File.join('.', 'filesystem_paths.yml'))

filename = SafePath.new('gist_root').join('cwt.xlsx')
table_mappings = 'national_cwt.yml'
importer = MongoDbImporter.new(filename, table_mappings)
importer.load
