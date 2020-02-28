# Anthonyize

Configure Linux/MSYS/Git Bash/Cygwin system according to my habits.

## Usage

```bash
./anthonyize
exec bash # Do in each open shell, or restart them.
```

## Modifying to one's habits

One could use this repo as a base for their own system customizer. Here are some important files that can be modified easily.

### `scripts/cli-setup-bashrc`

Appends code to the system-wide `bashrc`, no matter what exactly it is named.

This is where we call the other scripts, and where we configure the prompt color.

### `config/etc/bash.bash_aliases`

To place your favorite aliases.

Autocompletion of aliases works perfectly under Linux systems that have the `bash-completion` (name may vary depending on distro and version) package installed. For systems that don't have it (e.g. Git Bash, sigh), only aliases that consist of a program name (e.g., `alias g='git'`) have autocomplete. So `alias l='ls -A --color=auto'` would not. Not that it couldn't be done, though.

### `scripts/commands`

To configure programs and commands to your taste.

I like having git aliases configured, for example.

### `scripts/fs`

To tweak directories, files, etc.

I don't do much here ; I only create `~/Desktop` and `~/Git` if they don't exist.

## Privilege-escalation warning

Although you are likely to be using other projects that are privilege-escalation-prone, I do wish to personally warn that this project copies and creates files from this Git repo directly into `/etc` using elevated privileges and would have no restriction to read, modify or execute any file on the filesystem. 

Since, by default, cloning a repo creates the files as the normal user, malware or a remote shell would in theory have the ability to modify the files in the cloned directory before you have the time to run the `anthonyize` script, and thus perform privilege escalation, for example by adding inside one of the scripts of this repo a command that creates a new user and adds it to the sudoers.

Therefore, if you wish to run the anthonyzation script, I recommend you clone this repo as root user. However, this is just friendly advice ; the MIT LICENSE file states this repo comes with no guarantee :) .
