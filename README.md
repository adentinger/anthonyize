# Anthonyize
Configure Linux system according to my habits.

## Privilege-escalation warning

Although you are likely to be using other projects that are privilege-escalation-prone, I do wish to personally warn that this project copies and creates files from this Git repo directly into `/etc` and would have no restriction to read, modify or execute any file on the filesystem. 

Since, by default, cloning is done as the normal user, malware or a remote shell would in theory have the ability to modify the files in the cloned directory before you have the time to run the `anthonyize` script, and thus perform privilege escalation.

Therefore, if you wish to run the anthonyzation script, I recommend you clone this repo as root user. However, this is just friendly advice ; the MIT LICENSE file states this repo comes with no guarantee.
