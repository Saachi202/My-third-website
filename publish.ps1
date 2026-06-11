param(
  [string]$RepoUrl = 'https://github.com/Saachi202/My-first-website.git',
  [string]$Branch = 'main',
  [switch]$UseGhPagesBranch
)

Write-Host "Publish script starting..."

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "git is not installed or not found in PATH. Install git and try again."
  exit 1
}

if (-not (Test-Path .git)) {
  Write-Host "Initializing git repository..."
  git init
}

Write-Host "Staging files..."
git add .

try {
  git commit -m "Initial website scaffold" | Out-Null
  Write-Host "Committed files."
} catch {
  Write-Host "No new changes to commit or commit failed: $_"
}

Write-Host "Setting branch to '$Branch'..."
git branch -M $Branch

$remoteExists = git remote | Select-String -Pattern '^origin$'
if ($remoteExists) {
  Write-Host "Removing existing 'origin' remote..."
  git remote remove origin
}
Write-Host "Adding remote origin: $RepoUrl"
git remote add origin $RepoUrl

if ($UseGhPagesBranch) {
  Write-Host "Creating and pushing 'gh-pages' branch..."
  git checkout -b gh-pages
  git push -u origin gh-pages -f
  $publishBranch = 'gh-pages'
} else {
  Write-Host "Pushing branch '$Branch' to origin..."
  git push -u origin $Branch -f
  $publishBranch = $Branch
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
  if ($RepoUrl -match 'github.com[:/](.+?)/(.+?)(\.git)?$') {
    $owner = $matches[1]
    $repo = $matches[2]
    Write-Host "Enabling GitHub Pages for $owner/$repo on branch '$publishBranch'..."
    gh api --method PUT "/repos/$owner/$repo/pages" -f source.branch=$publishBranch -f source.path="/" | Write-Host
    Write-Host "Requested Pages enablement. Allow a few minutes for deployment."
  } else {
    Write-Host "Could not parse owner/repo from URL: $RepoUrl"
    Write-Host "Enable Pages manually at: https://github.com/<owner>/<repo>/settings/pages"
  }
} else {
  Write-Host "GitHub CLI 'gh' not found. Open the repo settings to enable Pages:"
  Write-Host "https://github.com/$(($RepoUrl -replace 'https://github.com/',''))/settings/pages"
}

Write-Host "Done. Visit https://<your-username>.github.io/<repo-name>/ after a few minutes to confirm deployment."
