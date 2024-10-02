#import "@preview/unify:0.6.0": qty

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

#show "LoRa": [LoRa#emoji.tm]

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

#show heading.where(level: 1): it => [
    #pagebreak()
    #smallcaps(it)
]
#show heading.where(level: 2): it => text(weight: 600, it)
#show heading.where(level: 3): it => emph(text(weight: 600, it))
#show figure: it => [
    #it
    #v(1em)
]


/***********
 * Helpers *
 ***********/

#let text_qty(number, unit) = text(spacing: 50%)[#number #unit]

#let sans = text.with(font: sans_font)
#let mono = text.with(font: mono_font)
#let bold = text.with(weight: "bold")


/*************
 * Titlepage *
 *************/
// Configuration
#let author = "Mose Schmiedel"
#let professor = "Prof. Jens Wagner"
#let supervisor = "Marian Ulbricht, M.Eng."
#let organization = "HTWK Leipzig"
#let date_raw = datetime(day: 16, month: 10, year: 2024)
#let date = "Octobre 2024, Leipzig"
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

#pagebreak()

_Abstract_

#v(3em)
_*Keywords:* #h(1em) #keywords.join([#h(.4em) #box(baseline: -42%)[#circle(radius: 1.8pt, fill: black)] #h(.4em)])_

#outline()

= Introduction

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
can be calculated.

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
required to achieve the before mentioned requirements for precision and synchronization of the time measurement.

=== Time Difference of Arrival
The strict time synchronization of anchor and end node is a requirement which is sometimes very difficult or even impossible to achieve in real world
implementations. In such circumstances, it could be required that end nodes can be deployed dynamically such that they are not always powered on and not
physically close to each other. These requirements add much complexity to the time synchronization process. One way to deal with this complexity is to avoid
it all together by improving the ToA-based distance measurement. Instead of using the ToF to estimate the distance between anchor and end node, the
time difference between the ToA of different anchors is used to calculate the differences of the distances between the anchors and the end node.
Through this optimization, time synchronization between anchor and end node is not required anymore, which decreases the complexity of the localization system.
The anchor nodes still need to be synchronized so that the differences between the different ToA can be used effectively.

Despite solving the time synchronization challenge of ToA-based localization, TDoA-based localization inherits many of the drawbacks of ToA-based localization.
The hardware used for TDoA-based localization still has to provide excellent resolution and drift properties.

=== Received Signal Strength Indicator
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

One goal of this thesis is to evaluate RSSI-based localization in a mobile application. This implies, for the above mentioned reasons, that the
evaluation of the resulting localization system must include some form of power consumption characterization.
To find and evaluate the real power characteristics of devices using LoRa communication technology, several studies were performed already.
Some of these works are presented in the following section.

In @el_agroudy_low_2016 El Agroudy et al. present an outdoor localization system based on RSSI with ZigBee. They evaluate the power consumption
of their implementation and find that it draws around #text_qty("30", "mA") in "Active mode" and #text_qty("6.7", "µA") in "Sleep mode". "Active mode"
is the system state in which communication and localization takes place while "Sleep mode" describes the state in which all system activity is lowered to 
minimum. El Agroudy et al. propose, based on the significant difference in current draw between "Active mode" and "Sleep mode", to reduce to amount of time
spent in the "Active mode" by implementing a periodic wake-up event which changes the system state from "Sleep mode" to "Active mode". With this approach
the total power consumption of the device can be configured by adjusting the time interval between the wake-up events.

// insert graph which illustrates wake-up interval and current draw in active and sleep mode

A challenge for this approach is that a device cannot receive any signals while in "Sleep mode". This challenge must influence the design of the localization
algorithm to ensure that communication between the devices in the localization system is possible. El Agroudy et al. resolve this issue by keeping the anchor node 
of their localization system always in "Active mode" so that it can coordinate the communication.



== Deployment
- smart campus @alves_introducing_2020
- coverage @rizzi_using_2017

== Similar work

Fargas et al. evaluate LoRa for use in an alternative GPS-free geolocation system @fargas_gps-free_2017.
Their proposed approach for localization with LoRa signals is based on precise measurements of the
Time of Arrival (ToA) of one packet at multiple LoRa gateways (anchor node). They then calculate the time difference of
the different ToA timestamps and estimate the distance between the end node and each gateway by using the
propagation velocity of radio waves, which is the speed of light. These distances are then combined by a
multilateration algorithm to estimate the position of the end node.

#figure(
    image("assets/fargas-gw-endnode-multilateration.png", width: 80%),
    caption: "Position estimation with multilateration algorithm © 2017 IEEE"
)

Fargas et al. also showed in their work, that by using the Generalized ESD test for detecting and eliminating outliers in
the distance measurement data, they could improve the accuracy of the position estimation.
They also shortly compared the current consumption of their test system with a GPS + GSM based device and found that their
device had significant lower current consumption and therefore could drastically decrease the power requirements for
devices with localization systems.

The idea of GPS-less localization is further advanced by Mackey et al. in @mackey_lora-based_2019 where they evaluate LoRa as alternative localization system
for Emergency Services. Instead of using the TDoA method for localizing the end node, they employ RSSI-based localization. For this they
use an Arduino Uno microcontroller together with the Dragino LoRa v1.3 Shield, which both are readily available off-the-shelf hardware components.
They evaluate their implementation on a soccer field of #text_qty("200", "m") #sym.times #text_qty("120", "m") where they achieve positioning accuracies
up to #text_qty("9", "m").
They also estimated the expected battery-life both of the transmitter and the receiver node and found that the transmitter
would possibly run up to 200 hours on a #text_qty("5000", "mAh") battery, but the receiver would only last about 90 hours with one battery charge.

