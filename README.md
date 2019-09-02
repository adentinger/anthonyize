# Anthonyize

Configure Linux/MSYS/Git Bash/Cygwin system according to my habits.

## Usage

```bash
./anthonyize
exec bash # Do in each open shell, or restart them.
```

## Privilege-escalation warning

Although you are likely to be using other projects that are privilege-escalation-prone, I do wish to personally warn that this project copies and creates files from this Git repo directly into `/etc` using elevated privileges and would have no restriction to read, modify or execute any file on the filesystem. 

Since, by default, cloning a repo creates the files as the normal user, malware or a remote shell would in theory have the ability to modify the files in the cloned directory before you have the time to run the `anthonyize` script, and thus perform privilege escalation, for example by adding inside one of the scripts of this repo a command that creates a new user and adds it to the sudoers.

Therefore, if you wish to run the anthonyzation script, I recommend you clone this repo as root user. However, this is just friendly advice ; the MIT LICENSE file states this repo comes with no guarantee :) .
