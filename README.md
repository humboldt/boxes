[![Build Status](https://travis-ci.org/a118n/boxes.svg?branch=master)](https://travis-ci.org/a118n/boxes)
[![Code Climate](https://codeclimate.com/github/a118n/boxes/badges/gpa.svg)](https://codeclimate.com/github/a118n/boxes)

# Boxes
Boxes is an asset management web application written primarily for managing printers, MFPs and their supplies. It may prove handy in large offices and corporations where you have to keep track of multitude of devices and supplies they use.

> Note: Currently under active development.

![screenshot](screenshot.png)

### Features
* You can easily assign specific supplies to a particular device and vice versa
* An overview page displays critial and important information, such as supplies that are about to run out of stock, devices that are in repair, etc
* Monthly usage reports for supplies that are delivered to your mailbox
* Monthly usage statistics for each individual supply
* Email notifications when supply is about to run out of stock (controlled by individual threshold)


### Installation
> Note: This instruction describes a sample installation on a clean Ubuntu 16.04 LTS server.

#### Application Stack
The following software is required before installing the application. For a detailed instructions please refer to software providers and distribution manuals.
* Ruby ≥ 2.3.1
* [Phusion Passenger](https://www.phusionpassenger.com/)
* [ElasticSearch](https://www.elastic.co/products/elasticsearch)
* [Redis](http://redis.io/)
* NGINX
* MariaDB (or MySQL)
* Node.js

#### Prerequisites

Install required packages:

```
sudo apt-get install build-essential ruby ruby-dev libmysqlclient-dev mariadb-server default-jre redis-server
```

Install Bundler:

```
sudo gem install bundler
```

Install Node.js:

```
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Install ElasticSearch:

```
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D27D666CD88E42B4

sudo apt-get update && sudo apt-get install elasticsearch
```

#### Clone the repo

```
git clone https://github.com/a118n/boxes.git && cd boxes
```

#### Bundle up

```
bundle install
```

#### Set up database

```
sudo mysql_secure_installation
```

Disable `auth_socket` plugin because it doesn't play nice with Rails:

```
sudo mysql -u root
```

```
MariaDB [(none)]>use mysql;
MariaDB [(mysql)]>update user set plugin=' ' where User='root';
MariaDB [(mysql)]>flush privileges;
MariaDB [(mysql)]>exit
```

Set up your root MySQL password as an environment variable:

```
echo "export BOXES_DATABASE_PASSWORD='YourMySQLRootPassword'" | sudo tee -a /etc/profile
```

Set up production secret key as an environment variable:

```
echo "export SECRET_KEY_BASE='$(bundle exec rails secret)'" | sudo tee -a /etc/profile
```

Load these variables into the shell:

```
source /etc/profile
```

Set up production database:

```
RAILS_ENV=production bundle exec rails db:setup
```

#### Set up ActionMailer

Set email address in `app/mailers/application_mailer.rb`

Set email address in `config/initializers/devise.rb`

Configure email server in `config/environments/production.rb`

#### Set up NGINX & Passenger

[This guide](https://www.phusionpassenger.com/library/install/nginx/install/oss/xenial/) describes installation of NGINX with Passenger.

[This guide](https://www.phusionpassenger.com/library/deploy/nginx/deploy/ruby/) describes application deployment.

Note: if you're having an error that says:

 `Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes. (ExecJS::RuntimeUnavailable)`

 Add ` env PATH;` on top of `/etc/nginx.conf`.

See [this issue](https://github.com/sstephenson/execjs/issues/77).

#### Set up Sidekiq

Copy `vendor/sidekiq.service` to `/lib/systemd/system`

Edit the following fields in `/lib/systemd/system/sidekiq.service`:

 * `WorkingDirectory` Path to the app

* `User` and `Group` Should be self-explanatory

* `Environment=BOXES_DATABASE_PASSWORD=` Password to MySQL

* `Environment=SECRET_KEY_BASE=` Secret Key (As defined earlier)

Enable and start the service:

```
sudo systemctl enable sidekiq && sudo systemctl start sidekiq
```

> Note: you can access Sidekiq WebUI by visiting http://boxes.yourdomain.com/sidekiq/

#### Set up ElasticSearch

Enable and start the service:

```
sudo systemctl enable elasticsearch && sudo systemctl start elasticsearch
```

Reindex:

```
RAILS_ENV=production bundle exec rails searchkick:reindex:all
```

#### Reboot

At this point everything should be set up. Reboot the server and verify the app is running.