#!/bin/bash -xe

echo "Create PDF..."
review-pdfmaker config.yml
echo "Create Gray-scaled PDF..."
gs -q -r600 -dNOPAUSE -sDEVICE=pdfwrite -o MkDocs-Book-GrayScale.pdf -dPDFSETTINGS=/prepress -dOverrideICC -sProcessColorModel=DeviceGray -sColorConversionStrategy=Gray -sColorConversionStrategyForImage=Gray -dGrayImageResolution=600 -dMonoImageResolution=600 -dColorImageResolution=600 MkDocs-Book.pdf 

echo "Create Ebook..."
review-pdfmaker config-ebook.yml
