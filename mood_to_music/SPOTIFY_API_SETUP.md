# Spotify API Setup Guide

## 🎵 Mood-to-Music App - Spotify API Configuration

### Step 1: Create Spotify Developer Account

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in with your Spotify account (or create one)
3. Click **"Create App"**

### Step 2: Configure Your App

Fill in the following details:

- **App Name**: Mood to Music
- **App Description**: A Flutter app that recommends playlists based on your mood
- **Redirect URI**: `http://localhost` (not used in this app but required)
- **APIs Used**: Web API
- **Accept Terms**: Check the box

Click **"Save"**

### Step 3: Get Your Credentials

1. After creating the app, you'll see your **Dashboard**
2. Click on **"Settings"**
3. Copy your **Client ID**
4. Click **"View client secret"** and copy your **Client Secret**

### Step 4: Add Credentials to the App

1. Open the file: `lib/config/spotify_config.dart`
2. Replace the placeholders:

```dart
static const String clientId = 'YOUR_CLIENT_ID_HERE';     // ← Paste your Client ID
static const String clientSecret = 'YOUR_CLIENT_SECRET_HERE';  // ← Paste your Client Secret
```

3. Save the file

### Step 5: Test the App

```bash
flutter run
```

The app will now fetch **real playlists** from Spotify!

---

## 🔒 Security Notes

- ✅ The `spotify_config.dart` file is **already added to .gitignore**
- ⚠️ **NEVER** commit your API credentials to public repositories
- ⚠️ **NEVER** share your Client Secret publicly
- ✅ If credentials are compromised, regenerate them in Spotify Dashboard

---

## 🧪 Testing

1. Select a mood (e.g., "Happy")
2. The app will:
   - Request an access token from Spotify
   - Search for playlists matching that mood
   - Display real Spotify playlists
3. Click on a playlist to open it in Spotify

---

## 🔄 Fallback Behavior

If API calls fail (wrong credentials, network issues), the app will automatically:
- Fall back to mock data
- Still work without internet connection
- Show a message in the console for debugging

---

## 📝 API Limits

Spotify Free Developer Account:
- ✅ Unlimited API calls for Client Credentials flow
- ✅ 10 playlists per search query
- ✅ Token expires after 1 hour (auto-renewed by the app)

---

## 🛠️ Troubleshooting

### "Failed to get access token"
- Check if Client ID and Secret are correct
- Ensure no extra spaces in the credentials
- Check your internet connection

### "No playlists found"
- This is normal for some moods
- The app will fall back to mock data
- Try a different mood

### App shows mock data instead of real playlists
- Check console logs for error messages
- Verify credentials are set correctly
- Test API credentials using curl:

```bash
curl -X POST "https://accounts.spotify.com/api/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=client_credentials&client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET"
```

---

## 🎉 Done!

Your app is now connected to Spotify API and ready to use! 🎵
