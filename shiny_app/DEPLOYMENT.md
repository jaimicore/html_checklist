# Deployment Instructions for shinyapps.io

## Quick Start

### 1. Create a Free Account
- Go to https://www.shinyapps.io/
- Sign up for a free account (supports 5 apps, 25 active hours/month)

### 2. Get Your Credentials
- Log in to shinyapps.io
- Click on your name (top right) → **Tokens**
- Click **Show** → **Show Secret** → **Copy to clipboard**

### 3. Configure Authentication
Open R and run:

```r
# Install rsconnect
install.packages("rsconnect")

# Configure your account (replace with your credentials)
rsconnect::setAccountInfo(
  name   = "YOUR-ACCOUNT-NAME",
  token  = "YOUR-TOKEN-HERE", 
  secret = "YOUR-SECRET-HERE"
)
```

### 4. Deploy Your App
From the project root directory, run:

```r
source("shiny_app/deploy_to_shinyapps.R")
```

The script will:
1. Copy `checklist_helpers.R` to the shiny_app folder (required for deployment)
2. Deploy the app to shinyapps.io
3. Open your browser to the live app

Or manually:

```r
library(rsconnect)

# Copy helper file to shiny_app directory
file.copy("checklist_helpers.R", "shiny_app/checklist_helpers.R", overwrite = TRUE)

# Deploy
setwd("shiny_app")
rsconnect::deployApp(appName = "html-checklist-generator")
```

### 5. Share Your App
After deployment, your app will be live at:
```
https://YOUR-ACCOUNT-NAME.shinyapps.io/html-checklist-generator/
```

Share this URL with anyone! No R installation required.

---

## Managing Your App

### View App Dashboard
https://www.shinyapps.io/admin/#/applications

From here you can:
- View usage statistics
- Start/stop your app
- View logs
- Configure settings
- Archive old apps

### Update Your App
Make changes to `app.R`, then re-run:

```r
source("shiny_app/deploy_to_shinyapps.R")
```

The script will update your existing app.

### Free Tier Limits
- **5 applications** maximum
- **25 active hours** per month
- **1 GB memory** per app
- Apps sleep after 15 minutes of inactivity

Note: Active hours = time when someone is using your app. Sleeping apps don't count.

---

## Troubleshooting

### "No account configured" error
Make sure you ran `setAccountInfo()` with your credentials first.

### Deployment fails
1. Check that all required packages are listed in `app.R`
2. Make sure you're deploying from the `shiny_app/` directory
3. Check the deployment log for specific errors

### App crashes after deployment
1. Go to https://www.shinyapps.io/admin/#/applications
2. Click on your app → Logs
3. Look for error messages

### Need more hours?
- Upgrade to a paid plan (starts at $9/month for 100 hours)
- Or use multiple free accounts (not recommended)
- Or deploy to your own Shiny Server

---

## Alternative Deployment Options

If shinyapps.io doesn't meet your needs:

1. **Hugging Face Spaces** - Free, but requires Docker setup
2. **Your own Shiny Server** - Free but need a Linux server
3. **Posit Connect** - Enterprise solution, paid

---

## Security Considerations

- Don't commit your token/secret to GitHub!
- The deployment script keeps credentials local
- Regenerate tokens if accidentally exposed
- Free apps are public by default (upgrade for authentication)

---

## Custom Domain (Paid Plans Only)

Paid plans allow custom domains:
```
https://checklist.yourdomain.com
```

Instead of:
```
https://yourname.shinyapps.io/html-checklist-generator/
```
