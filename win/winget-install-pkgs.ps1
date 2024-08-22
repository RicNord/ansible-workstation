winget install -e --id 7zip.7zip;
winget install -e --id Alacritty.Alacritty;
winget install -e --id BurntSushi.ripgrep.GNU;
winget install -e --id cURL.cURL;
winget install -e --id Docker.DockerDesktop;
winget install -e --id Git.Git;
winget install -e --id GitHub.cli;
winget install -e --id GnuPG.GnuPG;
winget install -e --id gokcehan.lf;
winget install -e --id Google.Chrome;
winget install -e --id junegunn.fzf;
winget install -e --id Microsoft.AzureCLI;
winget install -e --id Microsoft.Azure.StorageExplorer;
winget install -e --id Microsoft.GitCredentialManagerCore;
winget install -e --id Microsoft.PowerBI;
winget install -e --id Microsoft.PowerToys;
winget install -e --id Microsoft.RemoteDesktopClient;
winget install -e --id Microsoft.SQLServerManagementStudio;
winget install -e --id Microsoft.Teams;
winget install -e --id Microsoft.VisualStudioCode;
winget install -e --id Microsoft.WindowsTerminal;
winget install -e --id Mintty.WSLtty;
winget install -e --id Mozilla.Firefox;
winget install -e --id Neovim.Neovim.Nightly;
winget install -e --id qBittorrent.qBittorrent;
winget install -e --id RARLab.WinRAR;
winget install -e --id Spotify.Spotify;
winget install -e --id stedolan.jq;
winget install -e --id vim.vim;

# languages - might want to not have this on path is wsl is primary used
# check versions are not outdated, some dont have "latest"
winget install -e --id GoLang.Go.1.20;
winget install -e --id Hashicorp.Terraform;
winget install -e --id Microsoft.DotNet.SDK.7;
winget install -e --id ojdkbuild.openjdk.17.jdk;
winget install -e --id OpenJS.NodeJS.LTS;
winget install -e --id Python.Python.3.11;
winget install -e --id Rustlang.Rustup;

# Probably easier to use wsl downloader
winget install -e --id Canonical.Ubuntu.2204;
