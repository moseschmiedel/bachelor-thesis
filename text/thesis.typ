#import "@preview/unify:0.6.0": qty
#import "@preview/cetz:0.2.2"
#import "@preview/codelst:2.0.1": sourcecode, code-frame
#import "@preview/zero:0.2.0": num, set-round
#import cetz.draw
#import cetz.plot
#import cetz.palette

#let sans_font = "Source Sans 3"
#let serif_font = "Source Serif 4"
#let mono_font = "Source Code Pro"

// LaTeX look
#set page(
    "a4",
    margin: (left: 3cm, top: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    footer: context {
        if counter(page).get().first() > 2 [
            #align(right)[#text(11pt, fill: black, font: sans_font, weight: 600)[#counter(page).display("1")]]
        ]
    }
)

#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
#set text(
    font: serif_font,
    size: 11pt,
    lang: "en",
    region: "US",
)

#show link: set text(fill: blue)
#show link: underline.with(offset: 1pt)

#show terms.item: it => block(spacing: 0.8em, par(hanging-indent: 1.8em, justify: true)[
    #set text(weight: 600)
    #it.term
    #set text(weight: 400)
    #it.description
])
#show raw: set text(font: mono_font)
#show par: set block(spacing: 0.55em)
#show heading: set block(above: 1.4em, below: 1em)
#show heading: set text(font: sans_font)

#set heading(numbering: "1.1.1")
#set math.equation(numbering: "(1)")

#show heading.where(level: 2): it => text(weight: 600, it)
#show heading.where(level: 3): it => emph(text(weight: 600, it))
#show figure.caption: it => [
    #emph[
        #text(weight: 600)[
            #it.supplement
            #it.counter.display(it.numbering)
            #h(-.15em)
            #it.separator
        ]
        #it.body
    ]
]
#show figure: it => [
    #it
    #v(1em)
]
#show raw.where(block: true): it => block(width: 100%, align(start, it))


/***********
 * Helpers *
 ***********/

#let text_qty(number, unit) = text(spacing: 50%)[#number #unit]

#let sans = text.with(font: sans_font)
#let mono = text.with(font: mono_font)
#let bold_txt = text.with(weight: "bold")


#[
#show heading.where(level: 1): it => [
    #pagebreak()
    #smallcaps(it)
]
/*************
 * Titlepage *
 *************/
// Configuration
#let author = "Mose Schmiedel"
#let professor = "Prof. Jens Wagner"
#let supervisor = "Marian Ulbricht, M.Eng."
#let organization = "HTWK Leipzig"
#let date_raw = datetime(day: 16, month: 10, year: 2024)
#let date = "October 2024, Leipzig"
#let title = "Implementation and Evaluation of mobile RSSI-based LoRa Localization"
#let subtitle = "Bachelor Thesis"
#let keywords = ("LoRa", "RSSI", "localization", "distance estimation")

#let titlepage = [
    #align(center)[
    #block(width: 100%)[
        #v(15fr)
        #stack(dir: ltr)[
            #box[#image("assets/HTWK_Zusatz_de_H_Black_sRGB.svg", width: 20em)]
            #h(1fr)
            #sans(16pt)[#date]
        ]
        #v(35fr)
        #block[
        #sans(weight: "bold", size: 24pt)[#title]
        ]
        #v(30fr)
        #block[
        #sans(size: 20pt)[#subtitle]
        #block[
            #text(14pt)[for]\
            #v(.3em)
            #emph[#text(18pt)[B.sc. Informatik]]\
            #v(1em)
            #emph[#text(16pt)[Faculty of Computer Science and Media]]
        ]
        ]
        #v(30fr)
        #block[
            #emph[#text(16pt)[submitted by]]\
            #v(.3em)
        #text(20pt)[#author]
        ]
        #v(8em)
        #block[
            #columns(2)[
                #text(14pt)[#professor]\
                #text[#emph[First reviewer]]
                #colbreak()
                #text(14pt)[#supervisor]\
                #text[#emph[Second reviewer]]
            ]
        ]
        #v(10fr)
    ]
    ]
]

#set document(title: title, author: author, keywords: keywords)

#titlepage

#show "LoRa ": [LoRa#emoji.tm ]
#show "LoRaWAN": [LoRaWAN#emoji.tm]

#pagebreak()

_Abstract_
#v(1em)
_For this thesis a LoRa localization system for outdoor use was implemented and evaluated. The system uses RSSI measurements to estimate
the distances between three anchor nodes and one end node. A trilateration algorithm is employed to estimate the position
of the end node based on these distances. The implementation decisions of the localization system are explained and
the performance of the system is evaluated experimentally. The evaluation highlights the limitations of RSSI-based
localization and provides clues for future optimizations._

#v(3em)
_*Keywords:* #h(1em) #keywords.join([#h(.4em) #box(baseline: -42%)[#circle(radius: 1.8pt, fill: black)] #h(.4em)])_

#heading(numbering: none, outlined: false)[Eidesstattliche Versicherung]

Ich erkläre hiermit, dass ich diese Bachelorarbeit selbstständig ohne Hilfe Dritter und ohne Benutzung anderer als der angegebenen
Quellen und Hilfsmittel verfasst habe. Alle den benutzten Quellen wörtlich oder sinngemäß entnommenen Stellen sind als
solche einzeln kenntlich gemacht.
#v(1em)
Diese Arbeit ist bislang keiner anderen Prüfungsbehörde vorgelegt und auch nicht veröffentlicht worden.
#v(1em)
Ich bin mir bewusst, dass eine falsche Erklärung rechtliche Folgen haben wird.

#v(4em)
#line(length: 100%)
#v(-.6em)
Ort, Datum, Unterschrift

#show outline.where(target: heading.where(outlined: true)): it => [
    #show outline.entry.where(level: 1): it => {
        v(12pt, weak: true)
        sans(strong(it))
    }
    #it
]

#outline(
    indent: true,
)

#show outline: set heading(outlined: true)

= Introduction
With radio technology becoming smaller and smaller, a continuously increasing amount of devices
feature some form of localization capability. One popular example for this is the Apple AirTag#emoji.tm @noauthor_airtag_nodate.
This device gives the broader public access to low power continous tracking technology.

On the other hand with the rise of the internet of things (IoT) in industry 4.0 @rizzi_using_2017, tracking and localization
technology is needed for tasks like asset tracking @priyanta_evaluation_2019 @gotthard_low-cost_2018,
smart campus orientation @alves_introducing_2020 or collision avoidance @gardiner_collision_2011. But localization
techniques are also essential for other applications like emergency rescue services @sciullo_design_2020 @mackey_lora-based_2019
or elderly care @fernandes_hybrid_2020.
With or without IoT and industry 4.0 the need for precise localization and tracking technology is clear.
#v(.4em)
Parallel to the advancements of IoT and industry 4.0, a new radio communication technology LoRa was developed @vangelista_long-range_2015.
This technology consists of a new modulation technique, also called LoRa, and a networking layer, called LoRaWAN. It promises
long-range communication with minimal power consumption.

Using this new technology for localization systems seems like a good fit because the area of coverage can be maximized,
while minimizing the power consumption.

#v(.4em)
To evaluate the feasibility and performance of LoRa based localization,
a localization system based on the LoRa modulation technique is implemented in this thesis. 
The localization system uses the received signal strength indicator (RSSI) to estimate
distances for the position estimation.

= State of the Art
LoRa and LoRaWAN were released as a radio communication technology to the public in 2015 by Semtech. 
Very early on, it already received coverage in scientific media as it was introduced as a
promising long-range radio communication technology for IoT devices @vangelista_long-range_2015.

