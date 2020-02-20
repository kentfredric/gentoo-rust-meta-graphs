for model in heirarchic radial; do
  for form in "" "_notest"; do
    printf "\e[32m* Scaling %s.png to %s_thumb.jpg ...\e[0m\n" "${model}${form}" "${model}${form}"
    pngtopam -verbose "${model}${form}".png |
      pamscale -verbose -xyfit 640 480 -filter sinc |
      pnmtojpeg -verbose -quality 85 -optimize -progressive -dct=float > "${model}${form}"_thumb.jpg
  done
done
