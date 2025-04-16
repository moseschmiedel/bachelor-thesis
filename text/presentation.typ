#import "@preview/unify:0.6.0": qty
#import "@preview/zero:0.2.0": num, set-round
#import "@preview/codelst:2.0.1": sourcecode, code-frame

#import "@preview/touying:0.5.3": *
#import themes.metropolis: *
#import "@preview/cetz:0.2.2"
#import cetz.draw
#import cetz.plot
#import cetz.palette

// #pdfpc.config(
//   duration-minutes: 30,
//   start-time: datetime(hour: 17, minute: 0, second: 0),
//   end-time: datetime(hour: 17, minute: 30, second: 0),
//   last-minutes: 5,
//   note-font-size: 12,
//   disable-markdown: false,
// )

#show link: set text(fill: blue)

#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))

#let sans_font = "Source Sans 3"
#let serif_font = "Source Serif 4"
#let mono_font = "Source Code Pro"

#show figure.caption: it => [
    //#v(-1.4em)
    #emph[
        #set text(20pt)
        #text(weight: 600)[
            #it.supplement
            #it.counter.display(it.numbering)
            #h(-.15em)
            #it.separator
        ]
        #it.body
    ]
]

#set math.equation(numbering: "(1)")

#let bold_txt = text.with(weight: "bold")
#let text_qty(number, unit) = text(spacing: 50%)[#number #unit]

#let title = "Implementation and Evaluation of mobile RSSI-based LoRa Localization"
#let institution = "HTWK Leipzig"

#set text(
    font: serif_font,
    lang: "en",
    region: "US",
)

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  // config-common(handout: true),
    header: self => text(font: sans_font)[#utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%))],
    header-right: self => block(height: 100pt, image("assets/HTWK_Zusatz_de_H_White_K.svg", width: 200pt)),
    config-info(
        title: title,
        subtitle: [Bachelor Thesis for B.sc. Informatik],
        author: [#text(20pt)[Mose Schmiedel] \ #emph[supervised by] Prof. Dr. Jens Wagner \ #emph[and] Marian Ulbricht, M.Eng.],
        date: datetime.today(),
        institution: image("assets/HTWK_Zusatz_de_H_Black_sRGB.svg"),
  ),
    config-colors(
        primary: rgb("#009ee3"),
        primary-light: rgb("#ccc"),
        secondary: rgb("#000"),
        neutral-lightest: rgb("#fff"),
        neutral-darkest: rgb("#000"),
        neutral-dark: rgb("#000"),
    )
)

#let sans = text.with(font: sans_font)
#let mono = text.with(font: mono_font)

#show heading: it => sans(it)

#show "LoRa": [LoRa#emoji.tm ]


#title-slide()

= #sans[Motivation]

== Motivation
#pause
- Apple AirTag#emoji.tm
#pause
- IoT + Industry 4.0
#pause
- Rise of LoRa 
#pause
- GPS is insufficient
    - Mountains
    - Underwater
    - Indoor

== LoRa 
#pause
- patented 2014 by Cycleo (later bought by Semtech)
#pause
- "#bold_txt[Lo]ng #bold_txt[Ra]nge"
    - ranges up to #text_qty(10, "km") @seye_study_2018
#pause
- Chirp Spread Spectrum Modulation (CSS)
#pause
- Low-power (TX: $~qty("20", "mA")$, RX: $~qty("11", "mA")$) @casals_modeling_2017

== Chirp Spread Spectrum
- LoRa EU $f_"center"$ = #text_qty("433.05 - 434.79", "MHz") and #text_qty("863 - 870", "MHz")
#v(2em)
#figure(
    caption: "Chirp Spread Spectrum Modulation",
    cetz.canvas({
        import cetz.draw: *
        scale(150%)
        plot.plot(
            size: (14,3),
            axis-style: "scientific",
            x-tick-step: 1,
            y-tick-step: none,
            x-label: $t$,
            y-label: "",
            x-min: 0,
            x-max: 4,
            y-max: 1.2,
            y-min: -1.2,
            x-grid: true,
            y-grid: true,
            y-ticks: ((-1, $f_"center" - "BW"/2$), (0, $f_"center"$), (1,$f_"center" + "BW"/2$)),
            legend: none,
            {
                plot.add(
                    ((0, -1), (1,1), (1,-1), (2,1), (2, 0.33), (2.66, -1), (2.66, 1), (3, 0.33), (3, 0), (3.5, -1), (3.5, 1), (4, 0)),
                    line: "linear",
                    style: (stroke: (paint: black),
                    mark: none,
                    )
                )

                plot.annotate({
                    line((1, 0.5), (2, 0.5), stroke: (dash: "dashed", thickness: .4pt), mark: (symbol: ">", fill: black), name: "chirp")
                    content("chirp.mid", padding: .2, anchor: "south", [chirp])
                })
            }
        )
    })
)
#pause
#v(2em)
- $2^"Spreading Factor"$ symbols per chirp (7-12) @noauthor_spreading_nodate

