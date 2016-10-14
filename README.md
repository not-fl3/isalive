![Alt text](http://i.imgur.com/9dsfneq.gif "screencast")

IS ALIVE
========

Self hosted app for monitoring project pulse.

One page visualization for every possible sources - like build servers, human heart-bit sensors, social networks activity, git commit frequency etc.

Built with Rust on backend and Elm on frontend.

Its mostly educational project - so, if you want to try rust or elm - we will have a lot of tasks in issues and any contributions will be highly welcomed!

How to build
------------

``` make client ``` from root folder to rebuild client

``` cargo run --release ``` to run server

Configuration
-------------
Project name, description, footer and services list can be configured at ```config/config.toml``` file. "Secret" metntioned in Services section - is key for posting status from sensors.

Roadmap
-------

* Integrate more sensors
  - twitter posts
  - git activity
  - textual notes
  - raspberry pi with sensors
* Move to cloud
  Instead of self-hosted made it cloud service - where anyone can register his project.
