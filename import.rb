require_relative 'mongo_db_importer'

filename = 'cwt.xlsx'
table_mappings = 'national_cwt.yml'
importer = MongoDbImporter.new(filename, table_mappings)
importer.load
