# Peermetrics Starter Kit

Use this when you want the fastest path from clone to `first useful dashboard`.

## What you will do

1. Start Peermetrics locally.
2. Create one app and copy its API key.
3. Run one real test call from the built-in page.
4. Confirm the call shows up in the dashboard.

## 1. Start the stack

Choose the command that matches your machine:

- Intel Linux / Intel Mac:

```sh
git clone https://github.com/peermetrics/peermetrics
cd peermetrics
docker compose up
```

- Apple Silicon (`arm64`) Mac:

```sh
git clone https://github.com/peermetrics/peermetrics
cd peermetrics
DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose up
```

Why: the published `peermetrics/web:latest` and `peermetrics/api:latest`
images are currently `amd64` only, so plain `docker compose up` fails on
Apple Silicon.

When the containers are ready, open `http://localhost:8080`.

Local URLs used in this guide:

- dashboard: `http://localhost:8080`
- API root: `http://localhost:8081/v1`
- test page: `http://localhost:8080/test/webrtc-test.html`

## 2. Create your first app

Log in with the default credentials:

- username: `admin`
- password: `admin`

Then do only this:

1. Create an organization if the UI asks.
2. Create an app.
3. Copy the app API key.

## 3. Send one real session

Open `http://localhost:8080/test/webrtc-test.html`.

On that page, keep the defaults and change only these fields:

- `API Key`: paste the key you copied
- `User ID`: optional, any value you want
- `Conference ID`: optional, any value you want

`API Root` should already be `http://localhost:8081/v1`.

Click `Start Test Call`.

If the browser asks for camera or microphone access, you can allow it for a
full media test, but it is not required for first-run validation. The test page
falls back to a data-channel-only connection and still sends Peermetrics
session data.

## 4. Confirm data in the dashboard

Go back to `http://localhost:8080` and open the dashboard for the same app.

You should see:

- a conference matching the test `Conference ID`
- a participant row for the test user
- session metrics while the call is active

If nothing appears right away, refresh after a few seconds
while the test call is still running.

## 5. Stop the call

Click `Stop Call` on the test page.

That is the full first-run validation: local stack, API key, SDK
initialization, and dashboard ingestion.

## If it does not work

Check the basics first:

- `docker compose ps`
- `docker compose logs api web nginx postgres redis`
- confirm the API key belongs to the app you are viewing
- confirm the test call actually started
- if media permissions were denied, check the test-page logs to make sure it
  continued with the no-media fallback instead of stopping on an init error

## After this

Once this works, move to the integration docs in
[README.md](README.md#how-to-integrate) to wire Peermetrics into your own
app.

If you want to develop the `api` or `web` services locally instead of just
validating the full stack, use the `Development` section in
[README.md](README.md#development). That flow requires cloning the separate
`web` and `api` repos into `./web` and `./api` first.
