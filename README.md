## Screen
### [Install screen firmware](https://learn.adafruit.com/adafruit-pitft-3-dot-5-touch-screen-for-raspberry-pi/easy-install)
Download the software

    wget http://adafru.it/pitftsh
    mv pitftsh pitft.sh
    chmod +x pitft.sh
Run it

    sudo ./pitft.sh -t 35r -r
Reboot the Pi

    sudo reboot

Everything should display on the Pi



### [Install video viewing software](https://learn.adafruit.com/adafruit-pitft-3-dot-5-touch-screen-for-raspberry-pi/displaying-images)
    sudo apt-get install fbi
View images with the following syntax

    sudo fbi -T 2 -d /dev/fb1 -noverbose -a adapiluv480x320.png