= #sans[Goal of this Thesis]
== Goal of this Thesis
#pause
- Evaluate feasibility of a RSSI-based localization system with LoRa
#pause
- Implement a simple reference system for evaluation

= #sans[Implementation]
== Implementation
#figure(
    caption: "Propagation of `Ping_t` message",
    cetz.canvas({
        import cetz.draw: *
        scale(150%)
        let cross = ((x, y), size: 1, width: 4pt, dynamic_scaling: true, name: "") => {
            let stroke_w = if dynamic_scaling { width * size } else { width }
            let nice_size_factor = 0.4
            let half_line_len = size * nice_size_factor
            group({
                line((x - half_line_len,y - half_line_len), (x + half_line_len,y + half_line_len), stroke: stroke_w, name: name + "_325deg")
                line((x - half_line_len,y + half_line_len), (x + half_line_len,y - half_line_len), stroke: stroke_w, name: name + "_45deg")
            }, name: name)
        }

        let label = (coord, content, angle: "", padding: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt, x: 0pt, y: 0pt), name: "") => {
            if angle != "" {
                draw.content(coord, angle: angle, padding: padding, box(fill: white, stroke: .4pt, radius: 2pt, inset: 2.5pt, content), name: name)
            } else {
                draw.content(coord, padding: padding, box(fill: white, stroke: .4pt, radius: 2pt, inset: 2.5pt, content), name: name)
            }
        }
        cross((0,0), name: "end_node")
        cross((-3,1), name: "anchor_a")
        cross((0,2), name: "anchor_b")
        cross((-1.5,-2), name: "anchor_c")

        let radii = (.8, 1, 1.3, 1.7, 2.2, 2.8, 3.5)

        for r in radii {
            circle("end_node.center", radius: r, stroke: (dash: "dashed"))
        }

        line("end_node.east", (4.5, 2.25), stroke: (thickness: 3pt, dash: "dashed"), mark: (end: ">"), name: "ping_line")
        label(("ping_line.start", 60pt, "ping_line.end"), angle: "ping_line.end", text(18pt)[`Ping_t`], name: "ping_label")

        label("end_node.south-east", padding: (left: 50pt, top: 20pt), text(18pt)[End node], name: "end_node_label")
        label("anchor_a.north-west", padding: (right: 10pt, bottom: 20pt), text(18pt)[Anchor A], name: "anchor_a_label")
        label("anchor_b.north-east", padding: (left: 10pt, bottom: 20pt), text(18pt)[Anchor B], name: "anchor_b_label")
        label("anchor_c.south-west", padding: (top: 20pt), text(18pt)[Anchor C], name: "anchor_c_label")

        hide(bounds: true, {
            rect((-6,-4.4), (6,4.35))
        })
    })
)

== Hardware
#figure(
    caption: "NUCLEO-WL55JC",
    image("assets/nucleo.jpg", width: 39%),
)

