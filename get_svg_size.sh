debugf() {
  true && return;
  local format=$1
  shift
  printf "\e[31m**\e[0m ${format}\n" "$@" >>/dev/stderr
}

svg_dims() {
  file="${1:?File name not specified}"
  if ! [[ -s "${file}" ]]; then
    printf "width=0\n"
    printf "height=0\n"
    printf "scale=100\n"
  else
    width="$(
      head -n 1 "${file}" |
      sed -r 's/^.* width="([0-9]+)".*/\1/'
    )"
    height="$(
      head -n 1 "${file}" |
        sed -r 's/^.* height="([0-9]+)".*/\1/'
    )"
    scale=$(( "${width}" * 100 / "${height}" ))
    printf "width=%s\n" "${width}"
    printf "height=%s\n" "${height}"
    printf "scale=%s\n" "${scale}"
  fi
}
box_fit() {
  local orig_x="${1:?Original X not specified}"
  local orig_y="${2:?Original Y not specified}"
  local lim_x="${3:?Limit X not specified}"
  local lim_y="${4:?Limit Y not specified}"
  if [[ "${orig_x}" -lt 1 ]] || [[ "${orig_y}" -lt 1 ]]; then
    printf "new_width=0\nnew_height=0\n"
    return
  fi
  local orig_aspect=$(( "${orig_x}" * 100 / "${orig_y}" ))
  local ratio_x=$(( "${orig_x}" * 1000 / "${lim_x}" ))
  local ratio_y=$(( "${orig_y}" * 1000 / "${lim_y}" ))
  debugf "box_fit: orig:   x: %s, y: %s" "${orig_x}" "${orig_y}"
  debugf "box_fit:    aspect: %s" "${orig_aspect}"
  debugf "box_fit: limits: x: %s, y: %s" "${lim_x}" "${lim_y}"
  debugf "box_fit: ratios: x: %s, y: %s" $(( "${ratio_x}" / 1000 ))  $(( "${ratio_y}" / 1000 ))

  # More ratio => larger amount of change to fit => scale by this onex
  local scale_ratio=1000
  if [[ "${ratio_x}" -lt "${ratio_y}" ]]; then
    debugf "box_fit: y_ratio is largest, scaling by y / height"
    scale_ratio="${ratio_y}"
  else
    debugf "box_fit: x_ratio is largest, scaling by x / width"
    scale_ratio="${ratio_x}"
  fi
  if [[ "${ratio_x}" -lt 1 && "${ratio_y}" -lt 1 ]]; then
    debugf "box_fit: null dimensions unhandled"
    printf "new_width=%s\n" "${orig_x}"
    printf "new_height=%s\n" "${orig_y}"
    return
  fi

  printf "new_width=%s\n" $(( "${orig_x}" * 1000 / ( "${scale_ratio}" ) ))
  printf "new_height=%s\n" $(( "${orig_y}" * 1000 / ( "${scale_ratio}" ) ))
}



print_pad() {
  file="${1:?File name not specified}"
  file_extd="${file}.svg"
  file_pad="${file_extd//?/ }"
  eval "$( svg_dims "${file_extd}" )"
  maxdim=5120
  eval "$( box_fit "${width}" "${height}" "${maxdim}" "${maxdim}" )"

  printf "\e[1;32m%s\e[0m: Dimensions: %sw x %sh\n" "${file_extd}" "${width}" "${height}"
  if [[ "$width" < "$height" ]]; then
    printf "%s  Scale by height: %s%%\n" "${file_pad}" "${scale}"
  else
    printf "%s  Scale by width: %s%%\n" "${file_pad}" "${scale}"
  fi
  printf "%s  New Size: %s x %s\n" "${file_pad}" "${new_width}" "${new_height}"
  eval "$( box_fit "${width}" "${height}" 640 480 )"
  printf "%s  Thumb Size: %s x %s\n" "${file_pad}" "${new_width}" "${new_height}"


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
