#!/bin/bash
# Script to validate version consistency across files
# Usage: ./scripts/validate_version.sh

set -e

VERSION_FILE="VERSION"
MAIN_TF="main.tf"
CHANGELOG_FILE="CHANGELOG.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Version Consistency Validation ==="
echo ""

# Read version from VERSION file
if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}✗ VERSION file not found${NC}"
    exit 1
fi

VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
echo -e "VERSION file: ${GREEN}$VERSION${NC}"

# Validate semantic versioning format
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}✗ Invalid version format in VERSION file. Expected: X.Y.Z${NC}"
    exit 1
fi

# Check main.tf for version comment
if [ -f "$MAIN_TF" ]; then
    MAIN_VERSION=$(grep "# Module Version:" "$MAIN_TF" | sed 's/.*# Module Version: //' | tr -d '[:space:]')
    if [ -n "$MAIN_VERSION" ]; then
        if [ "$MAIN_VERSION" = "$VERSION" ]; then
            echo -e "main.tf:      ${GREEN}$MAIN_VERSION ✓${NC}"
        else
            echo -e "main.tf:      ${RED}$MAIN_VERSION ✗ (expected $VERSION)${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠ No version comment found in main.tf${NC}"
    fi
fi

# Check CHANGELOG for version entry
if [ -f "$CHANGELOG_FILE" ]; then
    if grep -q "\[${VERSION}\]" "$CHANGELOG_FILE"; then
        echo -e "CHANGELOG.md: ${GREEN}$VERSION ✓${NC}"
    else
        echo -e "CHANGELOG.md: ${YELLOW}⚠ Version $VERSION not found in changelog${NC}"
    fi
fi

# Check if version is tagged in git
if git rev-parse --git-dir > /dev/null 2>&1; then
    if git tag | grep -q "^v${VERSION}$"; then
        echo -e "Git tag:      ${GREEN}v$VERSION ✓${NC}"
    else
        echo -e "Git tag:      ${YELLOW}⚠ v$VERSION not found${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✓ Version validation complete${NC}"
