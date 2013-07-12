# Server VM Use Instructions

This document contains step-by-step instructors for using a prebuilt VM that
matches the NetChat production environment.


## Setup

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Most
Linux distributions have VirtualBox available in their package repositories.

2. Install sshfs. Many Linux distributions have it installed by default, and
most distributions have it in their package repositories. On OSX, install the
two packages on the [FUSE for OSX page](http://osxfuse.github.com/).

3. Download and decompress
   [the server VM image](http://people.csail.mit.edu/costan/netchat/netchat-server-vm.7z)

  * On OSX, a 7z decompression utility is needed, such as
    [Keka](http://www.kekaosx.com/)

4. Add the VM to VirtualBox. (Machine > Add in the VirtualBox menu)

5. Start the VM and wait for it to boot up.

6. Create an SSH key, if you don't have one.

    ```bash
    ssh-keygen -t rsa
    # press Enter all the way (default key type, no passphrase)
    ```

7. [Upload your SSH key to the Git hosting site](https://github.com/settings/ssh).

8. Set up public key SSH login and verify that it works.

    ```bash
    ssh-copy-id netchat@netchat.local
    ssh netchat@netchat.local
    # ssh should not ask for a password.
   ```

9. Personalize SSH, so you can make commits on the server.

    ```bash
    # ssh netchat@netchat.local
    git config --global user.name "Your Name"
    git config --global user.email your_name@mit.edu
    ```

10. Update the server software.

    ```bash
    # ssh netchat@netchat.local
    ~/vm/script/update.sh
    ```

## General Use

For ease of development, the `netchat` home directory on the server VM should be
mounted over SSHFS. This makes the source code available to all the local
software, such as Photoshop.

```bash
mkdir netchat-vm
sshfs netchat@netchat.local: netchat-vm
```

The game server can be accessed at [http://netchat.local/](http://netchat.local/)

The metrics server can be accessed at
[http://netchat.local:8080/](http://netchat.local:8080/)


### Game Server Development

The game server repository is cloned in the `game` directory inside the
`netchat` user's home directory.

When working on the game server, it is convenient to kill the daemonized server
and start a server from the command line.


    ```bash
    # ssh netchat@netchat.local
    sudo /etc/init.d/netchat-game stop
    cd ~/game
    foreman start
    ```

### Metrics Server Development

The metrics server repository is cloned in the `metrics` directory inside the
`netchat` user's home directory.

When working on the metrics server, it is convenient to kill the daemonized
server and start a server from the command line.


    ```bash
    # ssh netchat@netchat.local
    sudo /etc/init.d/netchat-metrics stop
    cd ~/metrics
    foreman start
    ```
