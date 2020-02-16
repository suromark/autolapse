# autolapse
An automated octoprint timelapse generator

## Concept
- The script polls the Octoprint API via localhost.
- It reads both the toolhead status and the job status.
- It uses the job status to extract the job name and create a target directory for the timelapse images.
- It uses the toolhead status to decide when to be active: It takes a snapshot via curl every 4 seconds as long as the head is above 120 °C.
- If curl fails, it calls the script "/home/pi/recam.sh" which restarts the webcamd service.

## Motivation
- Octoprint's builtin timelapse stops at the end of the print file. Its post-roll option just appends the last picture, which usually is the print head still printing.
- By using the time delay of the print head cooling down, my script adds a generous amount of real post-roll pictures.

## Prerequisites
- A working Octoprint installation
- An API key for getting access, which you'll need to enter in the ma_autolapse.sh file instead of "YOUR-API-KEY" (two locations in the file)
- A webcam connected to the Pi, whose output is accessible as JPEG still picture

## Setup
- Add this start command to the /etc/rc.local file, above the final "exit 0" command:
- /home/pi/ma_autolapse.sh &
- Make sure that the script recam.sh runs without requiring the sudo password.

## Hints, notes
- Running the Raspberry off a USB SSD drive is highly recommended over using a microSD card, both for speed and durability.
- For best results, set the raspberry camera to fixed exposure and fixed white balance. This is accessible through the file /boot/octopi.txt
- My config line for the camera options reads like this:
- camera_raspi_options="-ev -2 -usestills -fps 2 -x 1920 -y 1080 -awb off --awbgainR 1.7 --awbgainB 1.5 -ex fixedfps -quality 50 -roi 0.2,0.2,0.6,0.6 "
  - "-ev 2" reduces the brightness. I have a black print bed, so the camera tends to overcompensate.
  - "-usestills" switches to still image mode. This improves picture quality over video mode (which compresses much stronger)
  - "-fps 2" reduces picture rate to 2 / second. Enough to see what's going on, less CPU required.
  - "-x 1920 -y 1080" use FullHD picture size
  - "-awb off --awbgainR 1.7 --awbgainB 1.5" locks the white balance. Green is always the reference at 1.0, Red and Blue are set to compensate the LED lighting I use.
  - "-ex fixedfps" sets the exposure mode.
  - "-quality 50" defines compression
  - "-roi 0.2,0.2,0.6,0.6" tells the camera to only use the center 60% of the sensor, with 20% offset to the left and top (basically zooming in a bit)
