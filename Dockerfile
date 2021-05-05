FROM tpgentry/aws-lambda-ruby-arrow:latest

# Gems ########################################################################

# Remove existing bundled rubygems
# RUN rm -rf .bundle/
# RUN rm -rf vendor/

# Copy Gemfile from host into container's current directory
COPY Gemfile .
COPY Gemfile.lock .

RUN yum install -y clang git-core && \
    gem update bundler && \
    bundle config --local silence_root_warning true && \
    bundle config --local path 'vendor/bundle' && \
    bundle config set --local clean 'true' && \
    bundle

# Set up code and entrypoint ##################################################

# Copy function code
COPY filesystem_paths.yml .
COPY lambda_function.rb .
COPY safe_dir.rb .

CMD ["lambda_function.Handler.process"]
# ENTRYPOINT "/bin/bash"
# CMD
