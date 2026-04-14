---
editor: visual
---

This repository contains a small research project written in R and Quarto. The repository will be used as a demonstration repository for the *Using Version Control for Data Analysis through GitHub* course by [Statistical Horizons](https://statisticalhorizons.com/). The project uses fake, but realistic, data to look at wage differences between men and women in the US by educational level.

## Pre-Course Preparation

All participants should complete the following activities prior to the beginning of the course. All software that you need to install is free.

1.  Install [git](https://git-scm.com/downloads) on your operating system. Git should work on all major platforms but currently there are some complications with MacOS systems that you should read about below. The installation procedure may ask you a few questions during installation. In all cases, use the default settings.
2.  If you do not have a [GitHub](https://github.com/) account, please create one. GitHub accounts are free.
3.  Star this repository on GitHub so that you can find it easily. The star button is in the upper right-hand corner.
4.  Download and install [GitHub Desktop](https://desktop.github.com/) for your operating system. Then run the application and go to Preferences \> Accounts. From there, connect GitHub Desktop to your GitHub account.
5.  Complete this [brief online survey](https://www.surveymonkey.com/r/HYKDR2N).

In order to run all of the code in this repository, participants should ensure they have [R](https://www.r-project.org/) and [quarto](https://quarto.org/docs/get-started/) installed. However, our focus will be on version control of the code rather than executing the code, so this step is not required to participate in the course.

It is **not** necessary to fork or clone this repository prior to the course.

## Installing git on MacOS

There is no longer a binary installer for git on MacOS, but there are still several ways to install git on MacOS. The two best options for this are:

1.  Install [Xcode](https://developer.apple.com/xcode/) which comes with git pre-installed. Xcode is a package full of developer-oriented stuff for Mac developers. This is straightforward but Xcode will also install a lot of other stuff and the download will be quite large.
2.  Use [homebrew](https://brew.sh/) to install git. This is the geeky solution and will require you to:
    1.  Install homebrew. You can do this from the command line following the instructions on the homepage or your you can download the [latest package installer](https://github.com/Homebrew/brew/releases).
    2.  On your Mac, open a Terminal window (found in Applications/Utilities) and type in `brew install git`. This will install git on your system.
