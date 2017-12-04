Artifact.sh
===========

A shell script to create an "artifact" out of a git clone, and commit the result to another git repository.  You would use this script if you have one repository (the "Source" repository) that excludes third party dependencies and generated assets, and another (the "Artifact" repository) that you want to commit those dependencies to for deployment purposes.

Installation:
-------------
cURL:
```bash
curl -O https://raw.githubusercontent.com/LastCallMedia/Artifact.sh/master/artifact.sh && chmod +x artifact.sh
```
Composer:
```bash
composer require lastcall/artifact.sh
```

Ignored Files
-------------
If you're using this script, you probably want to ignore different files between your source and artifact repositories.  To handle this, you can use `.artifact.gitignore` files at anywhere you would normally use a `.gitignore` file.  When the artifact is built, the `.artifact.gitignore` file will be respected.  `.gitignore` files are also respected, except if they are in the same directory as an `.artifact.gitignore` file.

For example, if you have the following directory structure:
```bash
README.txt
.artifact.gitignore # Empty file.
.gitignore # Ignores /vendor
src/
vendor/
```
The vendor directory would be excluded from your source repository due to the normal `.gitignore` file, but included in your artifact repository, because of the empty `.artifact.gitignore` file.

Options:
--------
* -h: Show help
*  -a: Set artifact git repository URL (required)
*  -b: Set downstream branch Defaults to current source repo branch.
*  -m: Set commit message.  Defaults to last source repo commit message.
*  -n: Dry run - display changes instead of committing and pushing.

Usage:
------
Export the current working directory as an artifact to `git://github.com/example/artifact.git`:

  ./artifact.sh -d git://github.com/example/artifact.git
  
