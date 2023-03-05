# Ubuntu dependencies
## apt
- git
- python3-pip
- python3-virtualenv

# Arch dependencies
## pacman
- git
- python
- python-pip

# Execute on remote host
On remote system install `openssh-server` on Ubnuntu `openssh` on Arch.
Arch (unlike Ubuntu) does not enable the `sshd` daemon by default, run:
```bash
sudo systemctl start sshd
```

Arch config file located at `/etc/ssh/sshd_config`
Ubuntu config file located at `/etc/ssh/ssh_config`

For ubuntu you may want to disble the server, run:
```bash
sudo systemctl disable --now ssh
```

# ssh key to github (If repo private)
```shell
ssh-keygen -t ed25519
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```
upload key to github

# pip
```shell
pip install virtualenv
virtualenv venv
source venv/bin/activate
```

