RED=$(tput setaf 1)
NORM=$(tput sgr0)
i3status | while true;
do
	 read line
	 caps=$(xset q | grep -E -o -e "[0-9]{8}")
	 if [[ "$caps" == "00000001" ]]; then
		 dat="(***) Caps Lock (***)"
		 col=",\"color\":\"FF0000\""
	 else
	 	dat=""
	 fi
	 dat="[{ \"full_text\": \"${dat}\" $col},"
	 echo "${line/[/$dat}" || exit 1
done
