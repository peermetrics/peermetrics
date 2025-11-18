# PeerMetrics WebRTC Test Tool

A simple HTML/vanilla JavaScript tool to test your PeerMetrics setup with WebRTC calls.

## Usage

1. **Start your PeerMetrics services** using docker compose:
   ```sh
   docker compose up
   ```

2. **Get your API Key**:
   - Open the web dashboard at `http://localhost:8080`
   - Log in with default credentials (admin/admin)
   - Create an organization and app
   - Copy the API key from the app dashboard

3. **Open the test tool**:
   - The test page is automatically served by nginx when running docker compose
   - Simply navigate to: **`http://localhost:8080/test/webrtc-test.html`**
   - No additional setup needed!

4. **Configure the test**:
   - **API Root**: Should be `http://localhost:8081/v1` (default)
   - **API Key**: Paste the API key from step 2
   - Adjust other fields as needed (User ID, Conference ID, etc.)

5. **Start the test**:
   - Click "Start Test Call"
   - Allow camera/microphone permissions when prompted
   - The tool will create a WebRTC connection and start sending metrics to PeerMetrics
   - Watch the logs for status updates

6. **View metrics**:
   - Go to `http://localhost:8080` in another tab
   - Navigate to your app dashboard
   - You should see the test conference and participant data

7. **Stop the test**:
   - Click "Stop Call" when done
   - The conference will be ended in PeerMetrics

## Features

- Simple WebRTC peer-to-peer connection for testing
- Real-time status indicators
- Detailed logging
- Video preview (local and remote)
- Automatic PeerMetrics integration
- No build step required - pure HTML/JS

## Troubleshooting

- **"WebRTC not supported"**: Make sure you're using a modern browser (Chrome, Firefox, Safari, Edge)
- **"Failed to initialize PeerMetrics"**: 
  - Check that the API is running on port 8081
  - Verify the API key is correct
  - Check browser console for CORS errors
- **No video**: Make sure you granted camera/microphone permissions
- **Connection fails**: Check that both API and web services are running

