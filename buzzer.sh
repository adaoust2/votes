#!/bin/sh


if [ $# -ne 1 ]
then
	echo "usage : buzzer.sh duree_en_s"
	

else


sudo /home/pi/pilotes/wiringPi/gpio/gpio mode 0 out
sudo /home/pi/pilotes/wiringPi/gpio/gpio write 0 1
sleep $1
sudo /home/pi/pilotes/wiringPi/gpio/gpio write 0 0

fi


