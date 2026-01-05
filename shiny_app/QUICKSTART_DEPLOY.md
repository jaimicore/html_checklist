# Quick Start: Deploy to shinyapps.io

## 5-Minute Deployment

### Step 1: Sign Up (2 min)
Visit https://www.shinyapps.io/ and create a free account

### Step 2: Get Credentials (1 min)
1. Log in → Click your name → **Tokens**
2. Click **Show** → **Show Secret** → **Copy to clipboard**

### Step 3: Deploy (2 min)
```r
# Install deployment package
install.packages("rsconnect")

# Configure account (paste your credentials)
rsconnect::setAccountInfo(
  name   = "your-username",
  token  = "paste-token-here",
  secret = "paste-secret-here"
)

# Deploy!
source("shiny_app/deploy_to_shinyapps.R")
```

### Step 4: Share!
Your app is now live at:
```
https://your-username.shinyapps.io/html-checklist-generator/
```

---

## That's it!

No servers to manage. No installations for users. Just share the link!

**Need help?** See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions and troubleshooting.

---

## Free Tier Includes:
- 5 applications
- 25 active hours/month
- Custom app names
- HTTPS included
- Automatic sleep after 15 min idle

**Perfect for personal projects and sharing with colleagues!**