This section presents relevant literature correlating with mobile RSSI-based LoRa Localization.

== Localization methods
There a multiple approaches for localization in RF based communication networks. The most commonly
used all depend on one or more of four physical metrics of the received radio signal. These properties
are the angle of arrival (AoA), time of arrival (ToA), Time delay of arrival (TDoA) and received signal strength
(RSSI) @marquez_understanding_2023[p.~3].

The presented localization algorithms use fixed reference points with known positions
to estimate the position of a device. The reference points will be called anchor nodes and the device will be called end node
from now on.

=== Angle of Arrival
Localization systems which are based on the angle of arrival use a directed antenna array to measure the
angle at which the radio signal was received. The AoA information of the signal received at the anchor nodes
and the distance between the anchor nodes is used to estimate the position of the end node via triangulation @peng_angle_2006[p.~2].
This is done using sine and cosine of the measured angles in combination of the distance between the anchor nodes.

#figure(
    image("assets/angulation-2-nodes.svg", width: 80%),
    caption: "Triangulation of end node with two anchor nodes"
)

AoA-based localization can achieve high position accuracy in short range applications. The accuracy is
negative correlated with increasing distance between anchor node and end node. This can be simply explained with
the following graphic. As can be seen, the resulting change of the position when changing the angle by one degree
is greater when the end node is farther away from the anchor node @zare_applications_2021[p.~3].

#figure(
    image("assets/angulation-2-nodes-error.svg", width: 80%),
    caption: "Triangulation error at different distances"
)

Another drawback of AoA-based localization methods is that they require additional hardware, not yet commonly
implemented in all RF receivers. Also, the need of a directed antenna array makes this localization method
unattractive for low-cost applications @zare_applications_2021[p.~3].

=== Time of Arrival
Another localization method presented in the media uses the time of arrival (ToA) of the radio signal.
The ToA is used to calculate the time of flight (ToF) which is the time the radio signal needs to travel from
the transmitter to the receiver. From this time and the speed of light, the distance between transmitter and receiver
can be calculated @kuriakose_localization_2014.

The position of the end node can be estimated when at least three distances between different anchors and the end node
can be measured. From these distances, the position can be derived by using trilateration. Trilateration calculates the
area of intersection between circles centered at the anchor nodes, each with the measured distance between the corresponding
anchor node and the end node. An improved variant of this localization algorithm called multilateration is explained in @multilateration
in more detail.

ToA-based localization systems need high precision timing capabilities and strict time synchronization between anchor and end node.
The following calculation demonstrates that to measure distances up to 1 m the time measurement must provide an accuracy
of $plus.minus$ #qty("3.3", "ns").

$ "ToF"_"1m" = qty("1", "m") / c approx qty("1", "m") / qty("3e8", "meter per second") = qty("3.3e-9", "s") eq.est qty("3.3", "ns") $

Due to this requirement, ToA-based localization is more suited for long range applications. As with AoA-based localization, this technique also
requires specialized hardware not found in every receiver circuit. Clock systems with high resolution and low drift over time and temperature are
required to achieve the before mentioned requirements for precision and synchronization of the time measurement @marquez_understanding_2023[p.~4].

=== Time Difference of Arrival
The strict time synchronization of anchor and end node is a requirement which is sometimes very difficult or even impossible to achieve in real world
implementations. In such circumstances, it could be required that end nodes can be deployed dynamically such that they are not always powered on and not
physically close to each other. These requirements add much complexity to the time synchronization process. One way to deal with this complexity is to avoid
it all together by improving the ToA-based distance measurement. Instead of using the ToF to estimate the distance between anchor and end node, the
time difference between the ToA of different anchors is used to calculate the differences of the distances between the anchors and the end node.
Through this optimization, time synchronization between anchor and end node is not required anymore, which decreases the complexity of the localization system.
The anchor nodes still need to be synchronized so that the differences between the different ToA can be used effectively @fargas_gps-free_2017.

Despite solving the time synchronization challenge of ToA-based localization, TDoA-based localization inherits many of the drawbacks of ToA-based localization.
The hardware used for TDoA-based localization still has to provide excellent resolution and drift properties.

=== Received Signal Strength Indicator <rssi>
The last localization method presented in this section uses the Received Signal Strength Indicator (RSSI) of a received radio signal. Like the T(D)oA based method
this localization technique also uses trilateration or multilateration to estimate the position of the end node. It differs in the distance estimation technique.
Instead of relying on time of flight or a derived measurement, this method uses the decrease in signal strength to estimate the distance between anchor and end node.

The RSSI measured by the receiver depends on many influences like distance between sender and receiver, number of reflections or attenuation by obstacles
(buildings, trees, hills) @azevedo_critical_2024[p.~1]. In the literature, several models for radio propagation with focus on different environments or applications are presented.
Examples include log-distance model @bianco_lora_2021[p.~4], Okumura-Hata model @griva_lora-based_2023[p.~4] or Cost 231 model @stusek_accuracy_2020[p.~3].
Although there exists no common classification of propagation models, they can be grouped into different categories. One such grouping differentiates the models
by the way, they are fitted @azevedo_critical_2024[p.~2].
/ Empirical models: rely on intensive measurement of the real behavior of the used radio system.
/ Site-specific models: include factors which are derived from a detailed understanding of the environment where the system is later deployed.
/ Theoretical models: use the underlying theory of electromagnetic propagation to calculate the path loss in an ideal environment.

In contrast to the other presented localization methods, RSSI-based localization does not need specialized hardware due to RSSI measurement circuit being available in most
LoRa receiver chips. This makes this method ideal for low-cost applications. This benefit comes with a cost because this localization method cannot achieve accuracies as
high as the other presented localization techniques @marquez_understanding_2023[p.~11].

== Low Power
LoRa is radio communication technology promising low power consumption compared to conventional long range radio communication
technologies @vangelista_long-range_2015[p.~7]. This is an active field of research because the power budget is an important design factor
for mobile applications due to them being limited to battery-based power supplies.

#v(0.4em)
One goal of this thesis is to evaluate RSSI-based localization in a mobile application. This implies, for the above mentioned reasons, that the
evaluation of the resulting localization system must include some form of power consumption characterization.
To find and evaluate the real power characteristics of devices using LoRa communication technology, several studies were performed already.
Some of these works are presented in the following section.

#v(0.4em)
Fargas et al. evaluate a LoRa localization system in @fargas_gps-free_2017 and compare its current consumption with a GPS + GSM based device.
They found that their device had significant lower current consumption and therefore could drastically decrease the power requirements for
devices with localization systems.

#v(0.4em)
In @el_agroudy_low_2016 El Agroudy et al. present an outdoor localization system based on RSSI with ZigBee. They evaluate the power consumption
of their implementation and find that it draws around #text_qty("30", "mA") in "Active mode" and #text_qty("6.7", "µA") in "Sleep mode". "Active mode"
is the system state in which communication and localization takes place while "Sleep mode" describes the state in which all system activity is lowered to 
minimum.

El Agroudy et al. propose, based on the significant difference in current draw between Active and Sleep mode, to reduce the amount of time
spent in Active mode by implementing a periodic wake-up event which changes the system state from Sleep mode to Active mode. With this approach
the total power consumption of the device can be configured by adjusting the time interval between the wake-up events.

