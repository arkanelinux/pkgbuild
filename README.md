# Arkane Linux PKGBUILD files
This repo contains the PKGBUILD files for all packages available in the [Arkane software repositories](https://repo.arkanelinux.org/arkane).

## Building packages and adding them to the database
### 1. Pull the repository
```
git clone https://github.com/arkanelinux/pkgbuild.git
```
### 2. Build the package
It is a good habit to always inspect the PKGBUILd files, irrelevant of the source. It takes just a few minutes and can save you from your system getting rm -rf-ed.
```
cd pkgbuild/os-installer
makepkg
```
### 3. Add the package to the database
```
cd ..
repo-add arkane.db.tar.zst ./os-installer/os-installer-1.0-1-x86_64.pkg.tar.zst
```

## Scripts
| Script				| Description																																																						|
| -------------	| ---------------------------------------------------------------------------------------------------------------------	|
| push_all.sh		| Pushes all packages to the repository, useless for everyone other than those with access to the repository server.		|
| clear_old.sh	| Removes the arkane.db.old files created after updating the database.																									|

## Development
Contributions, in any form, be it code or ideas are always welcome!
### Getting started
Refer to the ArchWiki page on [PKGBUILD](https://wiki.archlinux.org/title/PKGBUILD) for information. For reference material check the PKGBUILD files included in this repository or the [AUR](https://aur.archlinux.org/).

### Software sources
Always use the original developer's primary repository or mirror as a software source.

### Software versions
Always use stable point releases. Git versions should be avoided with rare exceptions.

### Binaries
Avoid binaries if possible, preferably always build the software from source.

### Including source code inside of this repository
Only tiny scripts or configuration files should be added in `package_name/src`, large pieces of software should pull their code or binaries from external sources.
