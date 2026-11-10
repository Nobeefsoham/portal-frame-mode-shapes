# Portal Frame Mode Shapes

GNU Octave script for plotting 2D mode shapes of a fixed-fixed portal frame with steel legs and an aluminum top span using transfer matrices and singular value decomposition.

## Run

Open `portal_frame_mode_shapes.m` in GNU Octave with the Qt graphics toolkit available, set the working directory to the script folder, and run:

```octave
portal_frame_mode_shapes
```

The script prints frequencies and plots three deformed shapes with the undeformed frame. The `graphics_toolkit('qt')` line is specific to GNU Octave; MATLAB users would need to remove or adapt that line.

## Model and interpretation

- Leg lengths: 0.150 m each; top span: 0.125 m.
- Rectangular section: 0.025 m in the bending plane by 0.002 m out of plane.
- Steel: E = 200 GPa, density = 7850 kg/m^3.
- Aluminum: E = 71 GPa, density = 2770 kg/m^3.
- Supplied ANSYS target frequencies: 70.60, 296.64, and 381.70 Hz.

The frequencies are hard-coded inputs, not independently calculated eigenfrequencies. At each supplied frequency, the script uses the smallest right singular vector of the boundary-condition submatrix to construct a shape. Each plotted shape is rescaled for visibility; plotted deformation is not a physical response amplitude. The ANSYS model and validation data are not included.

The script is reproduced as provided by the repository owner. Publication does not constitute numerical validation; the script was not executed as part of this upload.

## Citation

Nobeefsoham. (2026). *Portal Frame Mode Shapes* [GNU Octave source code]. GitHub. https://github.com/Nobeefsoham/portal-frame-mode-shapes

For a reproducible research citation, also record the specific Git commit hash or use the file's permanent link. A `CITATION.cff` file supplies citation metadata using the GitHub username as the author identifier.