#align(center)[
    #figure(
        caption: "Current consumption in Active and Sleep mode",
        cetz.canvas({
            import cetz.draw: *
            let y_min = 0.0067
            let y_max = 30
            let y_pad = 0.6
            plot.plot(
                size: (14,3),
                axis-style: "scientific",
                x-tick-step: 500,
                y-tick-step: 10,
                x-label: $t "[ms]"$,
                y-label: $I "[mA]"$,
                x-min: 500,
                y-max: y_max + (y_max - y_min) * y_pad,
                y-min: y_min - (y_max - y_min) * y_pad,
                legend: none,
                {
                    plot.add(
                        ((500, 0.0067), (1000,30), (1100,0.0067), (2000, 30), (2300, 0.0067), (3000, 30), (3300, 0.0067), (3800, 0.0067)),
                        line: "hv",
                        style: (stroke: (paint: black))
                    )
                    plot.annotate({
                        content((1500, 6), [_Sleep mode_])
                        content((2150, 35.3), [_Active mode_])

                        line((1000, 20), (2000, 20), stroke: (dash: "dashed", thickness: .4pt), mark: (symbol: ">", fill: black), name: "wake-up")
                        line((3000, 10), (3300, 10), stroke: (dash: "dashed", thickness: .4pt), mark: (symbol: ">", fill: black), name: "active")
                        content("wake-up.mid", padding: .2, anchor: "south", [$t_"wake-up"$])
                        content("active.mid", padding: .2, anchor: "south", [$t_"Active"$])
                    })
                }
            )
        })
    )
]

The total current consumption of this approach can be calculated when the current draw and the time spent in the individual modes is known. Following 
equation shows the final formula. The resulting current consumption is measured in Milliampere hours (mAh).

$
t_"wake-up" &:= "Time interval between Wake-Up events" \
t_"Active" &:= "Time per interval spent in Active mode" \
I_"total" &= (I_"Active" dot t_"Active" + I_"Sleep" dot (t_"wake-up" - t_"Active")) / t_"wake-up"
$

They used a #text_qty("620", "mAh") battery and configured their system to be in the Active mode for 5% of the time. They found that through this method
they could improve the life time of their battery from 14.46 hours to 288 hours.

A challenge for this approach is that a device cannot receive any signals while in Sleep mode. This challenge must influence the design of the localization
algorithm to ensure that communication between the devices in the localization system is possible. El Agroudy et al. resolve this issue by keeping the anchor node 
of their localization system always in Active mode so that it can coordinate the communication.

#v(0.4em)
In @mackey_lora-based_2019 Mackey et al. evaluate the power consumption of a LoRa localization system based on the Dragino LoRa v1.3 Shield
and an Arduino Uno microcontroller. Like El Agroudy et al. they also implement an localization algorithm working with fixed communication intervals to
reduce the amount of time the system is in active mode. They evaluated the power consumption of the receiver node (end node) and the transmitter node
(anchor node) separately. They also varied the transmission power and transmission rate and found that they could configure their whole localization system,
which consisted of three anchor nodes and one end node, so that it consumed around #text_qty("350", "mW"). They compared this with the power consumption
of the GPS module integrated in the Dragino Shield and found that their system outperforms GPS-based localization when at least four end nodes use the
deployed anchor nodes.

Despite these promising findings there is still room for improvement. Mackey et al. estimated the life time of a #text_qty("5000", "mAh")
battery when used as a power source for the anchor or the end node. They found that their anchor node could run up to 200 hours with one
battery charge, but their end node would only last for 90 hours. These values would make this solution practical in ad-hoc short-term
scenarios where a localization system is need quick and only for a couple of days, but for remote long-term deployments improvements need
to be made especially for the power consumption of the anchor node.

#v(0.4em)
Gotthard et al. implement a LoRa RSSI-based system in @gotthard_low-cost_2018, specialized for asset localization in large carparks.
They found that with their localization technique a single node of their system could run for about 5 years powered by an #text_qty("800", "mAh")
CR2 battery. This result looks rather promising compared to the other findings presented in this section. But the system Gotthard et al. builds
on fundamental assumptions taken about the environment and scenario the localization is performed in. This includes the assumption
that many nodes are deployed in a relatively dense space which simplifies the problem with communication coordination explained 
earlier.

The assumptions make it difficult to adopt the localization system proposed by Gotthard et al. for general use but they investigate
promising ideas which hopefully can be integrated into localization systems in the future to reduce their power consumption.

== Similar Work <similar_work>

Fargas et al. evaluate LoRa for use in an alternative GPS-free geolocation system @fargas_gps-free_2017.
Their proposed approach for localization with LoRa signals is based on precise measurements of the
Time of Arrival (ToA) of one packet at multiple LoRa gateways (anchor node). They then calculate the time difference of
the different ToA timestamps and estimate the distance between the end node and each gateway by using the
propagation velocity of radio waves, which is the speed of light. These distances are then combined by a
multilateration algorithm to estimate the position of the end node.

#figure([
    #image("assets/fargas-gw-endnode-multilateration.png", width: 70%)
    #metadata("Reprinted, with permission, from Bernat Carbonés Fargas, GPS-free geolocation using LoRa in low-power WANs, 2017 Global Internet of Things Summit (GIoTS), June 2017") <reference>
    ],
    caption: "Position estimation with multilateration algorithm © 2017 IEEE"
)

Fargas et al. also showed in their work, that by using the Generalized ESD test for detecting and eliminating outliers in
the distance measurement data, they could improve the accuracy of the position estimation.

The idea of GPS-less localization is further advanced by Mackey et al. in @mackey_lora-based_2019 where they evaluate LoRa as alternative localization system
for Emergency Services. Instead of using the TDoA method for localizing the end node, they employ RSSI-based localization. For this they
use an Arduino Uno microcontroller together with the Dragino LoRa v1.3 Shield, which both are readily available off-the-shelf hardware components.
They evaluate their implementation on a soccer field of #text_qty("200", "m") #sym.times #text_qty("120", "m") where they achieve positioning accuracies
up to #text_qty("9", "m").

In @dieng_outdoor_2019 Dieng et al. use RSSI-based LoRa Localization to track individual animals of a cattle herd to better deal with livestock theft.
Their solution is based on a hybrid localization approach where they use both GPS and LoRa RSSI measurements to estimate the positions of the
individual animals. They deploy hybrid nodes, nodes equipped with both LoRa and GPS, and LoRa-only nodes. The hybrid nodes are used to
continuously improve the RSSI-distance model over time by correlating their GPS position with the current distance estimated by the RSSI-distance
model.

In @gotthard_low-cost_2018 Gotthard et al. evaluate RSSI-based LoRa localization as asset tracking system for large used car dealerships. They
present a novel variant of RSSI-based localization where end nodes only send "ping" messages between one another. The RSSI acquired from these "pings"
are transmitted to a central server, where they can be combined to approximate the position of the individual end nodes. Through this mechanism their
proposed system does not require any anchor devices.

== Contribution of this Thesis
As shown in @similar_work multiple implementations of LoRa localization exist already. This thesis focuses
on the implementation of a LoRa localization system implemented with already available off-the-shelf components.
The implemented localization system uses a range-based algorithm for position estimation. The distances needed
for that are estimated with the RSSI. This path is chosen because almost every receiver hardware has RSSI measurement
capability and is therefore widely accessible.

The goal of this thesis is to evaluate the feasibility of RSSI-based LoRa localization with the implemented localization system.
For that the performance of the distance and the position estimation are evaluated and the power consumption of the system is measured.

= Principals
This section presents the fundamental theory needed for implementing and evaluating RSSI-based localization systems with LoRa. 

== Path-Loss Model <path_loss_model>
To estimate distances based on the RSSI measured at the receiver a relation between RSSI and distance needs to be
established. This relation is commonly modeled as the power loss experienced by the transmitted signal over distance.
This is based on the assumption that the average power of a radio signal decays with the distance from the transmitter
according to some deterministic attenuation law @zanella_best_2016[p.~2]. This model is called Path-Loss Model (PLM).

