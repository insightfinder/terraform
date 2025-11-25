#!/bin/bash
# Script to update module version and changelog
# Usage: ./scripts/update_version.sh [major|minor|patch] "changelog message"

set -e

VERSION_FILE="VERSION"
CHANGELOG_FILE="CHANGELOG.md"
MAIN_TF="main.tf"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 [major|minor|patch] \"changelog message\""
    echo ""
    echo "Examples:"
    echo "  $0 major \"Breaking API changes\""
    echo "  $0 minor \"New ServiceNow integration feature\""
    echo "  $0 patch \"Bug fix for authentication\""
    exit 1
}

# Check arguments
if [ $# -ne 2 ]; then
    usage
fi

BUMP_TYPE=$1
CHANGE_MESSAGE=$2

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}Error: Invalid version bump type. Must be major, minor, or patch${NC}"
    usage
fi

# Read current version
if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}Error: VERSION file not found${NC}"
    exit 1
fi

CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
echo -e "${YELLOW}Current version: $CURRENT_VERSION${NC}"

# Parse version components
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Bump version based on type
case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo -e "${GREEN}New version: $NEW_VERSION${NC}"

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Update VERSION file
echo "$NEW_VERSION" > "$VERSION_FILE"
echo -e "${GREEN}✓ Updated VERSION file${NC}"

# Update main.tf version comment
if [ -f "$MAIN_TF" ]; then
    sed -i "s/# Module Version: .*/# Module Version: $NEW_VERSION/" "$MAIN_TF"
    echo -e "${GREEN}✓ Updated main.tf version comment${NC}"
fi

# Update CHANGELOG
if [ -f "$CHANGELOG_FILE" ]; then
    # Create temporary file
    TEMP_FILE=$(mktemp)
    
    # Read the changelog and insert new version
    awk -v version="$NEW_VERSION" -v date="$CURRENT_DATE" -v msg="$CHANGE_MESSAGE" '
    /^## \[Unreleased\]/ {
        print $0
        print ""
        print "## [" version "] - " date
        print ""
        print "### Changed"
        print "- " msg
        print ""
        next
    }
    { print }
    ' "$CHANGELOG_FILE" > "$TEMP_FILE"
    
    # Replace original file
    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo -e "${GREEN}✓ Updated CHANGELOG.md${NC}"
else
    echo -e "${YELLOW}Warning: CHANGELOG.md not found${NC}"
fi

# Git operations (if in a git repository)
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo ""
    echo -e "${YELLOW}Git repository detected. Creating commit and tag...${NC}"
    
    # Add files
    git add "$VERSION_FILE" "$CHANGELOG_FILE" "$MAIN_TF"
    
    # Commit
    git commit -m "chore: bump version to $NEW_VERSION

$CHANGE_MESSAGE"
    
    # Create tag
    git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION

$CHANGE_MESSAGE"
    
    echo -e "${GREEN}✓ Created git commit and tag v$NEW_VERSION${NC}"
    echo ""
    echo -e "${YELLOW}To push changes:${NC}"
    echo "  git push origin $(git branch --show-current)"
    echo "  git push origin v$NEW_VERSION"
else
    echo -e "${YELLOW}Not in a git repository. Skipping git operations.${NC}"
fi

echo ""
echo -e "${GREEN}Version update complete!${NC}"
echo -e "Version: ${GREEN}$CURRENT_VERSION${NC} → ${GREEN}$NEW_VERSION${NC}"
