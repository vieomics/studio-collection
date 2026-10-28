# Third-party notices

This image is an aggregate of independently licensed software. The MIT license
in the repository root covers the original Omicslab code in this repository. It
does **not** relicense the third-party components listed below, and the image as
a whole is not "MIT-only".

License texts shipped in the image are under
`/usr/share/doc/studio-collection/LICENSES/`.

## Base image

| Component | Version | License | Source |
| --- | --- | --- | --- |
| rocker/rstudio | 4.6.1 | image scripts GPL-2.0-or-later | <https://github.com/rocker-org/rocker-versioned2> |
| R | 4.6.1 | GPL-2.0 / GPL-3.0 | <https://www.r-project.org/> |
| RStudio Server | 2026.10.0+233 | AGPL-3.0 | <https://github.com/rstudio/rstudio> |
| Ubuntu | 24.04 | mixed GPL/LGPL/permissive | <https://launchpad.net/ubuntu/noble> |

**RStudio Server is AGPL-3.0.** If you let users interact with RStudio Server
over a network, the AGPL network-use and corresponding-source obligations apply.
The RStudio Server source is available from the upstream project above. Any
modifications to RStudio Server must be released under the AGPL.

The Ubuntu and Rocker base also contains GPL/LGPL packages. See
`/usr/share/doc/<package>/copyright` and `/usr/share/common-licenses/` inside the
image.

## Added by this repository

| Component | Version | License | Source |
| --- | --- | --- | --- |
| Pixi | 0.83.0 | BSD-3-Clause | <https://github.com/prefix-dev/pixi> |
| Pixi R environment | R 4.6.1 | R GPL-2.0 / GPL-3.0 | <https://github.com/conda-forge/r-base-feedstock> |
| IRkernel | CRAN | MIT | <https://github.com/IRkernel/IRkernel> |
| rstudioapi | CRAN | MIT | <https://github.com/rstudio/rstudioapi> |
| Oh My Zsh | master at build time | MIT | <https://github.com/ohmyzsh/ohmyzsh> |
| zsh-autosuggestions | master at build time | MIT | <https://github.com/zsh-users/zsh-autosuggestions> |
| zsh-syntax-highlighting | master at build time | BSD-3-Clause | <https://github.com/zsh-users/zsh-syntax-highlighting> |

License texts:

- `LICENSES/AGPL-3.0-rstudio-server.txt` — RStudio Server
- `LICENSES/GPL-2.0-R.txt` — R
- `LICENSES/BSD-3-Clause-pixi.txt` — Pixi
- `LICENSES/MIT-oh-my-zsh.txt` — Oh My Zsh
- `LICENSES/MIT-zsh-autosuggestions.txt` — zsh-autosuggestions
- `LICENSES/BSD-3-Clause-zsh-syntax-highlighting.txt` — zsh-syntax-highlighting

R packages installed later from CRAN or conda-forge are licensed by their
publishers. Some bioinformatics packages have academic-only or non-commercial
licenses; check before installing or distributing them.
