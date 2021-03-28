FROM lambci/lambda:build-ruby2.7

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y https://apache.bintray.com/arrow/centos/7/apache-arrow-release-latest.rpm
RUN yum install -y --enablerepo=epel arrow-glib-devel
RUN yum install -y --enablerepo=epel parquet-glib-devel

RUN gem update bundler

CMD "/bin/bash"
