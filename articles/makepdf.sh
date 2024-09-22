#!/bin/bash -xe

echo "Create PDF..."
review-pdfmaker config.yml
echo "Create Gray-scaled PDF..."
bookname_base=$(yq '.bookname' ./config.yml)
gs -q -r600 -dNOPAUSE -sDEVICE=pdfwrite -o "$bookname_base"-GrayScale.pdf -dPDFSETTINGS=/prepress -dOverrideICC -sProcessColorModel=DeviceGray -sColorConversionStrategy=Gray -sColorConversionStrategyForImage=Gray -dGrayImageResolution=600 -dMonoImageResolution=600 -dColorImageResolution=600 "$bookname_base".pdf

echo "Create Ebook..."
review-pdfmaker config-ebook.yml
