# Healthsvc-mon
health monitoring webservice

Healthsvc-mon is a library that monitors, logs, and sends notifications for one or more [Healthsvc](https://github.com/katmore/healthsvc) webservice endpoints.
Additionally, it provides webservice endpoints to examine the latest status and history of *healthsvc* webservice endpoints.

## Feature List
The following checkboxes describes features that are planned for inclusion in the **Healthsvc-mon** project.
Checked items are currently implemented, unchecked items will be available in the future.

**Monitoring and Logging**
 - [ ] Background worker to log the response a [Healthsvc](https://github.com/katmore/healthsvc) webservice endpoint.
 - [ ] Background worker to monitor the logs and determine status of one or more [Healthsvc](https://github.com/katmore/healthsvc) endpoint tests.
 - [ ] Background worker to monitor the status of one or more [Healthsvc](https://github.com/katmore/healthsvc) endpoint tests and send notifications.
 - [ ] Webservice endpoint to provide the status of one or more [Healthsvc](https://github.com/katmore/healthsvc) endpoint tests.
 - [ ] Webservice endpoint to allow a response to notifications.

**Notifications**
 - [ ] **email**
 - [ ] **push message** via [Amazon SNS](https://aws.amazon.com/sns/)
 - [ ] **push message** via [AMQP](https://www.amqp.org/) (i.e. [RabbitMQ](https://www.rabbitmq.com/))
 - [ ] **SMS Text Message** via [Twilio Programmable SMS](https://www.twilio.com/sms)
 - [ ] **SMS Text Message** via [Amazon SNS Transactional SMS](https://aws.amazon.com/sns/sms-pricing/)
 - [ ] **Telephone Voice Call** via [Twilio Programmable Voice](https://www.twilio.com/voice)

## Usage in Existing Projects
Use *Composer* to add to an existing project.

```sh
composer require katmore/healthsvc-mon
```

## Usage as Standalone Service
Download the project:
```sh
git clone https://github.com/katmore/healthsvc-mon.git
```

Update using *Composer*:
```sh
cd healthsvc-mon
composer update
```

## Unit Tests
 * [`coverage.txt`](./coverage.txt): unit test coverage report
 * [`phpunit.xml`](./phpunit.xml): PHPUnit configuration file
 * [`tests/phpunit`](./tests/phpunit): source code for unit tests

To perform unit tests, execute phpunit located in the `vendor/bin` directory.
```sh
vendor/bin/phpunit
```

The [`tests.sh`](./tests.sh) wrapper script is provided for convenience.
```sh
./tests.sh
```

## Legal
"Healthsvc-mon" is distributed under the terms of the [MIT license](LICENSE) or the [GPLv3](GPLv3) license.

Copyright (c) 2018-2019, Doug Bird. All rights reserved.
