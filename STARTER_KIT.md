# Peermetrics Starter Kit

Use this when you want the fastest path from clone to `first useful dashboard`.

## What you will do

1. Start Peermetrics locally.
2. Create one app and copy its API key.
3. Run one real test call from the built-in page.
4. Confirm the call shows up in the dashboard.

## 1. Start the stack

```sh
git clone https://github.com/peermetrics/peermetrics
cd peermetrics
docker compose up
```

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

Click `Start Test Call`, then allow camera and microphone access.

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
- confirm the test call actually started and browser permissions were
  granted

## After this

Once this works, move to the integration docs in
[README.md](README.md#how-to-integrate) to wire Peermetrics into your own
app.
