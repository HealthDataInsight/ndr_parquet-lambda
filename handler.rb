require 'rubygems'
require 'bundler/setup'
require 'ndr_import'
require 'nokogiri'

def main(event:, context:)
  {
    ndr_import_version: NdrImport::VERSION,
    nokogiri_version: Nokogiri::VERSION
  }
end