== Firmware
#figure(
    caption: "Firmware architecture",
    cetz.canvas({
        import cetz.draw: *
        scale(200%)
        let start = (shape) => shape.coords.at(0)
        let end = (shape) => shape.coords.at(1)
        let shapes = (
            (coords: ((x: 5.5, y: 3), (x: 9, y: 6.5)), name: "util",
                content: sans[*Utilities* \ Sequencer \ Timer server \ Trace via UART]),
            (coords: ((x: 0, y: 3), (x: 5, y: 6.5)), name: "app",
                content: sans[*Application* \ LoraLocator]),
            (coords: ((x: 0, y: 1.5), (x: 9, y: 2.5)), name: "driver",
                content: sans[*Hardware driver* \ HAL + SubGHz_Phy]),
            (coords: ((x: 0, y: 0), (x: 9, y: 1)), name: "hardware",
                content: sans[*Hardware* \ NUCLEO-WL55JC with STM32WL55JC]),
        )
        for s in shapes {
            rect(
                (s.coords.at(0).x,
                    s.coords.at(0).y),
                (s.coords.at(1).x,
                    s.coords.at(1).y),
                stroke: 1pt,
                name: s.name)
            content(s.name+".center", align(center, s.content))
        }

        let lines = (
            (a: "app", b: "util", dir: "horiz"),
            (a: "app", b: "driver", dir: "vert"),
            (a: "util", b: "driver", dir: "vert"),
            (a: "driver", b: "hardware", dir: "vert"),
        )
        for l in lines {
            let gap = 0.4
            let shape_a = shapes.find(s => s.name == l.a)
            let shape_b = shapes.find(s => s.name == l.b)
            let name = l.a + "-" + l.b
            let stroke = 0.5pt
            let mark_scale = .8
            if l.dir == "horiz" {
                let midpoint = start(shape_a).y + (end(shape_a).y - start(shape_a).y) / 2
                line(
                    (end(shape_a).x,
                        midpoint - gap / 2),
                    (start(shape_b).x,
                        midpoint - gap / 2),
                    mark: (start: ">", fill: black, scale: mark_scale),
                    stroke: stroke,
                    name: name + "minus"
                )
                line(
                    (end(shape_a).x,
                        midpoint + gap / 2),
                    (start(shape_b).x,
                        midpoint + gap / 2),
                    mark: (end: ">", fill: black, scale: mark_scale),
                    stroke: stroke,
                    name: name + "plus"
                )
            } else {
                let midpoint = start(shape_a).x + (end(shape_a).x - start(shape_a).x) / 2
                line(
                    (midpoint - gap / 2,
                        start(shape_a).y),
                    (midpoint - gap / 2,
                        end(shape_b).y),
                    mark: (start: ">", fill: black, scale: mark_scale),
                    stroke: stroke,
                    name: name + "minus"
                )
                line(
                    (midpoint + gap / 2,
                        start(shape_a).y),
                    (midpoint + gap / 2,
                        end(shape_b).y),
                    mark: (end: ">", fill: black, scale: mark_scale),
                    stroke: stroke,
                    name: name + "plus"
                )
            }
        }
    })
) <firmware_architecture>

== Distance Estimation
- Path-Loss Model @zanella_best_2016
$ "RSSI"(d) = P_0 - 10 n dot log_10 (d/d_0) $
#pause
$ d("RSSI") = 10^(("RSSI" + 10 n) dot 1 / P_0) $
#v(2em)
#pause
- find coefficients with linear regression
$ y = a x + b $
$ y = "RSSI"(d)," "a = -10 n," "x = log_10 (d/d_0)," "b = P_0 $


== Localization (1/2)
#figure(
    image("assets/trilateration.svg", width: 60%),
    caption: "Position estimation error with trilateration"
)

== Localization (2/2)
#figure(
    image("assets/trilateration-mod.svg", width: 60%),
    caption: "Modified trilateration"
)

= #sans[Evaluation]

== Distance Estimation (1/3)
#figure(
    caption: "RSSI vs. Distance data from experiment 02_1",
    image("assets/02_1.svg", width: 80%)
)

== Distance Estimation (2/3)
#figure(
    caption: "RSSI vs. Distance data from experiment 07",
    image("assets/07.svg", width: 80%)
)

