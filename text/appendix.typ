#let mono_font = "Source Code Pro"
#let mono = text.with(font: mono_font)

#set par(leading: 0.55em, first-line-indent: 0em, justify: true)

= Appendix

All software and data implemented and recorded for this thesis can be found online or on
the provided USB drive.

#v(.4em)
The data and the scripts for evaluation can be found in this repository on GitHub:
https://github.com/moseschmiedel/bachelor-thesis/tree/submission.

#v(.4em)
The firmware for the anchor nodes and the end node can be found in this repository on GitHub:
https://github.com/moseschmiedel/lora-locator/tree/submission.

#v(.8em)
The contents of the USB drive are:
#table(
    columns: (auto, auto),
    mono[data], [folder with the data and data evaluation repository],
    mono[lora-locator], [folder with the anchor and end node firmware repository],
    mono[thesis], [folder with the source code and PDF of this thesis],
)
