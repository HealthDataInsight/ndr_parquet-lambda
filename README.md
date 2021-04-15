# ndr_import-parquet-example

This is a proof of concept AWS Lambda, using [ndr_parquet](https://github.com/timgentry/ndr_parquet) to generate parquet files from [numerous filetypes](https://github.com/publichealthengland/ndr_import#ndrimport---).

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/timgentry/ndr_import-parquet-example. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/timgentry/ndr_import-parquet-example/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ndr_import-parquet-example project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/timgentry/ndr_import-parquet-example/blob/main/CODE_OF_CONDUCT.md).