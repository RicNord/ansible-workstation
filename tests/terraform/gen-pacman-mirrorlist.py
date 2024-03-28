#!/usr/bin/env python3
import argparse
import subprocess
import yaml


def main():
    COUNTRIES_LIST = "se,dk,no,de,nl"
    parser = argparse.ArgumentParser(
        description="Regenerate list of pacman mirror for Archlinux cloud-init file",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        epilog="Needed dependancy is PyYAML"
    )
    parser.add_argument(
        "-c",
        "--countries",
        type=str,
        help="String of comma separated country names or codes",
        default=COUNTRIES_LIST,
    )
    args = parser.parse_args()
    result = subprocess.run(
        [
            "reflector",
            "--delay",
            "3",
            "--country",
            args.countries,
            "--fastest",
            "10",
            "--sort",
            "rate",
            "--protocol",
            "https",
        ],
        capture_output=True,
        text=True,
        check=True,
    )

    with open("./cloud-init-arch.yaml", "r") as file:
        config = yaml.safe_load(file)
        config["write_files"][0]["content"] = result.stdout

    with open("./cloud-init-arch.yaml", "w") as file:
        file.write("#cloud-config\n")
        yaml.safe_dump(config, file, width=float("inf"))


if __name__ == "__main__":
    main()
