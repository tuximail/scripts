####cat all the things
# Dependencies: imagemagick, odt2txt
#
# Script is still under development
#
##############################)

for file in $@; do
    case $(file --mime-type -b "$file") in
        image/*)
        #get height and with
        #size=$(identify "$file" | grep -oP '\d+x\d+(?=\+)')
        #heigth=$( echo "$size" | cut -dx -f1)
        #width=$( echo "$size" | cut -dx -f2)
        img2txt -W 70 "$file" #using static 70 width for now as most original sizes of pictures are too large
        ;;
        application/pdf)
        pdftotext "$file" /tmp/pdf.txt
        cat /tmp/pdf.txt
        ;;
        application/vnd.oasis.opendocument.*)
        odt2txt "$file"
        ;;
        *)
        bat "$file"
        ;;
    esac
done
