
print_pad() {
file="${1:?File name not specified}"
file_extd="${file}.svg"
file_pad="${file_extd//?/ }"
width="$(
  head -n 1 "${file_extd}" |
  sed -r 's/^.* width="([0-9]+)".*/\1/'
)"
height="$(
  head -n 1 "${file_extd}" |
    sed -r 's/^.* height="([0-9]+)".*/\1/'
)"
scale=$(( "${width}" * 100 / "${height}" ))
maxdim=5120
printf "\e[1;32m%s\e[0m: Dimensions: %sw x %sh\n" "${file_extd}" "${width}" "${height}"
if [[ "$width" < "$height" ]]; then

  printf "%s  Scale by height: %s%%\n" "${file_pad}" $(( "$width" * 100 / "$height" ))
  printf "%s  New Size: %s x %s\n" "${file_pad}" "${maxdim}" $(( "$maxdim" * 100 / "$scale" ))
else
  printf "%s  Scale by width: %s%%\n" "${file_pad}" $(( "$width" * 100 / "$height" ))
  printf "%s  New Size: %s x %s\n" "${file_pad}" "${maxdim}" $(( "$maxdim" * 100 / "$scale" ))
fi
file "${file}.png"
file "${file}_thumb.jpg" | sed 's/JFIF standard 1.01, //;s/aspect ratio, //;s/density 1x1, //;s/segment length 16, //'
git diff --stat "${file}.png" "${file}.svg" "${file}_thumb.jpg" 
printf "\n\n\e[31;1m-\e[0m\n\n"

}

for model in heirarchic radial; do
  for form in "" "_notest"; do
    print_pad "${model}${form}"
  done
done