== Distance Estimation (3/3)
#let dist_agg = {
    csv("data/distance_aggregated_error.csv", row-type: dictionary)
       .map(row => (experiment: row.experiment,
           mean_rel_error: float(row.mean_rel_error),
           std_rel_error: float(row.std_rel_error),
           max_error_m: float(row.max_error_m),
           min_error_m: float(row.min_error_m),
           slope: float(row.slope),
           intercept: float(row.intercept),
       ))
}
#figure(
    caption: "Experiments for distance estimation evaluation",
    {
        set-round(mode: "places", precision: 4)
        let display_log_normal = (slope, intercept) => {
            set-round(mode: "places", precision: 4)
            slope = num(slope / 10)
            if float(intercept) < 0 {
                intercept = text_qty(num(-(float(intercept))), "dBm")
                $"RSSI"(d) =  slope dot 10 dot log_10 (d/qty("1", "m")) - intercept$
            } else {
                $"RSSI"(d) = slope dot 10 dot log_10 (d/qty("1", "m")) + intercept$
            }
        }
        let display_error = (error) => {
            set-round(mode: "places", precision: 4)
            let disperr = text_qty(num(error), "m")
            if float(error) < 0 {
            } else {
                [$plus$#disperr]
            }
        }
        let results = dist_agg.map(row => (
            row.experiment,
            if row.experiment == "07" [#text_qty(10, "m") -- #text_qty(160, "m") ] else [#text_qty(5, "m") -- #text_qty(50, "m") ],
            num(row.slope / -10),
            num(row.intercept),
            num(row.mean_rel_error),
            $plus.minus num(#row.std_rel_error)$,
            display_error(if calc.abs(row.max_error_m) > calc.abs(row.min_error_m) { row.max_error_m } else { row.min_error_m })
        ))
        table(
            columns: (auto, 1.1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
            inset: (
                x: 4pt,
                y: 7pt,
            ),
            align: horizon,
            table.header(
                [*ID*], [*Range*], [*$bold(n)$*], [*$bold(P_0)$*], [*$bold(mu(e_"r"))$*], [*$bold(sigma(e_r))$*], [*$bold(e_max)$*]
            ),
            ..results.flatten()
        )
    }
) <dist_results>


== Localization (1/2)

#v(-2em)
#figure(
    caption: [Localization -- Experiment 07],
    stack(dir: ltr,
        spacing: -20pt,
        image("assets/exp07_pos1.svg", width: 35%),
        image("assets/exp07_pos2.svg", width: 35%),
        image("assets/exp07_pos3.svg", width: 35%),

    )
)

== Localization (2/2)

#let pos_agg = {
    json("data/pos_agg.json")

}

#let rows = (pos_data) => {
            let display_cart = (coord) => {
                set-round(mode: "places", precision: 2)
                if coord == none [
                    _unknown_
                ] else {
                    let (x, y) = coord
                    align(left)[_x:_ #h(1fr) #num(x)\ _y:_ #h(1fr) #num(y)]
                }
            }
            let rows = ()
    let debug = ()
            let exp_counter = 0
            for (exp, exp_results) in pos_data {
                rows.push(
                    table.cell(exp, rowspan: 3)
                )
                let pos_counter = 0
                for (pos, pos_results) in exp_results {
                    rows.push(
                        table.cell(pos, x: 1, rowspan: 3)
                    )
                    let anchor_counter = 0
                    for an in pos_results.anchors {
                        rows.push(
                            table.cell(upper(an.at(0)))
                        )
                        rows.push(
                            table.cell(
                                num(an.at(1)))
                        )
                        rows.push(
                            table.cell($#num(an.at(2)) plus.minus #num(an.at(3))$)
                        )
                        if anchor_counter == 0 {
                            rows.push(
                                table.cell(display_cart(pos_results.estimated_pos), rowspan: 3)
                            )
                            rows.push(
                                table.cell(display_cart(pos_results.actual_pos), rowspan: 3)
                            )
                        }
                        anchor_counter += 1
                    }
                    pos_counter += 1
                }
                exp_counter += 1
            }
    rows
}

#figure(
    caption: "Experiments for localization evaluation",
    table(
        columns: (auto, auto, auto, auto, auto, auto, auto),
        align: horizon,
        table.header(
            [*Distance\ model*], [*Position*], [*Anchor ID*], [*RSSI [dBm]*], [*Distance [m]*], [*Estimated\ Position*], [*Actual\ Position*]
        ),
        ..{rows(("07": ("pos2": pos_agg.at("07").at("pos2"))))}.flatten()
    )
)

= #sans[Conclusion]
== #sans[Conclusion]
- simple RSSI-based localization system using LoRa was implemented
#pause
- performance of the system was evaluated
#pause
- evaluation showed that the implemented system is not usable for localization in current state

== #sans[Conclusion]
- big variations between different Path-Loss Models
#pause
#let dist_agg = {
    csv("data/distance_aggregated_error.csv", row-type: dictionary)
       .map(row => (experiment: row.experiment,
           mean_rel_error: float(row.mean_rel_error),
           std_rel_error: float(row.std_rel_error),
           max_error_m: float(row.max_error_m),
           min_error_m: float(row.min_error_m),
           slope: float(row.slope),
           intercept: float(row.intercept),
       ))
}
#figure(
    caption: "Experiments for distance estimation evaluation",
    {
        set-round(mode: "places", precision: 4)
        let display_log_normal = (slope, intercept) => {
            set-round(mode: "places", precision: 4)
            slope = num(slope / 10)
            if float(intercept) < 0 {
                intercept = text_qty(num(-(float(intercept))), "dBm")
                $"RSSI"(d) =  slope dot 10 dot log_10 (d/qty("1", "m")) - intercept$
            } else {
                $"RSSI"(d) = slope dot 10 dot log_10 (d/qty("1", "m")) + intercept$
            }
        }
        let display_error = (error) => {
            set-round(mode: "places", precision: 4)
            let disperr = text_qty(num(error), "m")
            if float(error) < 0 {
            } else {
                [$plus$#disperr]
            }
        }
        let results = dist_agg.map(row => (
            row.experiment,
            if row.experiment == "07" [#text_qty(10, "m") -- #text_qty(160, "m") ] else [#text_qty(5, "m") -- #text_qty(50, "m") ],
            num(row.slope / -10),
            num(row.intercept),
            num(row.mean_rel_error),
            $plus.minus num(#row.std_rel_error)$,
            display_error(if calc.abs(row.max_error_m) > calc.abs(row.min_error_m) { row.max_error_m } else { row.min_error_m })
        ))
        table(
            columns: (auto, 1.1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
            inset: (
                x: 4pt,
                y: 7pt,
            ),
            align: horizon,
            table.header(
                [*ID*], [*Range*], [*$bold(n)$*], [*$bold(P_0)$*], [*$bold(mu(e_"r"))$*], [*$bold(sigma(e_r))$*], [*$bold(e_max)$*]
            ),
            ..results.flatten()
        )
    }
) <dist_results>

== #sans[Conclusion]
- big variations between estimated distances
#pause
#figure(
    caption: "RSSI vs. Distance data from experiment 07",
    image("assets/07.svg", width: 60%)
)

== #sans[Conclusion]
- simple RSSI-based localization system using LoRa was implemented
- performance of the system was evaluated
- evaluation showed that the implemented system is not usable for localization in current state
    - big variations between different Path-Loss models
    - big variations between estimated distances
    #v(2em)
#pause
#bold_txt[#sym.arrow.r] potential for future improvements is visible
#v(2em)
#pause
- different localization systems with LoRa already exist
    - RSSI-based @el_agroudy_low_2016 @mackey_lora-based_2019
    - timing-based @fargas_gps-free_2017

= #sans[Future Work]
== #sans[Future Work]
#pause
- improve RSSI to distance estimation
    #pause
    - increase range over which model is fit
    #pause
    - integrate GPS receiver into hardware for automated data acquisition
    #pause
    - use more then 4 devices for model fitting
    #pause
    - analyze the cause for the RSSI variation at higher distances
    #pause
    - try different Path-Loss model 
#pause
- try different localization algorithm 
    - weighted least-mean-square method @el_agroudy_low_2016 @sumathi_rss-based_2011
    - DV-Hop @safa_novel_2014

= #sans[Thank you]
#[
    #set text(16pt)
- firmware available on GitHub: \ https://github.com/moseschmiedel/lora-locator
- data available on GitHub: \ https://github.com/moseschmiedel/bachelor-thesis
]

== #sans[Bibliography]
#[
#set text(12pt)

#bibliography("presentation.bib", title: none, style: "ieee")
]

