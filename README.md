# dskencupsky
# Simple Script for Upload Entire Encrypted Disk to SiaSky.Net Service
# This script was tested only on Linux Ubuntu 20 but the concept should be easy for transfer to other platforms. 

First of all:
Neither the SiaSky.net Partners nor the SIA Foundation have had any involvement in the development of this proof of concept and under no circumstances are there any guarantees of performance now or in the future, so please consider yourself a developer if you use this script and please do so with extreme caution, as you may incur loss of data. 

About SiaSky.Net:
SiaSky.Net is The decentralized CDN and file sharing platform for devs. Skynet is the storage foundation for a Free Internet!. 

Why this POC? Unlike Siac, the SiaSky Web Service does not encrypt documents uploaded to SiaSky, so anyone who knows the link it generates could access the data.  With the assurance that your data is encrypted at source, you need not worry about uploading it to SiaSky. Not Wallet or SiaCoins Requiered for upload unlimited data.

The main reason for thinking about the realization of this proof of concept, has been nothing more than trying to generate interest in Sia's technology that I consider is very good, and create something of Mass Adoption by Internet users through a simple script easy to read and interpret and therefore to customize, with the aim that users can create local encrypted disks on your computer, fill them with information and upload them safely and free to the Sia Network, and then retrieve it only keeping the link file and of course the encryption password. All this, without requiring the installation of a Wallet or the purchase of Siacoins by the user. 

Many thanks for the courtesy of all the partners who maintain the SiaSky.net storage, without them, this test would not have been possible.

# Proof of concept to have a Backup of a complete Encrypted Disk in SiaSky.net
This script uses the most simple cryptsetup LUKS encryption configuration. Of course, you can improve this script for your security requeriments.

1. Edit the script and configure this variables:
DSKENCNAME="encryptedDisk" --> The name of encrypted volume name under /dev/mapper
DSKPATH="/mnt" --> Folder under the script will work with the data
BCHFILESIZE="500MB" --> Splitted size limit. Not is recomendable more than 1GB for SiaSky size file size restrictions.
DSKENCSIZE="30000M" --> Desired size of your Encrypted Volume in M (30GB) in our example. Important to know the available space: If you make a Disk of 30GB you will need x2 of Freespace in DSKPATH. This could be improve easly but since is a POC not was for me a priority.

2. Initialising
Run ./dskencupsky -i
 - Install cryptsetup if not installed
 - Create a file called /mnt/encryptedDisk.iso with 30GB
 - Initialises the disk as LUKS format
 - Format the disk as ext4
 - Open Luks and Mount
 
Initialiting Encryption DiskFile /mnt/encryptedDisk
Prerequisite cryptsetup to Encrypt new volume disk
Reading package lists... Done
Building dependency tree       
Reading state information... Done
cryptsetup is already the newest version (2:2.2.2-3ubuntu2.3).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Creating main file encryptedDisk.iso with 30000M
Initialiting encryptedDisk... (Reply YES in Uppercase) And Your Secret Phrasse!

WARNING!
========
This will overwrite data on /mnt/encryptedDisk.iso irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase for /mnt/encryptedDisk.iso: (ENTER YOUR SECURITY PHRASSE HERE)
Verify passphrase: (REPEAT YOUR SECURITY PHRASSE HERE)
Openning encryptedDisk ... Write your Phrasse bellow
Enter passphrase for /mnt/encryptedDisk.iso: (ENTER YOUR PHRASSE AGAIN TO OPEN DISK)
Formating /dev/mapper/encryptedDisk
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 7675904 4k blocks and 1921360 inodes
Filesystem UUID: 0b6f14ba-dff6-425e-b7fb-1e77729b2fbf
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done   

Mounting /mnt/encryptedDisk
Congratulations your Device /mnt/encryptedDisk is ready for write data!

#df -Th
#/dev/mapper/encryptedDisk ext4       29G   45M   28G   1% /mnt/encryptedDisk

3. Coping data in to encrypted disk
After the Disk is mounted, you can access as a simple folder and store data. In my POC I used a complete synced Siad Blockchain with Sia 1.5.4
(I have chosen a blockchain database because of its high sensitivity to any changes.And this is very important to later check 100% that no data has been altered after the process.)

total 64
drwxr-xr-x 13 root root  4096 Feb  9 21:15 .
drwxr-xr-x  5 root root  4096 Feb  9 07:38 ..
drwxr-xr-x  3 root root  4096 Feb  7 22:03 bin
drwxr-xr-x  2 root root  4096 Feb  7 22:03 consensus
drwxr-xr-x  2 root root  4096 Feb  7 22:03 feemanager
drwx------  2 root root  4096 Feb  7 22:05 gateway
drwx------  3 root root  4096 Feb  7 22:05 host
drwx------  2 root root 16384 Feb  7 21:14 lost+found
drwx------  4 root root  4096 Feb  7 22:55 renter
drwx------  2 root root  4096 Feb  7 22:03 siamux
drwxr-xr-x  2 root root  4096 Feb  7 22:03 transactionpool
drwxr-xr-x  2 root root  4096 Feb  7 22:39 upload
drwx------  2 root root  4096 Feb  7 22:03 wallet

#df -Th
#/dev/mapper/encryptedDisk ext4       29G   27G  1.2G  96% /mnt/encryptedDisk

4. Close Disk and Upload to SiaSky.net
Run ./dskencupsky -u

Unmounting /mnt/encryptedDisk
split /mnt/encryptedDisk.iso /mnt/split/ --bytes=500MB
Deleting older /mnt/files_uploaded.siasky
Uploading Data to SiaSky.net. Please be patient, the timeline depends of your internet connection and the amount of data and SiaSky.net service
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  5  476M    0     0    5 24.5M      0  3981k  0:02:02  0:00:06  0:01:56 1014k

(In my case, about 4 hours to upload 30GB)
After end the upload, please check if all was uploaded without errors. Some times a got 504 error from SiaSky.net 

Very important: Save this file /mnt/files_uploaded.siasky in a safe storage for download and rebuild your data. 

5. Download and Rebuild your Disk in other machine

First, copy files_uploaded.siasky under DSKPATH (in my example: /mnt)

Run ./dskencupsky -d

Removing older downloaded folder /mnt/download and /mnt/encryptedDisk.iso volume
Downloading files from SiaSky using /mnt/files_uploaded.siasky...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  476M  100  476M    0     0  27.4M      0  0:00:17  0:00:17 --:--:-- 36.8M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  476M  100  476M    0     0  16.5M      0  0:00:28  0:00:28 --:--:-- 29.5M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  476M  100  476M    0     0  6400k      0  0:01:16  0:01:16 --:--:-- 16.5M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current

After a 1 hour, I downloaded and rebuild my encryptedDisk in other host:

#df -Th
#/dev/mapper/encryptedDisk ext4       29G   27G  1.2G  96% /mnt/encryptedDisk

And I can run my complete Sia Blockchain without lost data:
#/mnt/encryptedDisk/bin/siac consensus

Synced: Yes
Block:      0000000000000001ebab3997ba5e4f9993c6e11da66b94f39009ac09210d3177
Height:     298937
Target:     [0 0 0 0 0 0 0 2 88 216 14 230 38 21 177 67 155 88 7 254 31 146 163 160 204 92 201 30 74 234 67 17]
Difficulty: 7859555327105616720


