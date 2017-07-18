# Snort/NIDS Data Collection

## Introduction
This is a simple data collection project. I want to build a data pool to use during my Database Management class during this coming semester at college.

## Pictures
Because everybody likes to see what it looks like: [Pics of My Lab](http://imgur.com/a/v9huh).

## Technologies Employed
- Raspberry Pi 3 (running Raspbian)
- Snort NIDS (running on the Pi)
- PulledPork (to update Snort)
- GitHub (to house my files)
- Mikrotik RB3011UIAS-RM RouterBOARD (to segment my network)

## Primary Objective
Build a pool of data to use, manipulate, and visualize in CIS 260 Database Management, Johnson County Community College (Fall 2017).

This data pool consists of daily CSV files containing the following data from Snort alerts:
1. Timestamp
2. Protocol
3. Snort Alert Message
4. Source IP
5. Source Port
6. Destination IP
7. Destination Port

Through the use of a shell script, the following geolocation data items are added to the daily CSV file (attempting to reflect a geolocation for the source of the visit to my hackable LAN):
1. Country
2. State
3. City
4. Postal Code
5. Longitude
6. Latitude

## Secondary Objectives
- Learn more about segmenting a local area network through the installation and configuration of a router.
- Learn more about network intrusion and security threats.
- Learn more about Snort, a popular (and free) network intrusion detection system (NIDS).
- Do something practical and useful with my spare time this summer (there were no classes in my program of study available for me), with my Raspberry Pi I got for Christmas, with my knowledge of Linux (in the beginning... was the command line), and with all the old computer equipment I have lying around.
- I also got to play around a little bit with my structured cabling tools (crimpers, etc.).

## Scope
This projected is designed primarily for data collection.

The other technologies used to collect the desired data (the “honey pot,” Snort, etc.) were not utilized to their full capabilities. They were put in place to serve the primary objective of gathering simple information on the hits received on vulnerable machines.

The scope was limited because time was limited and learning curves are long. I wanted to accomplish the data collection and along the way learn some things (all during the two months or so I had free from studies at college).

## Process Description
1. Segment my home LAN with the MikroTik Router and isolate the vulnerable subnet.
2. Install and configure Raspbian on the Raspberty Pi 3.
3. Install and configure Snort and Pulled Pork on the Pi.
4. Set up a snortd daemon in /etc/init.d/ to run Snort as a service.
5. Set up a WinXP (SP4) maching running a “KittyCam” (open webcam).
6. Set up HoneyDrive3 (virtual machine inside Devuan Linux). 
7. Write a shell script to move the snort log and alert files (trivial).
8. Write a shell script to process the snort alert files (main script; less trivial).
9. Write a shell script to view the alert files in real time (trivial tweak of the main script).
10. Set up cron jobs on the Pi to move, process, copy, and backup my Snort alert and log files.
11. Setup a GitHub repository and sync with Git on the Pi (never used Git before).
12. Write a handful of simple Snort rules to flag hits on open ports.
13. Set up tmux to watch this thing in action from the command line. It's totally cool.

## References
1. Raspberry Pi Firewall and Intrusion Detection System by fNX in raspberry-pi
http://www.instructables.com/id/Raspberry-Pi-Firewall-and-Intrusion-Detection-Syst/

2. Installing Snort on Debian
https://www.upcloud.com/support/installing-snort-on-debian/

3. How To Configure Snort On Debian
https://www.vultr.com/docs/how-to-configure-snort-on-debian

4. Webcam Viewing Live Over the Internet Using A Dynamic IP Internet Service
http://hosteddocs.ittoolbox.com/rv100908b.pdf

5. Getting a Python script to run in the background (as a service) on boot
(I used this as a patter for my snortd daemon)
http://blog.scphillips.com/posts/2013/07/getting-a-python-script-to-run-in-the-background-as-a-service-on-boot/

6. HowTo: Add Jobs To cron Under Linux or UNIX?
https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/

7. A Quick and Easy Guide to tmux
http://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/

8. tmux shortcuts & cheatsheet
https://gist.github.com/MohamedAlaa/2961058