== #sans[List of Figures]
#show outline.where(target: figure.where(kind: image)): it => [
    #show outline.entry: it => context {
        v(.4em)
        it
        let indent = 1.5em
        let refs = query(selector(<reference>).after(selector(it.element.location())))
        let refs = refs.filter(r => {
            if counter(figure).at(r.location()) == counter(figure).at(it.element.location()) {
                true
            } else {
                false
            }
        })
        //if refs.len() > 0 [
    [
            #v(.1em)
            #h(indent)
            #box(width: 100% - indent, emph[#emoji.copyright 2024 Mose Schmiedel])
        ]
    }
    #it
]

#[
#set text(12pt)
#outline(title: none, target: figure.where(kind: image))
]


== Packet Types (1/3)
#figure(caption: "Packet type `Ping_t`")[
    #sourcecode[
```c
typedef struct {
    // attribute used to discriminate
    // between packet types
    PacketType_t packet_type;
    // ID of the device
    // sending the `Ping_t`
    uint8_t device_id;
    // ID of the `Ping_t`, `device_id`
    // combined with this should be unique
    uint8_t packet_id;
} Ping_t;
```
    ]
]


== Packet Types (2/3)
#figure(caption: "Packet type `AnchorResponse_t`")[
    #sourcecode[
```c
// Note that this packet does not need a `packet_type` discriminator because
// it is the only type that is 4 bytes long.
typedef struct {
    // ID of the anchor sending the `AnchorResponse_t`
    Device_t anchor_id;
    // ID of the `Ping_t` that triggered this `AnchorResponse_t`
    uint8_t packet_id;
    // RSSI of `Ping_t` measured by the anchor node
    int16_t recv_rssi;
} AnchorResponse_t;
```
    ]
]

