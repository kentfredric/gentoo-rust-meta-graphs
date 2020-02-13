pngtopam -verbose heirarchic.png |
  pamscale -verbose -xyfit 640 480 -filter sinc |
  pnmtojpeg -verbose -quality 85 -optimize -progressive -dct=float > heirarchic_thumb.jpg

pngtopam -verbose radial.png |
  pamscale -verbose -xyfit 640 480 -filter sinc |
  pnmtojpeg -verbose -quality 85 -optimize -progressive -dct=float > radial_thumb.jpg
