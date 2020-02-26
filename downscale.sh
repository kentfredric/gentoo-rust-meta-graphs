mk_thumbnail() {
  local base="${1}"
  local source="${1}.png"
  local target="${2:-${1}_thumb.jpg}"

  printf "\e[32m* Scaling %s to %s ...\e[0m\n" "${source}" "${target}"
  pngtopam -verbose "${source}" |
    pamscale -verbose -xyfit 640 480 -filter sinc |
    pnmtojpeg -verbose -quality 85 -optimize -progressive -dct=float > "${target}"
  printf "\e[32m* Done %s -> %s [^_^]\e[0m\n" "${source}" "${target}"
}


for model in heirarchic radial; do
  for form in "" "_notest"; do
    mk_thumbnail "${model}${form}" &
   done
done
wait
