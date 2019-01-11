#!/bin/bash

# General options:
tmpdir='tmp'
compress=false

# Files to generate pdfs for:
poster="Berlin-2019_mrakitin"

# Create a temp dir if it does not exist:
if [ ! -d "$tmpdir" ]; then
    mkdir $tmpdir
else
    rm -f $tmpdir/*
fi

# LaTeX options:
outdir="-output-directory=$tmpdir"
nonstop="-interaction=nonstopmode"

# GhostScript parameters:
gs="gs"  # "gs" on Mac
compatibility="1.4"
quality="printer"

for b in $poster; do
    texfile="${b}.tex"
    auxfile="${b}.aux"
    bblfile="${b}.bbl"
    pdffile="${b}.pdf"
    finalpdf="${b}.pdf"
    compressedpdf="${b}_comp.pdf"

    # Sequence of LaTeX commands from https://tex.stackexchange.com/a/13012.
    latex $nonstop $outdir $texfile
    bibtex ${tmpdir}/${auxfile}
    latex $nonstop $outdir $texfile
    pdflatex -synctex=1 --src-specials $nonstop $outdir $texfile

    # Copy the resulted file from the temp dir:
    cp -fv ${tmpdir}/${pdffile} $finalpdf

    # Compress the file:
    if [ $compress == true ]; then
        $gs -sDEVICE=pdfwrite -dCompatibilityLevel=$compatibility -dPDFSETTINGS=/$quality -dNOPAUSE -dQUIET -dBATCH -q -sOutputFile=$compressedpdf $finalpdf
        mv -fv $compressedpdf $finalpdf
    fi
done