Multiple Path-Loss Models exist in the literature @griva_lora-based_2023 @bianco_lora_2021 @stusek_accuracy_2020. For
this thesis the most basic model is used. This model is derived from the equation for received power (in [dBm]).

$ P_"rx" (t,s) = D(d) + Psi(s) + a(t) $

In this equation $D(d)$ is the deterministic component of the received power at distance $d$, while $Psi(s)$ and $a(t)$ model
the random variation in space and time. The relation $D(d)$ can be modeled further as:

$ D(d) = P_0 - 10n dot log_10 (d/d_0) "   " forall d >= d_0 $

As can be seen $D(d)$ is only defined for distances $d$ greater then $d_0$. $d_0$ is the reference distance at which
the initial received power $P_0$ can be measured. The factor $n$ is called the path-loss coefficient. It mainly influences 
the slope with which the model predicts the attenuation of the received power over distance @zanella_best_2016[pp.~5-7].

For this thesis $Psi(s)$ and $a(t)$ are assumed as neglible and therefore the received power or RSSI is only modeled dependent on $D(d)$:

$ "RSSI"(d) = P_0 - 10n dot log_10 (d/d_0) "   " forall d >= d_0 $ <eqn:rssi>


== Multilateration <multilateration>
Multilateration is a range-based position estimation algorithm to determine an unknown position. For this the distances between the node
with unknown position (end node) and nodes with known positions (anchor nodes) are measured. At least three of these distances must
be known to localize the end node.

The algorithm can be visualized by drawing circles, each with the measured distance at the anchor
as radius, around the positions of the anchors. The position of the end node is estimated by the point of intersection of all
the circles. In a perfect scenario this single point of intersection would exist, but in a real-world scenario the distance measurement
always includes an error. Due to this error the circles all intersect at different points. These points describe an area in which the real
position of the end node must be located.

#figure(
    image("assets/multilateration.svg", width: 80%),
    caption: "Position estimation error with multilateration"
)

To solve the multilateration problem algebraically the formulas for the circles are combined to form a system of equations.
For the special case of three points $P_1(x_1, y_1), P_2(x_2, y_2), P_3(x_3, y_3)$ with corresponding
distances $d_1, d_2, d_3$ the resulting system would look like this:

$ (x - x_1)^2 + (y - y_1)^2 &= d_1^2 \
  (x - x_2)^2 + (y - y_2)^2 &= d_2^2  \
  (x - x_3)^2 + (y - y_3)^2 &= d_3^2 $

This system can also be represented with matrices:
#set math.mat(delim: "[", column-gap: 1em)
$ mat(1, -2x_1, -2y_1;
      1, -2x_2, -2y_2;
      1, -2x_3, -2y_3;
)

mat(x^2 + y^2;
    x;
    y;
)

mat(d_1^2 - x_1^2 - y_1^2;
    d_2^2 - x_2^2 - y_2^2;
    d_3^2 - x_3^2 - y_3^2;
)
$

In this form the general equation for an arbitrary amount $n$ of anchor nodes $a_n$
and distances $d_n$ can be expressed as follows:
$ mat(1, -2x_1, -2y_1;
      1, -2x_2, -2y_2;
      1, -2x_3, -2y_3;
      dots.v, dots.v, dots.v;
      1, -2x_n, -2y_n;
)

mat(x^2 + y^2;
    x;
    y;
)

mat(d_1^2 - x_1^2 - y_1^2;
    d_2^2 - x_2^2 - y_2^2;
    d_3^2 - x_3^2 - y_3^2;
    dots.v;
    d_n^2 - x_n^2 - y_n^2;
)
$

The derivation and solution of this system of equations is explained in more
detail in @norrdine_algebraic_2012

= Implementation <implementation>
In the scope of this thesis a simple RSSI-based LoRa localization system was implemented. This system and the decisions which led
to the final design are presented in this section. For the sake of conciseness from now on the term "localization system" references,
where the context does not say otherwise, the localization system that was implemented for this thesis.

== System Overview
The localization system implemented for this thesis consists of multiple components. Some of them have physical other have only logical boundaries.
The following graphic illustrates the localization system as a whole and gives a quick overview.

#figure(
    image("assets/system-overview.svg", width: 65%),
    caption: "LoraLocator system overview"
)

The graphic shows that there are two different types of devices Anchor nodes and End nodes. These serve different purposes in the localization system.
The End node is the device which position should be localized. The Anchor nodes serve as fixpoints for the measurements taken to estimate the position of the 
End node. The system which was implemented and evaluated in this thesis consists of three Anchor nodes and one End node.
In-depth explanations of the individual components that make up one Anchor or one End node follow in the subsequent sections of this chapter.

== Hardware
Both device types of the localization system are built with the same hardware and differ only in firmware. Every device consist of a NUCLEO-WL55JC
@noauthor_nucleo-wl55jc_nodate this is a evaluation board for the the STM32WL55JC microcontroller @noauthor_stm32wl55jc_nodate developed and manufactured by
STMicroelectronics (ST) @noauthor_stmicroelectronics_nodate. This board features LoRa transceiver, an integrated programmer and debugger, connectors for the GPIO pins
of the microcontroller and easy power supply over Micro-USB. This solution was chosen for several reasons. Most important is of course that the hardware satisfies
the basic requirements imposed by the goal of this thesis to implement and evaluate a mobile RSSI-based LoRa localization system. This criterium is fulfilled by 
the NUCLEO-WL55JC evaluation board because it provides an integrated LoRa transceiver with built-in RSSI measurement and promises comparatively low power consumption
in the datasheet @noauthor_stm32wl55xx_2022.
Another reason for which the NUCLEO-WL55JC was chosen is the benefit of using prebuilt hardware with a big ecosystem like that of ST. This allows for rapid prototyping
by focusing development work on the parts where this localization system differs from previous implementations and reusing boilerplate code where possible. One such part
is _SubGHz_Phy_ @noauthor_an5406_2022[pp.~25-27] which is a driver for the LoRa transceiver of the STM32WL55JC.

#figure(
    caption: "NUCLEO-WL55JC",
    image("assets/nucleo.jpg", width: 39%),
)

== Firmware
The firmware for the NUCLEO-WL55JC board was written in the programming language C and utilizes prebuilt drivers and libraries provided by STMicroelectronics. 
The source code was managed with the version control system _git_ and uploaded to _GitHub_ @schmiedel_moseschmiedellora-locator_2024.

The implementation of the firmware is based on the _SubGhz_Phy_PingPong_ example application provided by STMicroelectronics @noauthor_an5406_2022[pp.~44-46].
The following graphic illustrates the individual logical components the firmware is made of.

    #figure(
        caption: "Firmware architecture",
        cetz.canvas({
            import cetz.draw: *
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

The main component of the firmware is the _LoraLocator_ application. It controls all the other components and implements the logic
that is needed for estimating the position of an End node.

=== Conditional compilation
As described earlier, the firmware of the Anchor node and the End node differ because they 
both fulfill different tasks in the localization system. Despite there differences these also share some similarities especially in the way the both 
process incoming and outcoming communication data via LoRa. To avoid unnecessary code duplication both the firmware for the Anchor node and for the End node
share the same codebase and node type specific code sections are conditionally included upon compilation depending on which device type was selected via 
preprocessor macros. For this purpose there are three macro definitions which must be configured when compiling the firmware.

#figure(caption: "Device type and ID configuration")[
    #sourcecode[
```c
// 1=is anchor node; 0=is not anchor node
#define IS_ANCHOR_NODE 1

// 1=is end node; 0=device is not end node
#define IS_END_NODE 0

// unique device identifier
//   - end node: numeric as uint8_t
//   - anchor node: alphabetical as char
#define DEVICE_ID 'A'
```
    ]
]

