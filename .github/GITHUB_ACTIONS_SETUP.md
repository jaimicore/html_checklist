# GitHub Actions Setup for Automatic Deployment

This guide explains how to set up automatic deployment to shinyapps.io whenever you push changes to GitHub.

## How It Works

When you push changes to the `main` branch (specifically to `shiny_app/`, `checklist_helpers.R`, or the workflow file), GitHub Actions will:

1. Automatically install R and required packages
2. Copy the helper file to the shiny_app directory
3. Deploy the updated app to shinyapps.io

## One-Time Setup

### Step 1: Get Your shinyapps.io Credentials

1. Log in to https://www.shinyapps.io/
2. Click your name (top right) → **Tokens**
3. Click **Show** → **Show Secret**
4. Copy the three values:
   - Account name (e.g., `jaimicore`)
   - Token (long string)
   - Secret (long string)

### Step 2: Add Secrets to GitHub

1. Go to your GitHub repository: https://github.com/jaimicore/html_checklist
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add these three secrets:

   **Secret 1:**
   - Name: `SHINYAPPS_ACCOUNT`
   - Value: Your account name (e.g., `jaimicore`)

   **Secret 2:**
   - Name: `SHINYAPPS_TOKEN`
   - Value: Your token (paste the long string)

   **Secret 3:**
   - Name: `SHINYAPPS_SECRET`
   - Value: Your secret (paste the long string)

### Step 3: Push the Workflow File

The workflow file is already created at `.github/workflows/deploy-shiny.yml`.

Push it to GitHub:

```bash
git add .github/workflows/deploy-shiny.yml
git commit -m "Add automatic deployment workflow"
git push
```

## Usage

Once set up, deployment is **completely automatic**:

1. Make changes to your code locally
2. Test locally: `shiny::runApp('shiny_app/app.R')`
3. Commit and push:
   ```bash
   git add .
   git commit -m "Update app"
   git push
   ```
4. GitHub Actions automatically deploys to shinyapps.io (takes 2-3 minutes)

## Monitoring Deployments

### View Deployment Status

1. Go to your GitHub repository
2. Click **Actions** tab
3. See the latest workflow runs and their status

### Manual Deployment

You can also trigger deployment manually without pushing code:

1. Go to **Actions** tab
2. Click **Deploy to shinyapps.io** workflow
3. Click **Run workflow** → **Run workflow**

## Workflow Triggers

The deployment runs when:
- You push changes to files in `shiny_app/`
- You push changes to `checklist_helpers.R`
- You push changes to the workflow file itself
- You manually trigger it from the Actions tab

## Troubleshooting

### Deployment Fails

1. Check the **Actions** tab for error messages
2. Verify your secrets are correct:
   - Go to Settings → Secrets → Actions
   - Delete and re-add any incorrect secrets

### "Permission denied" Error

Make sure you've added all three secrets with the exact names:
- `SHINYAPPS_ACCOUNT`
- `SHINYAPPS_TOKEN`
- `SHINYAPPS_SECRET`

### Still Using Manual Deployment

You can still use `source("shiny_app/deploy_to_shinyapps.R")` for local deployment if needed. Both methods work independently.

## Security Notes

- Secrets are encrypted by GitHub and never exposed in logs
- Only repository collaborators can view/modify secrets
- GitHub Actions runs in an isolated environment
- Your credentials are safe

## Cost

- GitHub Actions: **Free** for public repositories (2,000 minutes/month for private repos)
- shinyapps.io: Uses your existing free tier (no additional cost)

## Disabling Automatic Deployment

To disable automatic deployment:

1. Go to repository → **Actions** tab
2. Click the workflow name
3. Click the "..." menu → **Disable workflow**

Or delete the workflow file:
```bash
git rm .github/workflows/deploy-shiny.yml
git commit -m "Disable automatic deployment"
git push
```
