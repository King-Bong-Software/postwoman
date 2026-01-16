#!/bin/bash

# PostWoman DMG Builder
# Creates a distributable DMG installer for PostWoman

set -e

# Configuration
APP_NAME="PostWoman"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
DMG_DIR="$BUILD_DIR/dmg"
OUTPUT_DIR="$PROJECT_DIR/dist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== PostWoman DMG Builder ===${NC}"
echo ""

# Parse arguments
VERSION=""
CONFIGURATION="Release"

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -d|--debug)
            CONFIGURATION="Debug"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -v, --version VERSION    Set version string (default: from git tag or 'dev')"
            echo "  -d, --debug              Build debug configuration instead of release"
            echo "  -h, --help               Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Get version from git if not specified
if [ -z "$VERSION" ]; then
    VERSION=$(git describe --tags --always 2>/dev/null || echo "dev")
fi

echo -e "Version: ${YELLOW}$VERSION${NC}"
echo -e "Configuration: ${YELLOW}$CONFIGURATION${NC}"
echo ""

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Build the app
echo -e "${YELLOW}Building $APP_NAME ($CONFIGURATION)...${NC}"
xcodebuild -project "$PROJECT_DIR/PostWoman.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$BUILD_DIR" \
    -destination 'platform=macOS' \
    build

# Find the built app
APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}Error: Could not find built app${NC}"
    exit 1
fi

echo -e "${GREEN}Found app at: $APP_PATH${NC}"

# Create DMG directory structure
echo -e "${YELLOW}Creating DMG contents...${NC}"
mkdir -p "$DMG_DIR"
cp -R "$APP_PATH" "$DMG_DIR/"

# Create Applications symlink for easy drag-and-drop installation
ln -s /Applications "$DMG_DIR/Applications"

# Create the DMG
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_PATH="$OUTPUT_DIR/$DMG_NAME"

echo -e "${YELLOW}Creating DMG: $DMG_NAME${NC}"
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

# Clean up
rm -rf "$DMG_DIR"

# Show results
echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"
echo -e "DMG created: ${YELLOW}$DMG_PATH${NC}"
echo ""

# Show DMG info
ls -lh "$DMG_PATH"

echo ""
echo -e "${GREEN}To install:${NC}"
echo "  1. Open the DMG file"
echo "  2. Drag PostWoman to the Applications folder"
echo "  3. Eject the DMG"
