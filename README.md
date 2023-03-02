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

## Manual Deployment

# On Bare metal ubuntu server

# Prerequisites on server

```bash
# Libraries, compilers and development files required
sudo apt install -y build-essential git git-lfs openssl libssl-dev ruby ruby-build libmysqlclient-dev libpq-dev libvips42 libxml2-dev curl ca-certificates gnupg

# Database services
# Postgresql
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install postgresql-15
sudo systemctl restart postgresql
sudo systemctl enable postgresql
sudo -u postgres psql -U postgres -d postgres -c "ALTER USER postgres WITH PASSWORD '$password';"

# Redis
sudo add-apt-repository -y ppa:redislabs/redis
sudo apt install -y redis-server
sudo systemctl restart redis-server
sudo systemctl enable redis-server

# Web server
# Nginx
sudo apt install nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```


## Dokku Deployment

### On Remote

### Install Dokku

```bash
wget -nv -O - https://get.docker.com/ | sh
wget -nv -O - https://packagecloud.io/dokku/dokku/gpgkey | sudo apt-key add -
export SOURCE="https://packagecloud.io/dokku/dokku/ubuntu/"
export OS_ID="$(lsb_release -cs 2>/dev/null || echo "focal")"
echo "utopicvividwilyxenialyakketyzestyartfulbionicfocal" | grep -q "$OS_ID" || OS_ID="focal"
echo "deb $SOURCE $OS_ID main" | sudo tee /etc/apt/sources.list.d/dokku.list
sudo apt-get update
sudo apt-get install dokku
sudo dokku plugin:install-dependencies --core # run with root!
```

### Install dokku postgres plugin

```bash
dokku apps:create sample
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
dokku postgres:create sample_production
dokku postgres:link sample_production sample
```

### Install dokku redis plugin
```bash
sudo dokku plugin:install https://github.com/dokku/dokku-redis.git redis
dokku redis:create sample_redis
dokku redis:link sample_redis sample
```

### On Local

```bash
git remote add dokku dokku@$REMOTE_IP:sample
cat ~/.ssh/id_rsa.pub | ssh -i pemfile.pem ubuntu@$REMOTE_IP "sudo sshcommand acl-add dokku dokku"
git push dokku master
```
### Import existing db dump

```bash
dokku postgres:import sample_production < dump.postgres.sql
dokku postgres:help
```
### Set default domain

```bash
dokku domains:add sample domainname.com
dokku domains sample
dokku domains:report
dokku domains:add-global sample domainname.com
dokku domains:report
dokku domains:enable sample
dokku domains:report
dokku deploy sample
```
