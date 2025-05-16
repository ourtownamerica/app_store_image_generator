#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <width> <height> <screenshot_file> <text> <outfile>"
  exit 1
fi

WIDTH=$1
HEIGHT=$2
TEXT=$4
OUTFILE=$5
SCREENSHOTFILE=$3
BORDER_IMAGE="bottom.png"
COLOR="#F3F8C6"
COLOR2="#066251"
BORDER_HEIGHT=$(( HEIGHT / 10 ))
BORDER_GRADIENT_HEIGHT=$(( BORDER_HEIGHT / 2 ))
MAX_SCREENSHOT_WIDTH=$(( WIDTH * 90 / 100 ))
MAX_SCREENSHOT_HEIGHT=$(( HEIGHT * 75 / 100 ))
BOTTOM_POS=$(( HEIGHT / 12 ))
TEXT_WIDTH=$(echo "$WIDTH * 85 / 100" | bc)
FONT_WIDTH=$(echo "$TEXT_WIDTH / 10" | bc)
FONT_FILE="fonts/LTMuseum-Black.ttf"

# Create text image
TMP_TEXT_IMG="tmp_text_img.png"
convert -background none \
        -fill "$COLOR" \
        -font "$FONT_FILE" \
        -pointsize "$FONT_WIDTH" \
        -size "${TEXT_WIDTH}x" \
        -gravity center \
        caption:"$TEXT" \
        "$TMP_TEXT_IMG"

# Create a resized version of the border (preserving aspect ratio)
TMP_BORDER_RESIZED="tmp_border_resized.png"
convert "$BORDER_IMAGE" -resize x${BORDER_HEIGHT} "$TMP_BORDER_RESIZED"

# Tile the resized border to the full width of the base image
TMP_BORDER_TILED="tmp_border_tiled.png"
convert -size "${WIDTH}x${BORDER_HEIGHT}" tile:"$TMP_BORDER_RESIZED" "$TMP_BORDER_TILED"

# Generate the background image
convert -size "${WIDTH}x${HEIGHT}" "xc:${COLOR2}" "$OUTFILE"

# Generate the vertical gradient
TMP_GRADIENT_FILE="tmp_gradient_file.png"
convert -size ${WIDTH}x${BORDER_GRADIENT_HEIGHT} gradient:"$COLOR2"-"$COLOR1" "$TMP_GRADIENT_FILE"

# Composite vertical gradient onto the base image
composite -gravity south "$TMP_GRADIENT_FILE" "$OUTFILE" "$OUTFILE"

# Composite the tiled border onto the base image, aligned at the bottom
composite -gravity south "$TMP_BORDER_TILED" "$OUTFILE" "$OUTFILE"

# Resize overlay image to fit within constraints while preserving aspect ratio
RESIZED_OVERLAY="tmp_overlay_resized.png"
convert "$SCREENSHOTFILE" -resize "${MAX_SCREENSHOT_WIDTH}x${MAX_SCREENSHOT_HEIGHT}" "$RESIZED_OVERLAY"

# Composite resized overlay onto center of background
OVERLAY_WIDTH=$(identify -format "%w" "$RESIZED_OVERLAY")
OVERLAY_HEIGHT=$(identify -format "%h" "$RESIZED_OVERLAY")
OFFSET_X=$(( (WIDTH - OVERLAY_WIDTH) / 2 ))
OFFSET_Y=$(( HEIGHT - OVERLAY_HEIGHT - BOTTOM_POS ))
composite -geometry +${OFFSET_X}+${OFFSET_Y} "$RESIZED_OVERLAY" "$OUTFILE" "$OUTFILE"

# Place the text 5% from the top
TEXT_OVERLAY_WIDTH=$(identify -format "%w" "$TMP_TEXT_IMG")
TEXT_OFFSET_X=$(( (WIDTH - TEXT_OVERLAY_WIDTH) / 2 ))
TEXT_OFFSET_Y=$(echo "$HEIGHT * 0.05" | bc | awk '{printf "%d", $0}')
echo "$TEXT_OFFSET_Y" "$TEXT_OFFSET_X" "$TEXT_OVERLAY_WIDTH"
composite -geometry +${TEXT_OFFSET_X}+${TEXT_OFFSET_Y} "$TMP_TEXT_IMG" "$OUTFILE" "$OUTFILE"

# Clean up
rm "$TMP_BORDER_RESIZED" "$TMP_BORDER_TILED" "$TMP_GRADIENT_FILE" "$RESIZED_OVERLAY" "$TMP_TEXT_IMG"

echo "Image created: $OUTFILE"
