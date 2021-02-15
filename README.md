# ndr_import-parquet-example

Based on [Ollie Tulloch](https://github.com/ollietulloch)'s boilerplate MongoDB example, this demonstrates the generation of a parquet file using [ndr_import](https://github.com/PublicHealthEngland/ndr_import) and [Apache Arrow](https://arrow.apache.org).

## Installation

To install Apache Arrow on a mac using homebrew, execute:

    $ brew install apache-arrow

and then execute:

    $ bundle install

## Usage

To convert the sample CWT spreadsheet `cwt.xlsx` to parquet format, using the `national_cwt.yml` mapping file, execute:

    $ ruby import.rb