These three macro definitions are then used inside macro conditionals which control which part of the source code is included in the firmware build. Following
code snippet demonstrates a use of a macro conditional.
#figure(caption: "Device type specific code compilation")[
    #sourcecode[
```c
#if IS_ANCHOR_NODE==1 && IS_END_NODE==0
// Anchor node specific code goes here...
#elif IS_ANCHOR_NODE==0 && IS_END_NODE==1
// End node specific code goes here...
#else
#error "Set atleast/only one of IS_ANCHOR_NODE and IS_END_NODE to 1."
#endif
```
]
]

=== Application state machine
The driving design concept of the LoraLocator application is the finite state machine. The current state is tracked by the `node_state` variable, state changes are
performed by the event handlers and the logic executed in a specific state is handled by the core application function `LoraLocator_Process()`.
// TODO insert state machine

All application specific state is centralized and managed with a fixed amount of memory. All variables needed can be found at
the top of the file `lora_locator_app.c` @schmiedel_moseschmiedellora-locator_2024.

#figure(caption: "Track last performed action")[
    #sourcecode[
```c
typedef enum {
    NODE_STATE_INIT,
    NODE_STATE_INTERVAL_START,
    NODE_STATE_RX_END,
    NODE_STATE_TX_END,
} NodeState_t;

static NodeState_t node_state = NODE_STATE_INIT;
```
]
]

The variable `node_state` is used in the core application function `LoraLocator_Process()` to determine the last action that was performed before 
the core function was called. The possible node states are:
/ NODE_STATE_INIT: State the application is in after initialization. Start of the application lifecycle. 
/ NODE_STATE_INTERVAL_START: State after the main application interval was triggered. `Ping_t` is transmitted or received depending on 
    device type.
/ NODE_STATE_RX_END: State after node was receive mode. The received packet is decoded and the next action is triggered
    depending on device type, received packet type and if reception was successful.
/ NODE_STATE_TX_END: State after node was transmission mode. Next action is triggered
    depending on device type, transmitted packet type and if transmission was successful.

The following listing shows how the behavior of the core function is dependent on the state recorded in the `node_state` variable.

#figure(caption: "Execute logic depending on last performed action")[
    #sourcecode[
```c
void LoraLocator_Process(void) {
    switch(node_state) {
    case NODE_STATE_INIT: {
    // execute NODE_STATE_INIT logic and trigger next action
    }break;
    case NODE_STATE_INTERVAL_START: {
    // execute NODE_STATE_INTERVAL_START logic and trigger next action
    }break;
    case NODE_STATE_RX_END: {
    // execute NODE_STATE_RX_END logic and trigger next action
    }break;
    case NODE_STATE_TX_END: {
    // execute NODE_STATE_TX_END logic and trigger next action
    }break;
    }
}
```
]
]

As mentioned before, all state changes occur in event handler functions. These are subroutines that are called when some kind of event occurs, for example 
when a LoRa transmission is successfully terminated. The functions are passed as function pointers to a hardware driver or some other event-based component.
The component receiving the event can then delegate the handling of the event to the function defined by the programmer by calling it via the provided
function pointer.

#figure(caption: "Pass function pointer to radio driver for event handling")[
    #sourcecode[
```c
static RadioEvents_t RadioEvents; 
...
RadioEvents.TxDone = &OnTxDone;
RadioEvents.RxDone = &OnRxDone;
RadioEvents.TxTimeout = &OnTxTimeout;
RadioEvents.RxTimeout = &OnRxTimeout;
RadioEvents.RxError = &OnRxError;

Radio.Init(&RadioEvents);
```
]
] <event_handler_config>

In the next listing the definitions of all event handlers used in the _LoraLocator_ app are listed. Note the usage of the prefix `On`, followed
by a description of an event, to signal that the function is called when the specified event occurs. 

#figure(caption: "List of event handlers used in LoraLocator")[
    #sourcecode[
```c
// interval_timer elapsed
static void OnIntervalEvent(void *context);

// listen_timer elapsed
static void OnListenEndEvent(void* context);

// Transmission done
static void OnTxDone(void);

// Timeout triggered while transmitting
static void OnTxTimeout(void);

// Timeout triggered while receiving
static void OnRxTimeout(void);

// Error occured during reception
static void OnRxError(void);
```
    ]
]

To complete the implementation of the application state machine the state stored in the
`node_state` variable must be changed in order to accomplish a transition from one
state to another. This is done in the event handler functions by setting the 
state via the helper function `SetState(NodeState_t next_state)` and calling
`QueueLoraLocatorTask()` to signal the scheduler to run the `LoraLocator_Process()`
function again. The corresping code can be found in the listing below on lines 5 and 6.

#figure(caption: "Example state change in transmission-done event handler")[
    #sourcecode[
```c
static void OnTxDone(void) {
    State = TX;
    switch (tx_result.packet_type) {...} // store and log transmitted packet
    tx_result.state = RESULT_OK;
    SetState(NODE_STATE_TX_END);
    QueueLoraLocatorTask();
}
```
    ]
]

=== Hardware Drivers
To develop firmware for the STM32WL55JC microcontroller the hardware drivers developed by STMicroelectronics were used.
They provide an abstraction layer over the hardware so that the programmer can access hardware functionality via high level
functions instead of configuring the peripheral registers themselves. This abstraction layer has the very creative name HAL, which stands for
#bold_txt[H]ardware #bold_txt[A]bstraction #bold_txt[L]ayer. Its documentation can be found here @noauthor_um2642_2022.

For controlling the integrated LoRa transceiver of the STM32WL55JC microcontroller the _SubGHz_Phy_ driver was used additionally. 
It already implements the most common used functionality like sending and receiving packets via LoRa and provides an easy to use
API with a single object `Radio` which is used to configure and control the radio transceiver. An example of how the event handlers
are configured was demonstrated earlier in @event_handler_config. Transmission and reception of LoRa packets can be triggered by 
calling methods of the global `Radio` object, demonstrated in the following listing.

#figure(caption: "Switch LoRa transceiver to transmission-/reception-mode")[
    #sourcecode[
```c
#define PAYLOAD_LEN 10
uint8_t tx_buffer[PAYLOAD_LEN];
Radio.Send(tx_buffer, PAYLOAD_LEN);

#define RX_TIMEOUT_MS 200
uint8_t rx_buffer[PAYLOAD_LEN];
Radio.Rx(rx_buffer, RX_TIMEOUT_MS);
```
    ] 
]

The code above transmits a payload of 10 bytes via a LoRa packet, as demonstrated in lines 1 to 3.
Lines 4 to 6 show how the transceiver can be configured to receive the transmitted packet.
Reception will fail after the time specified by `RX_TIMEOUT_MS`
which in this case would be #text_qty(200, "ms"). Of course, sending and receiving should be done by separate devices
at the same time for them to communicate successfully.

A more detailed explanation of how to build LoRa applications with the _SubGHz_Phy_ driver and the documentation of the all
available methods can be found in here @noauthor_an5406_2022.

=== Utilities
Several utility modules distributed by STMicroelectronics were used to simplify the firmware development process.
They helped reduce the amount of boilerplate code, i.e. source code required for basic project setup that has
little variation between different projects. @firmware_architecture lists all the utility modules used for the final
firmware. This section briefly introduces the two most influential modules.

