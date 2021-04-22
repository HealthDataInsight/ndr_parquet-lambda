# Core ########################################################################

FROM lambci/lambda:build-ruby2.7
# FROM public.ecr.aws/lambda/ruby:2.7
# FROM amazon/aws-lambda-ruby:2.7
# FROM amazonlinux:latest

# Install ruby
# RUN amazon-linux-extras install -y ruby2.6

# Update all existing packages
RUN yum update -y

# Optimize compilation for size to try and stay below Lambda's 250 MB limit
# This reduces filesize by over 90% (!) compared to the default -O2
ENV CFLAGS "-Os"
ENV CXXFLAGS $CFLAGS

# Apache Arrow ################################################################

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y https://apache.bintray.com/arrow/centos/7/apache-arrow-release-latest.rpm
RUN yum install -y --enablerepo=epel arrow-glib-devel
RUN yum install -y --enablerepo=epel parquet-glib-devel

# Gems ########################################################################

# Remove existing bundled rubygems
RUN rm -rf .bundle/
RUN rm -rf vendor/

# Update Bundler
RUN gem update bundler

# Install the Runtime Interface Client
RUN gem install aws_lambda_ric --no-document

# Copy Gemfile from host into container's current directory
COPY Gemfile .

# RUN bundle config --local silence_root_warning true
RUN bundle config --local path 'vendor/bundle'
# RUN bundle config set --local clean 'true'
RUN bundle

# Copy function code
COPY filesystem_paths.yml .
COPY lambda.rb .
COPY lambda_function.rb .
COPY safe_dir.rb .

ENTRYPOINT ["/var/runtime/bin/aws_lambda_ric"]
CMD ["lambda_function.Handler.process"]
# CMD "/bin/bash"