In @dieng_outdoor_2019 Dieng et al. use RSSI-based LoRa Localization to track individual animals of a cattle herd to better deal with livestock theft.
Their solution is based on a hybrid localization approach where they use both GPS and LoRa RSSI measurements to estimate the positions of the
individual animals. They deploy hybrid nodes, nodes equipped with both LoRa and GPS, and LoRa-only nodes. The hybrid nodes are used to
continuously improve the RSSI-distance model over time by correlating their GPS position with the current distance estimated by the RSSI-distance
model.

In @gotthard_low-cost_2018 Gotthard et al. evaluate RSSI-based LoRa localization as asset tracking system for large used car dealerships. They
present a novel variant of RSSI-based localization where end nodes only send ping messages between one another. The RSSI acquired from these "pings"
are transmitted to a central server, where they can be combined to approximate the position of the individual end nodes. Through this mechanism their
proposed system does not require any anchor devices. They found that their system had an average error of #text_qty("4.71", "m") and that an individual
node could run for about 5 years powered by an #text_qty("800", "mAh") CR2 battery.

- RSSI-based LoRa localization for a low-cost car park localization implementation @gotthard_low-cost_2018.
- LoRa evaluated for use as communication technology for Emergency Services in off-grid environments @mackey_lora-based_2019.
- Evaluation of LoRaHarbor @priyanta_evaluation_2019
- lightweight boat tracking using LoRa technology @sanchez-iborra_tracking_2019
- LoRa-based mobile emergency management system (LOCATE) @sciullo_design_2020
- tracking of patients in elderly care @fernandes_hybrid_2020
  - indoor and outdoor


- RSSI-based LoRaWAN localization + evaluation of accuracy, impairments, and prospects with SDR (software-defined radio) @kwasme_rssi-based_2019
- low power RSSI outdoor using 868 MHz ZigBee @el_agroudy_low_2016
    - current consumption: 20mA in active mode, 6.7 uA in sleep-mode all at 3.3V -> receiver periodically wakes up to receive signals
- (indoor RSSI-based LoRa Localization in 2.4 GHz frequency band @vaishnav_design_2022)
- evaluation of using AoA measurement for LoRa Localization in the cloud @bnilam_angle_2022
- AoA-based (indoor?) LoRa Localization @ge_long-range_2024
- LoRaWAPS: wide-area positioning system based on LoRa Mesh @li_lorawaps_2023
- public outdoor LoRa network used for TDoA-based tracking @podevijn_tdoa-based_2018

== Challenges for LoRa Localization
@gu_lora-based_nodate
- multiple approaches
  - ToA or TDoA => time-based approach
    - needs specialized hardware
    - insufficient accuracy for range of applications
    - often need pre-trained models
  - RSSI => signal-strength approach
    - multipath effect
    - high fluctuations in RSSI measurements at equal distance

== Contribution of this Thesis
- implementation and evaluation of mobile localization tag using RSSI-based LoRa localization with off-the-shelf (OTS) components
    - RSSI measurement is implemented in nearly all receivers -> no dedicated hardware
    - accuracy loss due to multipath effect should not play a huge role in outdoor localization because of higher LOS (line-of-sight) component of the signal
- evaluation of the feasibility of a LoRa based localization system
    - accuracy
    - power consumption
    - frequency band usage

= Principals
This section presents the fundamental theory needed for implementing and evaluating RSSI-based localization systems with LoRa. 

== LoRa
As already stated LoRa is a radio technology proposed by SemTech and developed by the LoRa Alliance @vangelista_long-range_2015 which primary targets 


== RSSI-based distance estimation



== Multilateration <multilateration>
Multilateration is a position estimation algorithm which uses three or more distances between the node which position should be estimated
and nodes with known positions. The algorithm can be geometrically explained by drawing circles, each with the measured distance at the anchor
as radius, around the positions of the anchors. The position of the end node is estimated by the point of intersection of all
the circles. In a perfect scenario this single point of intersection would exist, but in a real-world scenario the distance measurement
always includes an error. Due to this error the circles all intersect at different points. These points describe an area in which the real
position of the end node must be located.

#figure(
    image("assets/multilateration.svg", width: 80%),
    caption: "Position estimation error with multilateration"
)

== Haversine formula
@gardiner_collision_2011

= Implementation
- usage of STM32 MCU with integrated LoRa transceiver
    - capable of RSSI measurement
    - low power consumption
    - pre-implemented LoRa radio software interface #sym.arrow.r ST provides example `SubGHz_PingPong`

== Distance estimation
- End node sends ping
```c
typedef struct {
    uint8_t device_id;
    uint8_t packet_id;
} EndNodeRequest_t;
```
- Anchor node responds with measured RSSI
```c
typedef struct {
    Device_t anchor_id;
    int16_t recv_rssi;
} AnchorResponse_t;
```
- experiment in park

== Localization
- ACK of distance measurement ping


= Evaluation
== Distance estimation
- log-distance model must be fitted
    - RSSI measured at different distances
    - multiple measurements per distance (ca. 80) #sym.arrow.r calculate average RSSI
    - 

#figure(
    image("assets/distance_experiment02_2.svg", width: 80%),
    caption: "Experiment #02-2 distance estimation"
)

== Localization
- define Anchor A as (0,0)
- measure distances between Anchors and calculates cartesian coordinates with haversine formula

= Future Works

#outline(title: "Figures", target: figure.where(kind: image))
#bibliography("lora-ba-thesis.bib", style: "ieee")

#include "appendix.typ"
