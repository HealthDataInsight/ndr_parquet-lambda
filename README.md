# ndr_import-parquet-example

Based on [Ollie Tulloch](https://github.com/ollietulloch)'s boilerplate MongoDB example, this demonstrates the generation of a parquet file using [ndr_import](https://github.com/PublicHealthEngland/ndr_import) and [Apache Arrow](https://arrow.apache.org).

## Installation

To install Apache Arrow on a mac using homebrew, execute:

    $ brew install apache-arrow

and then execute:

    $ bundle install

### AWS Linux

To make the AWS Linux docker container with Apache Arrow, execute:

    $ make image

and then execute:

    $ make install

## Usage

To convert the sample collection spreadsheet `ABC_Collection-June-2020_03.xlsm` to parquet format, using the `national_collection.yml` mapping file, execute:

    $ ruby import.rb

or to convert the spreadsheet in the docker container, execute:

    $ make import
