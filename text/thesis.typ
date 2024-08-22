// LaTeX look
//#set page(margin: 1.75in)
#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
#set text(font: "New Computer Modern")

#show raw: set text(font: "New Computer Modern Mono")
#show par: set block(spacing: 0.55em)
#show heading: set block(above: 1.4em, below: 1em)

#set heading(numbering:
    (..nums) =>
    if nums.pos().len() == 1 {
        numbering("I.", nums.pos().last())
    } else {
        numbering("A.", nums.pos().last())
    }
)

#show heading.where(level: 1): it => smallcaps(it)
#show heading.where(level: 2): it => emph(text(weight: 400, it))

#set document(title: "Implementation and Evaluation of mobile RSSI-based LoRa Localization", author: "Mose Schmiedel")

#include "00_title.typ"
#include "01_introduction.typ"
#include "02_state-of-the-art.typ"
#include "03_principals.typ"
#include "04_implementation.typ"
#include "05_evaluation.typ"
#include "06_future-works.typ"

#bibliography("lora-ba-thesis.bib", style: "ieee")

#include "07_appendix.typ"
