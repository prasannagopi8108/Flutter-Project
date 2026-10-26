# Production Deployment Guide — Medicine Reminder Web

This guide covers building and deploying the Medicine Reminder Flutter web application across leading hosting platforms: **Vercel**, **Netlify**, **Firebase Hosting**, and **GitHub Pages**.

---

## 1. Prerequisites for Web Build

Ensure you have the Flutter SDK installed and web support enabled:

```bash
flutter doctor
flutter config --enable-web
```

---

## 2. Compiling the Production Web Bundle

### A. Root-Domain Deployment (Standard)

When deploying to a custom domain (e.g. `https://medreminder.app`) or root hosting:

```bash
flutter build web --release
```

- Output directory: `build/web`
- Default base href: `/`

### B. Subpath Deployment (e.g., GitHub Pages)

When deploying to a subpath URL (e.g. `https://username.github.io/Flutter-Project/`):

```bash
flutter build web --release --base-href "/Flutter-Project/"
```

> [!IMPORTANT]
> The `--base-href` argument must always start and end with a forward slash `/`. Omitting the trailing slash causes asset loading failures.

### C. Web Renderers

Flutter offers two web renderers:
1. **Auto (Recommended)**: Uses HTML renderer on mobile browsers for small bundle size and fast load, and CanvasKit on desktop browsers for pixel-perfect rendering:
   ```bash
   flutter build web --release --web-renderer auto
   ```
2. **CanvasKit (High Fidelity)**:
   ```bash
   flutter build web --release --web-renderer canvaskit
   ```

---

## 3. Platform Deployment Guides

### Option 1: Vercel

The project includes a ready-to-deploy [`vercel.json`](file:///c:/Users/prasa/OneDrive/Desktop/Flutter/Flutter-Project/vercel.json) file with single-page application (SPA) routing rewrites.

#### Deploy via Vercel CLI:
```bash
# 1. Build the release bundle
flutter build web --release

# 2. Deploy
vercel --prod
```

#### Deploy via Git Integration:
1. Push this repository to GitHub/GitLab.
2. In the Vercel dashboard, click **Add New Project** and select this repository.
3. Configure settings:
   - **Framework Preset**: Other
   - **Build Command**: `flutter/bin/flutter build web --release` (or use GitHub Actions to build and output to `build/web`)
   - **Output Directory**: `build/web`

---

### Option 2: Netlify

The repository includes a ready-to-deploy [`netlify.toml`](file:///c:/Users/prasa/OneDrive/Desktop/Flutter/Flutter-Project/netlify.toml) file.

#### Deploy via Netlify CLI:
```bash
# 1. Build the release bundle
flutter build web --release

# 2. Deploy to production
netlify deploy --prod --dir=build/web
```

#### Manual Drag-and-Drop:
1. Run `flutter build web --release`.
2. Open [app.netlify.com/drop](https://app.netlify.com/drop).
3. Drag the `build/web` folder into the upload target.

---

### Option 3: Firebase Hosting

The repository includes a ready-to-deploy [`firebase.json`](file:///c:/Users/prasa/OneDrive/Desktop/Flutter/Flutter-Project/firebase.json) file.

#### Steps:
```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Authenticate
firebase login

# 3. Build Web Bundle
flutter build web --release

# 4. Deploy to Firebase
firebase deploy --only hosting
```

---

### Option 4: GitHub Pages

1. Build with the repository name as base href:
   ```bash
   flutter build web --release --base-href "/Flutter-Project/"
   ```
2. Deploy the `build/web` folder to the `gh-pages` branch:
   ```bash
   npx gh-pages -d build/web
   ```

---

## 4. Single-Page Application (SPA) Routing & Fallbacks

Flutter Web is a client-side single page app. If a user refreshes on an inner route or deep link, the web server must serve `index.html` rather than returning a 404 error.

- **Vercel**: Handled via `routes` rewrite in `vercel.json`:
  ```json
  { "src": "/(.*)", "dest": "/index.html" }
  ```
- **Netlify**: Handled via `redirects` in `netlify.toml`:
  ```toml
  [[redirects]]
    from = "/*"
    to = "/index.html"
    status = 200
  ```
- **Firebase**: Handled via `rewrites` in `firebase.json`:
  ```json
  "rewrites": [ { "source": "**", "destination": "/index.html" } ]
  ```

---

## 5. Storage Persistence Across Browser Sessions

- Flutter Web utilizes the browser's HTML5 `localStorage` / `IndexedDB` sandbox for `SharedPreferences`.
- Data is preserved across page reloads and tab closures.
- Clearing browser cache or using Incognito/Private browsing resets local storage upon window closure.
