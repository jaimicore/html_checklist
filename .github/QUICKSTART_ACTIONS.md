# Quick Reference: GitHub Actions Auto-Deploy

## Setup (One Time Only)

### 1. Get Credentials from shinyapps.io
- Login → Your Name → Tokens → Show → Show Secret
- Copy: Account name, Token, Secret

### 2. Add to GitHub Secrets
Go to: https://github.com/jaimicore/html_checklist/settings/secrets/actions

Add three secrets:
- `SHINYAPPS_ACCOUNT` = your account name
- `SHINYAPPS_TOKEN` = your token
- `SHINYAPPS_SECRET` = your secret

### 3. Push the Workflow
```bash
git add .github/
git commit -m "Add auto-deploy workflow"
git push
```

## Done!

Now every push to main automatically deploys your app.

## Daily Workflow

```bash
# 1. Make changes
# 2. Test locally
shiny::runApp('shiny_app/app.R')

# 3. Commit and push
git add .
git commit -m "Your changes"
git push

# 4. Wait 2-3 minutes - app is automatically deployed!
```

## Monitor Deployments

View status: https://github.com/jaimicore/html_checklist/actions

## Manual Trigger

Actions tab → Deploy to shinyapps.io → Run workflow

## Full Documentation

See [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) for complete details.
