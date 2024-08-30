# Python Template

Template to create your python project.

## Customization

* To use the template you will need to update the naming to match the one of your project:
  * Find all instances of `myenv` and replace them with the name of your project/repo.
  * Replace `my_package` with the name of your package.
* In `setup.sh` set the python version to the desired one.
* In `pyproject.toml` update the list of desired dependencies under `[tool.poetry.dependencies]`.

## Install

To install python and create the virtual env run `make setup`. The process is the same whether you are on Linux or Mac.

If it is the first time the script will install `conda`. The installation requires your input:
* Approve the license by entering `yes`
* Set the install location to the default path (just press ENTER)
* When asked "Do you wish to update your shell profile to automatically initialize conda?": NO
After these steps the script will continue installing `poetry`. It will prompt few times

Next step is to install the `my_package` modules and dependencies. This can be done by running
```bash
make install
```

The first time you install it it will create the Conda environment file with the list of dependencies that has been installed (you can think of this file as poetry.lock). You should commit the file into your repo so next person to install will be guaranteed your same versions of the environment dependencies.

The file name has the format `environement-[Linux, MacOSX]-<arch>-<conda version>-<poetry version>.yml`.


### Add new python package dependency.

Add a new entry in `pyproject.toml` under `[tool.poetry.dependencies]`.

If you don't care about the version and want the latest set the version to `= "*"` otherwise you can specify an exact version, `= "1.3.1"` or a minimum one `>= "1.4.2"`.

After that run `make lock` to compute the new dependency graph and then `make install` to install them.


### Update python packages versions.

To update packages version you can run `make lock`.

This will update the `poetry.lock` file. Once the command has terminated re-run `make install`.

## Run
To run your python code you first need to activate the environment. Running `make activate` will tell you which command to run.
> NOTE: Makefile run in a separate shell so it's not possible to activate it from within make.

Add your script to `[tool.poetry.scripts]` in `pyproject.toml`.
```bash
poetry run example
```

## Tools

The repo comes with a set of tools for code quality, please have a look at the `Makefile` file for a list of available command.
