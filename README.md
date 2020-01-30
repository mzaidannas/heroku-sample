# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


## Dokku Deployment

### On Remote

### Install Dokku

* wget -nv -O - https://get.docker.com/ | sh
* wget -nv -O - https://packagecloud.io/dokku/dokku/gpgkey | apt-key add -
* export SOURCE="https://packagecloud.io/dokku/dokku/ubuntu/"
* export OS_ID="$(lsb_release -cs 2>/dev/null || echo "trusty")"
* echo "utopicvividwilyxenialyakketyzestyartfulbionic" | grep -q "$OS_ID" || OS_ID="trusty"
* echo "deb $SOURCE $OS_ID main" | tee /etc/apt/sources.list.d/dokku.list
* apt-get update
* apt-get install dokku
* dokku plugin:install-dependencies --core # run with root!

### Install dokku postgres plugin

* dokku apps:create sample
* sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
* dokku postgres:create sample_production
* dokku postgres:link sample_production sample

### On Local

* git remote add dokku dokku@$REMOTE_IP:sample
* cat ~/.ssh/id_rsa.pub | ssh root@$REMOTE_IP "sudo sshcommand acl-add dokku dokku"
* git push dokku master

### Import existing db dump
dokku postgres:import sample_production < dump.postgres.sql
dokku postgres:help

### Set default domain
dokku domains:add sample domainname.com
dokku domains sample
dokku domains:report
dokku domains:add-global sample domainname.com
dokku domains:report
dokku domains:enable sample
dokku domains:report
dokku deploy sample