#v(0.4em)
The firmware uses the *Sequencer* module to schedule the execution of the `LoraLocator_Process()` function.
This allows the event handler functions, which are often executed in an interrupt context, to indirectly call the
core function and leave the interrupt context quickly. The documentation of the Sequencer module can be found here @noauthor_utilitysequencer_nodate.

#figure(caption: "Sequencer task registration")[
    #sourcecode[
```c
UTIL_SEQ_RegTask(
    (1 << CFG_SEQ_Task_SubGHz_Phy_App_Process),
    UTIL_SEQ_RFU,
    LoraLocator_Process);
```
    ] 
]
#figure(caption: "Helper function to schedule task execution")[
    #sourcecode[
```c
static void QueueLoraLocatorTask() {
    UTIL_SEQ_SetTask(
        (1 << CFG_SEQ_Task_SubGHz_Phy_App_Process),
        CFG_SEQ_Prio_0);
}
```
    ] 
]

Basic timing functionality is implemented in the _LoraLocator_ application with the *Timer server* module. This module allows
to create an arbitrary amount of independent timers. A timer generates a timeout event and calls a provided event handler function
after a fixed amount of time provided upon creation. The time is specified in Milliseconds. Unfortunately no official documentation
could be found for this module but most important functionality can be understood by directly reading the source code @noauthor_lora-locatorutilitiestimerstm32_timerc_nodate.

#figure(caption: "Timer creation")[
    #sourcecode[
```c
/* Timer that triggers `LoraLocator_Process` periodically to either transmit a `Ping_t` (end node) or listen for a `Ping_t` (anchor node). */
static UTIL_TIMER_Object_t interval_timer;
...
UTIL_TIMER_Status_t timer_result = UTIL_TIMER_Create(
        &interval_timer,      // timer object
        INTERVAL_PERIOD_MS,   // timeout value
        UTIL_TIMER_PERIODIC,  // timer mode (ONESHOT=run once and stop,
                              // PERIODIC=run and restart until stopped)
        &OnIntervalEvent,     // callback function to call when timer elapses
        NULL);                // argument passed to callback function

if (timer_result != UTIL_TIMER_OK) {
    // handle timer creation error
    APP_LOG(TS_ON, VLEVEL_M, "Could not create interval timer.\n\r");
}
```
    ] 
]
#figure(caption: "Start timer with specified timeout value")[
    #sourcecode[
```c
UTIL_TIMER_StartWithPeriod(&interval_timer, INTERVAL_PERIOD_MS);
```
    ] 
]

== Distance Estimation and Localization
In order to estimate the position of an end node by trilateration, it is necessary to determine the distances between the end node and 
at least three anchor nodes. As stated in the thesis title and in preceding chapters, the implemented localization system utilizes
RSSI measurements to estimate these distances. For this to work the end node periodically transmits LoRa packets of type `Ping_t`.

#v(1em)
#stack(dir: ltr,
    spacing: 10pt,
figure(caption: "`Ping_t` transmission")[
    #align(center)[
    #cetz.canvas({
        import cetz.draw: *
        scale(50%)
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
        label(("ping_line.start", 60pt, "ping_line.end"), angle: "ping_line.end", [`Ping_t`], name: "ping_label")

        label("end_node.south-east", padding: (left: 50pt, top: 20pt), [End node], name: "end_node_label")
        label("anchor_a.north-west", padding: (right: 10pt, bottom: 20pt), [Anchor A], name: "anchor_a_label")
        label("anchor_b.north-east", padding: (left: 10pt, bottom: 20pt), [Anchor B], name: "anchor_b_label")
        label("anchor_c.south-west", padding: (top: 20pt), [Anchor C], name: "anchor_c_label")

        hide(bounds: true, {
            rect((-6,-4.4), (6,4.35))
        })
    })
    ]
],
figure(caption: "Packet type `Ping_t`")[
    #sourcecode(
        frame: it =>
            block(width: 260pt,
                fill: luma(250),
                stroke: .6pt + luma(200),
                inset: (x: .45em, y: .65em),
                radius: 3pt,
                clip: false,
                breakable: true,
                it
            )
    )[
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
)
#v(1em)

An anchor node receiving a `Ping_t` responds to it by transmitting an `AnchorResponse_t` which includes the RSSI measured by the anchor node
while receiving the `Ping_t`.

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

During the transmission of the `AnchorResponse_t` a collision could occur which hinders the end node from decoding
the packet. This happens when multiple anchor nodes start transmitting its response almost at the same time. To detect when this is happening
another packet type `Ack_t` is introduced. An anchor nodes always expects an end node to respond to an successful `AnchorResponse_t` with
an `Ack_t`. If the anchor node does not receive this `Ack_t` in a configurable amount of time it retries sending the `AnchorResponse_t`.
The maximum of retries can also be configured via the macro `MAX_ANCHOR_RESPONSE_RETRIES`, which defaults to 3. When this number of
retries is reached the anchor node gives up and goes to sleep until it receives the next `Ping_t`.

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

The end uses the decoded RSSI value `recv_rssi` from an successful `AnchorResponse_t` to calculate the distance between
itself and the anchor node with a path-loss model. The chosen path-loss model is the log-normal model which is explained in more detail during the
evaluation of the distance estimation in @distance_evaluation. The estimated distances can then be combined to calculate a position relative
to the positions of the anchor nodes by employing the trilateration algorithm or its generalization the multilateration algorithm. These
algorithms are explained in @multilateration. To obtain a absolute position the relative position can be added to the absolute position of an
anchor node.

#v(.4em)
The rest of this section demonstrates the architectural design decisions of the localization system
by highlighting some of the key features of the chosen implementation.

A significant feature of this localization system is the amount of control the end node can exert. Because the whole system 
relies on the periodic `Ping_t` packets of the end node, it can effectively regulate the frequency with which measurements are taken.
This frequency is referred to as tracking rate. This equips the end node with a mechanism to increase or reduce the localization
precision on demand, which is useful in a situation where the velocity of the end node changes. In this scenario the end node could
increase the tracking rate while traveling at a high velocity and subsequently reduce the tracking rate, thereby lowering power consumption,
when traveling at a low velocity.

Another benefit of the end node transmitting the `Ping_t` packets, is that multiple anchor nodes can receive
the same `Ping_t`. This mitigates the impact of variations in the transmitter circuit or other undesired
environmental influences on the localization process.

The main drawback of this approach is the amount of transmitted packets. In comparison to the distance estimation approach implemented by
Bluetooth Low Energy beacons @faragher_location_2015 @qamaz_experimental_2022, this implementation needs twice as much packets for a single
localization cycle. This is because with the BLE approach the anchor nodes periodically send short packets which are received by the end node
and are used to estimate the distances between itself and the anchor nodes without the need for reponse to the ping message. 

Despite this drawback, the benefits would enable some interesting advantages over existing solutions. For this reason this localization
method was chosen for the evaluated system.

= Evaluation
In this chapter two experiments, conducted for evaluating the performance of the implemented localization system, are presented and
the resulting data is discussed.

== Distance Estimation <distance_evaluation>
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
#let dist_best_exp = {
    csv("data/02_1.csv", row-type: dictionary)
       .map(row => (distance_m: float(row.distance_m),
           recv_rssi_dbm: float(row.mean_rssi_dbm),
           experiment: row.experiment,
           estimated_distance_m: float(row.estimated_distance_m),
           error_dist_m: float(row.error_dist_m),
       ))
}

