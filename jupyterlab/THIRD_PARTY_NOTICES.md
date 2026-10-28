# Third-party notices

This image is an aggregate of independently licensed software. The MIT license
in the repository root covers the original Omicslab code in this repository. It
does **not** relicense the third-party components listed below, and the image as
a whole is not "MIT-only".

License texts shipped in the image are under
`/usr/share/doc/studio-collection/LICENSES/`.

## Base image

| Component | License | Source |
| --- | --- | --- |
| Ubuntu 26.04 | mixed GPL/LGPL/permissive | <https://launchpad.net/ubuntu> |

Ubuntu package copyrights are under `/usr/share/doc/<package>/copyright` and
`/usr/share/common-licenses/`.

## Installed by this repository

| Component | Version | License | Source |
| --- | --- | --- | --- |
| Pixi | 0.83.0 | BSD-3-Clause | <https://github.com/prefix-dev/pixi> |
| JupyterLab | 4.6.4 | BSD-3-Clause | <https://github.com/jupyterlab/jupyterlab> |
| Python (Pixi) | 3.13 | PSF-2.0 | <https://github.com/conda-forge/python-feedstock> |
| ipykernel | conda-forge | BSD-3-Clause | <https://github.com/ipython/ipykernel> |
| R (Pixi) | 4.5.3 | GPL-2.0 / GPL-3.0 | <https://github.com/conda-forge/r-base-feedstock> |
| IRkernel | conda-forge | MIT | <https://github.com/IRkernel/IRkernel> |
| Oh My Zsh | master at build time | MIT | <https://github.com/ohmyzsh/ohmyzsh> |
| zsh-autosuggestions | master at build time | MIT | <https://github.com/zsh-users/zsh-autosuggestions> |
| zsh-syntax-highlighting | master at build time | BSD-3-Clause | <https://github.com/zsh-users/zsh-syntax-highlighting> |

License texts:

- `LICENSES/BSD-3-Clause-jupyterlab.txt`
- `LICENSES/PSF-Python.txt`
- `LICENSES/GPL-2.0-R.txt`
- `LICENSES/BSD-3-Clause-pixi.txt`
- `LICENSES/MIT-oh-my-zsh.txt`
- `LICENSES/MIT-zsh-autosuggestions.txt`
- `LICENSES/BSD-3-Clause-zsh-syntax-highlighting.txt`

JupyterLab, Python, and R are installed from conda-forge into Pixi
environments. Other conda-forge packages in those environments keep their own
licenses; see the package metadata in
`/opt/jupyter/.pixi/envs/default/conda-meta/` and
`/opt/r-kernel/.pixi/envs/default/conda-meta/`.

Packages installed later from PyPI, CRAN, or conda keep their own licenses.
Some bioinformatics packages are academic-only or non-commercial; check before
installing or distributing them.
