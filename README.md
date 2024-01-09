# peer metrics - WebRTC metrics analyzer

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://makeapullrequest.com)![GitHub License](https://img.shields.io/github/license/peermetrics/peermetrics)

The all complete solution to monitor your WebRTC implementation.

peer metrics offers fully open source client SDKs and back-end services for you to start collecting metrics and create the perfect product.

For hosted versions check [peermetrics.io](https://peermetrics.io/).

Table of Contents
=================

* [About](#about)
* [Features](#features)
* [How it works](#how-it-works)
* [Tech stack](#tech-stack)
* [How to run locally](#how-to-run-locally)
* [How to Deploy](#how-to-deploy)
  * [Docker](#docker)
  * [Google app engine](#google-app-engine)
* [Development](#development)
  * [Clone repos](#clone-repos)
  * [Start docker](#start-docker)
  * [Start watcher](#start-watcher)
* [How to integrate](#how-to-integrate)
* [Other](#other)
  * [DB Migrations](#db-migrations)
  * [API Admin](#api-admin)
  * [CSS](#css)

## About

peer metrics is the complete solution to start monitoring your WebRTC implementation.

The [javascript SDK](https://github.com/peermetrics/sdk-js) integrates with the major WebRTC libs like Livekit, Mediasoup, Janus, etc, [more here](https://github.com/peermetrics/sdk-js).

This repo contains examples on how to run the back-end services of peer metrics: 

- api: the ingestion endpoint
- web: the visualization service

## Features

#### View app overview
![image](https://github.com/peermetrics/peermetrics/assets/1862405/ec27ac03-9b85-439c-9630-fcc5fa7c80cf)

#### Drilldown into conference
![image](https://github.com/peermetrics/peermetrics/assets/1862405/32715cc0-bb73-4bbb-82dd-3d236452355a)

#### See detailed connection timeline
![image](https://github.com/peermetrics/peermetrics/assets/1862405/a0333090-d192-4099-88d3-75343d12bdb0)

#### Advanced quality graphs
![image](https://github.com/peermetrics/peermetrics/assets/1862405/9bb4981a-71bb-4995-b29f-7a135469d036)

#### Automatically detected issues
For a whole list check [ISSUES.md](ISSUES.md)

![image](https://github.com/peermetrics/peermetrics/assets/1862405/be67c082-7220-432a-8843-fd9788dac6e9)

## How it works

peer metrics contains all the components you need to monitor and improve your WebRTC app:

- **client SDKs**: used for collecting metrics from client devices (right now we only support the [JavaScript SDK)](https://github.com/peermetrics/sdk-js).
- **ingestion endpoint**: this is a server where the SDK sends the metrics collected (this is the [api](https://github.com/peermetrics/api) service).
- **visualization endpoint**: used by the dev / customer team to visualize the metrics collected (this is the [web](https://github.com/peermetrics/web) service).

The reason for separating into **api** and **web** it's because the services have different scaling needs.

## Tech stack

Both **api** and **web** have the same backend:

- Language: Python 3.8
- Framework: Django
- DB: Postgres
- Template rendering: Jinja2
- Frontend: VueJS

## How to run locally

Fastest way to get started is to pull this repo and use docker compose

```sh
git pull https://github.com/peermetrics/peermetrics .
cd peermetrics
docker-compose up --build
```

## How to Deploy

Because peer metrics consists for two services, both need to be deployed independently. 

This also offers the flexibility to scale them separately.

There are multiple ways to deploy peer metrics:

### Docker

The recommended way for deploying is to use Docker.

There are 2 images on Docker Hub:

- **api**: `peermetrics/api`
- **web**: `peermetrics/web`

For inspiration on how to use the images with Docker Compose check the files:

- api: [docker-compose.api.yaml](docker-compose.api.yaml)
- web: [docker-compose.web.yaml](docker-compose.web.yaml)

To deploy both containers on the same server look at [docker-compose.yaml](docker-compose.yaml)

### Google app engine

You also have the option to deploy the app as a [Google App engine service](https://cloud.google.com/appengine?hl=en).

Each service repo has a `app_engine.yaml` file that will help you deploy both services to App engine. 

Check the files for [web](https://github.com/peermetrics/web) and [api](https://github.com/peermetrics/api).

## Development

To start developing peer metrics locally:

1. #### Clone repos

Clone this repo:

```sh
git clone https://github.com/peermetrics/peermetrics && cd peermetrics
```

Then clone  `api` and `web`:

```sh
git clone https://github.com/peermetrics/web
```

```sh
git clone https://github.com/peermetrics/api
```

2. #### Start docker

To start development start Docker using the special dev file:

```sh
docker-compose -f docker-compose.dev.yaml up
```

3. #### Start watcher

Optionally, you can also start the watcher for the vue files:

```sh
cd web
npm install
npm start watch
```

## How to integrate

To integrate peer metrics into your WebRTC app you need to follow these steps:

1. Deploy the **api** / **web** images using Docker or any of the options found in [How to deploy](#how-to-deploy).
2. Access the **web** service, create a new organization and app. There will be an API key associated with the new app.
3. Integrate the Javascript SDK following the steps [listed here](https://github.com/peermetrics/sdk-js).
4. When initializing the JS SDK, use an additional attribute `apiRoot` to start using your custom API endpoint.

For example, if you deployed the **api** endpoint at `api.example.com`, the initializing object will become:

```javascript
let peerMetrics = new PeerMetrics({
    apiRoot: 'https://api.example.com/v1',
    apiKey: '7090df95cd247f4aa735779636b202', // api key from the newly created app
    userId: '1234',
    userName: 'My user',
    conferenceId: 'conference-1',
    conferenceName: 'Conference from 4pm',
    appVersion: '1.0.1'
})
```

**Note**: very important that `apiRoot` is a valid URL and ends with `/v1`

4. Follow the instructions in the [SDK repo](https://github.com/peermetrics/sdk-js) to start collecting metrics.

## Other

### DB Migrations

A think to note is that the **api** container runs the Django migrations automatically when it starts. 

Details are in the docker compose files.

### API Admin

In order to debug conferences, events, etc you can use the Admin section in the `api` container.

For that, you need to create a superuser:

```sh
# sh into the api container
docker-compose run api sh
# run the createsuperuser command
python manage.py createsuperuser --username admin --email admin@admin.com
# it will ask for you to choose a password
```

You'll also need to collectstatic:

```sh
python manage.py collectstatic --clear --noinput
```

### CSS

For **web** you have the following commands:

- compile CSS

```sh
npm run css
```

- start CSS watcher

```sh
npm run css-watch
```