The distance estimation was evaluated with two devices, an anchor and an end node. As previously described, the end node periodically
sent `Ping_t` packets which the anchor node responded with `AnchorResponse_t` packets which included the RSSI values it measured.
These measurements were taken at different distances. At each distance multiple measurements were performed so that the average RSSI
value per distance can be calculated to reduce the impact of RSSI variations. The measured distances reached from #text_qty(5, "m") to
#text_qty(50, "m") and were measured with a tape measure. The end node and the anchor node were mounted on two wooden poles at approximately
#text_qty(1.5, "m") above the ground with the antennas parallel to each other.

To also measure larger distances, the experiment setup was slightly modified. Instead of using a tape measure as reference for the distance, 
the iOS-App "GPS Tracks" @noauthor_gps_2024-1 was used. With it the position of the anchor node was recorded as a waypoint. All distances
of the end node were then measured relative to this waypoint. The collection of the RSSI measurements stayed the same. This setup was
used to measure distances in a range from #text_qty(10, "m") to #text_qty(160, "m").

The recorded data is openly accessible and can be found in the GitHub repository of this thesis @schmiedel_moseschmiedelbachelor-thesis_2024.

#figure(
    caption: "Distance estimation setup at multiple distances",
    stack(
        dir: ltr,
        spacing: 10%,
        image("assets/dist_exp_long.jpg", width: 37%),
        image("assets/dist_exp_short.jpg", width: 37%),
    )
)
#v(-1em)
The devices that were used for the experiments were described previously in @implementation. For all experiments the LoRa transceiver
was configured with following parameters.
#figure(
    caption: "LoRa transceiver configuration",
    table(
        columns: (auto, auto),
        align: (left, center),
        inset: 8pt,
        table.header([*Parameter*], [*Value*]),
        [Frequency], text_qty(868, "MHz"),
        [Bandwidth], text_qty(125, "kHz"),
        [Spreading Factor], [7],
        [Coding Rate], [4/5],
        [Preamble Length], [8],
        [Output Power], text_qty("+14", "dBm"),
    )
)

/*
 * 1 methodology
    - RSSI measured at different distances+
    - multiple measurements per distance (ca. 80) #sym.arrow.r
 * 2 explanation of data analysis
    - calculate average RSSI
    - log-distance model must be fitted
 * 3 presentation of all results
 */

=== Data Analysis
Multiple experiment runs where performed to evaluate the distance estimation method presented in this thesis.
Based on @eqn:rssi empirical models to estimate the distance from a measured RSSI value were built with
the data of each run. The following table shows the maximum and relative error for each experiment run.
The relative error was obtained by calculating the average of the differences between actual and estimated distance divided
by the actual distance.

$ e_"r" (d_"actual") = (d_"estimated" - d_"actual") / d_"actual" $

The maximum error is simply the maximum value of the absolute distance differences.

$ e_"max" = max({|d_"estimated" - d_"actual"|  | forall d_"estimated", d_"actual" }) $


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
                [*ID*], [*Range*], [$bold(n)$], [$bold(P_0)$], [*$bold(mu(e_"r"))$*], [*$bold(sigma(e_r))$*], [*$bold(e_max)$*]
            ),
            ..results.flatten()
        )
    }
) <dist_results>

To evaluate the data recorded during the experiments, the Log-Normal path-loss model of
each dataset was calculated. This model was previously explained in @path_loss_model.
To apply this model for distance estimation the values for $n$ and $P_0$ had to be determined.
The RSSI equation of the PLM can be expressed as a linear function
depending on the logarithm of the distance.

$ "RSSI"(d) = P_0 - 10 n dot log_10 (d/d_0) $
$ y = a x + b $
$ y = "RSSI"(d)," "a = -10 n," "x = log_10 (d/d_0)," "b = P_0 $

Because of this expression of the Log-Normal model equation as a linear function, the
coefficients could be determined by using linear regression to find $a$ and $b$. These
are directly proportional to the unknown coefficients of the model.
With the determined coefficients the Log-Normal model equation could be rewritten
to obtain a function from RSSI to the distance $d$.
Assuming that the distance $d_0$ at which $P_0$ is the measured power is #text_qty(1, "m")
following statement is true.

$ d("RSSI") = 10^(("RSSI" + 10 n) dot 1 / P_0) $

This formula was then used as an distance estimator. Note that altough the estimator
function would take any real number as RSSI value, the measurement circuit of the LoRa transceiver only
provides integer RSSI values. This means that the same RSSI value can be measured
at different distances. In the following figures the results from two different experiments
is plotted as a function from RSSI to distance. Both the measured and the estimated distance
are included in the graph

#figure(
    caption: "RSSI vs. Distance data from experiment 02_1",
    image("assets/02_1.svg", width: 80%)
)

#figure(
    caption: "RSSI vs. Distance data from experiment 07",
    image("assets/07.svg", width: 80%)
)

This visualization indicates, that the sensitivity of this distance estimation approach
decreases the further away the end node and the anchor node are. For example the distance
between the RSSI of #text_qty(-50, "dBm") and #text_qty(-51, "dBm") are #text_qty(6.32, "m").
The distance delta in which the same RSSI value is measured can be calculated with the following
equation.

$ Delta d("RSSI") = d("RSSI"-1) - d("RSSI") $

Despite this quantization effect arising from the hardware capabilities of the used LoRa transceiver,
the distance estimation function is not modified for further evaluations because the all RSSI values
used are the average result of multiple measurements.

=== Results <sec:dist_results>
The results of the distance estimation evaluation may look promising at first glance as the plotted
curves of the models fit the measured data quite well. But all models show high error deviation.
Also despite using the same experiment setup, the differences of the derived
coefficients of experiments 01_1 through 02_2 are also big. These observations both imply low
repeatability.

At last the data of experiment 07 shows an interesting pattern above #text_qty(80, "m"). The 
origin of this pattern could not be determined as part of this thesis. The pattern can also
be found in the data shown in @kwasme_rssi-based_2019[pp.~7-8].

== Localization
For the evaluation of the localization implementation the test setup was modified. On a 
large grass field (Rosental in Leipzig) three anchor nodes were setup on wooden poles
in three corners of the field. Their positions were chosen to maximize the area were communication with
all three anchors is possible. With the iOS-App "GPS Data Smart" @noauthor_gps_2024 the absolute
positions of the three anchors were measured.

After installing all three anchors, the end node was used to perform RSSI measurements at three different
positions. Again the actual position of the end node was measured with the previously mentioned iOS-App.
The RSSI readings were recorded for later evaluation.

=== Data Analysis
The actual positions of the anchor nodes and the end node were all measured with GPS.
This data was in latitude/longitude format. To further process the positions their
cartesian representation was needed. This conversion was performed based on the WGS-84
ellipsoid which is used for GPS @gisgeography_world_2015. After that for better readability
all positions were expressed relative to the position of Anchor A.

#let anchor_data = {
    csv("data/loc_anchors.csv", row-type: dictionary).map(row => (
        anchor_id: row.anchor_id,
        gps_position: (lat: row.gps_position_lat, long: row.gps_position_long),
        cart_position: (x: row.cart_position_x, y: row.cart_position_y),
        cart_rel_position: (x: row.cart_rel_position_x, y: row.cart_rel_position_y),
    )
    )
}
#let display_gps = ((lat: latv, long: longv)) => {
    align(left)[_latidude:_#h(1fr)$latv$\ _longitude:_#h(1fr) $longv$]
}

#let display_cart = ((x: xv, y: yv)) => {
    set-round(mode: "places", precision: 2)
    align(left)[_x:_ #h(1fr) #num(xv)\ _y:_ #h(1fr) #num(yv)]
}