== Packet Types (3/3)
#figure(caption: "Packet type `Ack_t`")[
    #sourcecode[
```c
typedef struct {
    // attribute used to discriminate between packet types
    PacketType_t packet_type;
    // ID of the anchor this `Ack_t` is addressed to
    Device_t receiver_id;
    // ID of the `Ping_t` that triggered the communication
    uint8_t packet_id;
} Ack_t;
```
    ]
]

== Low-Power (1/2)
#figure(
    caption: "Power consumption",
    table(
        columns: (auto, auto, auto),
        table.header(
            [*Mode*], [*Current [mA]*], [*Power consumption [mW]*]
        ),
        [Transmitting], $27$, $135$,
        [Receiving], $8.5$, $42.5$,
        [Sleep], $2.9$, $14.5$,
    )
)
#pause

$ P_"tx" = (2 dot T_"tx") / qty("1000", "ms") dot qty("135", "mW") $
$ P_"rx" = qty("400", "ms") / qty("1000", "ms") dot qty("42.5", "mW") $
$ P_"tx" = (1000 - (2 dot T_"tx" + qty("400", "ms"))) / qty("1000", "ms") dot qty("14.5", "mW") $
$ P_"total" = P_"tx" + P_"rx" + P_"sleep"  = qty("30.7", "mW") $

== Low-Power (2/2)

$ P_"total" = P_"tx" + P_"rx" + P_"sleep"  = qty("30.7", "mW") $
#pause

#figure(
    caption: "LiPo Battery",
    image("assets/akku.jpg", width: 40%),
)

- lifetime of $~$#text_qty(1303, "h") or 54.3 days with battery capacity of #text_qty(40000, "mWh")

== Friis Equation

$ P_r^"[dB]" = P_t^"[dB]" + G_t^"[dBi]" + G_r^"[dBi]" + 20 log_"10" (lambda / (4 Pi d)) $