#figure(
    caption: "Anchor positions",
    table(
        columns: (auto, 14em, auto, auto),
        align: horizon,
        table.header(
            [*Anchor ID*], [*GPS Position*], [*Cartesian Position (based on WGS 84)*], [*Cartesian Position (rel. to Anchor A)*],
        ),
        ..{
            anchor_data.map(row => (align(center+horizon, row.anchor_id), display_gps(row.gps_position), display_cart(row.cart_position), display_cart(row.cart_rel_position)))
        }.flatten()
    )
)

The localization data was evaluated with the models of the two best distance estimations.
For that the average RSSI value for every anchor at each position was determined.
This was then used with the distance estimator to obtain the distances from the end node
to each anchor node. With these distances the trilateration (multilateration with three
distances) algorithm was used to estimate the position of the end node. Following
table shows the data collected in the localization experiments and the associated estimated
positions. Most distance estimations led to not enough circles intersecting which makes a position
estimation impossible.

To accommodate for the uncertainty of the distance estimation, the 
multilateration algorithm was also slightly modified. Instead of calculating the point
where all circles intersect it now just calculates the pairwise intersection points.
Each pairwise intersection could results in two points, so a strategy to choose one
of them must be provided. The first point is chosen by calculating the distance
of both points to the third anchor node that was not involved in the intersection.
The point with the lower distance is chosen as starting point. After that always
the point with lower distance to all already chosen points is included. The
result can be seen in @loc_pos2.


#let pos_agg = {
    json("data/pos_agg.json")

}

#let rows = {
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
            for (exp, exp_results) in pos_agg {
                rows.push(
                    table.cell(exp, rowspan: 9)
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
        ..{rows}.flatten()
    )
)
/*
 * 1 methodology
    - define Anchor A as (0,0)
 * 2 explanation of data analysis
    - measure distances between Anchors and calculates cartesian coordinates with haversine formula
 * 3 presentation of all results
 */

#move(dx: 0pt, dy: -20pt)[
#stack(dir: ttb,
    spacing: -.5em,
    [#figure(
        caption: "Localization of position 1",
        stack(dir: ltr,
            spacing: -80pt,
            image("assets/exp02_1_pos1.svg", width: 80%),
            image("assets/exp07_pos1.svg", width: 80%),
        )
    ) <loc_pos1>],
    [#figure(
        caption: "Localization of position 2",
        stack(dir: ltr,
            spacing: -80pt,
            image("assets/exp02_1_pos2.svg", width: 80%),
            image("assets/exp07_pos2.svg", width: 80%),
        )
    ) <loc_pos2>],
    [#figure(
        caption: "Localization of position 3",
        stack(dir: ltr,
            spacing: -80pt,
            image("assets/exp02_1_pos3.svg", width: 80%),
            image("assets/exp07_pos3.svg", width: 80%),

        )
    ) <loc_pos3>]
)
]

=== Results
The evaluation of the localization data shows that the distance estimator is too inaccurate to be useable
for position estimation. As concluded in @sec:dist_results, the distances estimated for RSSI values at
high distance deviate significantly from the actual distances. This likely originates in the fluctuations
of the RSSI signal at high distances and therefore lower fit of the model for these distances.
Additional to this conclusion another problem in the repeatability between different devices can be observed.
Instead of showing similar deviation from the actual position, the accuracy of the distance estimation varies
largely between different anchor nodes. For example in @loc_pos3 experiment 07 the actual position of the end
node is chosen so that every anchor node has similar distance from the end node. This leads to the assumption
that all estimated distance show similar error characteristics. But while the distance estimated from Anchor C
is very accurate, both Anchor A and B show large deviation from the actual distance.

All these observations lead to the conclusion that the localization system cannot provide reliable positioning data
despite being able to estimate a position in @loc_pos2 experiment 07.

== Low Power
To estimate the power consumption of the implemented localization system. The current drawn at a fixed voltage
(#text_qty(5, "V")) of one node was measured in different operating modes. This measurement was conducted
by connecting a multimeter in series with lab bench power supply and the device. The power supply was configured
to provide a fixed voltage of #text_qty(5, "V"). Special firmware with hardcoded operating modes was used
to eliminate as much other influences as possible.
#v(-.2em)
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
#v(-1.4em)
It can be seen that the power consumption of one node is quite low. If we assume that the node transmits two packets
per second, listens for incoming packets for #text_qty(400, "ms") and sleeps for the rest of the time, following 
average power consumption can be calculated. $T_"tx"$ is the time one packet needs to be transmitted. For all
packets in the implemented system this time is approximately #text_qty(40, "ms").

$ P_"total" = P_"tx" + P_"rx" + P_"sleep" $
$ P_"tx" = (2 dot T_"tx") / qty("1000", "ms") dot qty("135", "mW") $
$ P_"rx" = qty("400", "ms") / qty("1000", "ms") dot qty("42.5", "mW") $
$ P_"tx" = (1000 - (2 dot T_"tx" + qty("400", "ms"))) / qty("1000", "ms") dot qty("14.5", "mW") $
$ P_"total" = qty("30.7", "mW") $

With a battery capacity of #text_qty(40000, "mWh") (LiPo battery with #text_qty(10000, "mAh")) the lifetime of the
system would be #text_qty(1303, "h") or 54.3 days.

= Future Works
As stated in the goal of this thesis a localization system based on RSSI measurements for LoRa was implemented and
evaluated. The implementation presented the design decision necessary for building a localization system. These included
for example the importance of communicating the reception of a packet sent by an anchor node and the benefits of
triggering the localization by a packet sent by an end node.

The evaluation of this localization system showed that the possibility to fit models for distance estimation based on
RSSI exists but refinement has to be done to use the distance estimation models for position estimation.

These refinements could not be explored as part of this work but some clues from the evaluation allow to
draw some assumptions where those refinements would likely be most impactful.

#v(.4em)
The first refinement that should be considered is the repeatability of the distance estimation. This could
possibly be improved by increasing the distance range measured. For this the measuring process could
also be improved to increase the amount of gathered data. This could for example be achieved by replacing the
absolute position measurement using the mobile phone, with a GPS receiver integrated in the testing devices.
This receiver could be sampled in addition to the RSSI measurements.
#v(.4em)
Following work should also consider increasing the sample size of the measuring devices. Due to manufacturing limitations
minor variations in transmitting and receiving circuits exists. Maybe the effect of these variations on the estimated distance
could be observed and eliminated. 
#v(.4em)
When refining the RSSI distance estimation, one could also analyze the variations shown at higher distances. Finding the cause
and decreasing or even eliminating it, would possibly result in more accurate distance estimations and consequently better
position estimation.
#v(.4em)
Another possible optimization lies in the chosen path-loss model. This thesis only employed a single-slope model, but in
the literature models with two or more slopes exists @zanella_best_2016[p.~20]. This possibly could improve the
accuracy of the distance estimation by employing different curves at different distances.
#v(.4em)
Regarding the localization algorithm, other methods could be explored. Possibilities include the weighted LMS approach
by @el_agroudy_low_2016 which counteracts the error at high distances by introducing weights.


#show "LoRa": [LoRa]
]

#pagebreak()
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
        if refs.len() > 0 [
            #v(.1em)
            #h(indent)
            #box(width: 100% - indent, emph(refs.first().value))
        ]
    }
    #it
]

#show heading.where(level: 1): it => [
    #smallcaps(it)
]

#outline(title: "List of Figures", target: figure.where(kind: image))
#outline(title: "List of Tables", target: figure.where(kind: table))
#outline(title: "List of Listings", target: figure.where(kind: raw))

#pagebreak()
#bibliography("lora-ba-thesis.bib", style: "ieee")

#pagebreak()
#include "appendix.typ"
