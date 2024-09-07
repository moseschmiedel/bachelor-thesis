#import "@preview/unify:0.6.0": qty

= State of the Art
LoRa and LoRaWAN were released as a radio communication technology to the public in 2015 by Semtech. 
Very early on it already received coverage in scientific media as it was introduced as a
promising long-range radio communication technology for IoT devices @vangelista_long-range_2015.

This section presents relevant literature correlating with mobile RSSI-based LoRa Localization.

== LoRa Localization
There a multiple approaches for localization in RF based communication networks. The most commonly
used all depend on one or more of four physical metrics of the received radio signal. These properties
are the angle of arrival (AoA), time of arrival (ToA), Time delay of arrival (TDoA) and received signal strength
(RSSI) @marquez_understanding_2023.

Localization systems which are based on the angle of arrival use a directed antenna array to measure the
angle at which the radio signal was received. When the exact distances between two anchor nodes are known, the position
of a third node, further called end node, can be estimated simply on basis of the SAS congruence theorem.
A slight variation of this method can be used when the distances between the anchor nodes is unknown. In this
case the AoA of at least three anchor nodes must be known. The position of the end node can now be estimated by
projecting lines from each anchor node with the measured AoA. The intersection of the lines represents the point or area
in which the end node must be located. The projected lines only intersect in a single point when the AoA measurements
are perfect i.e. the measurement has no error attached.
#block[
#align(center+bottom)[
#stack(dir: ltr, spacing: 20pt,
    figure(
        image("assets/angulation-2-nodes.svg", width: 45%),
        caption: "Angulation with two anchor nodes"
    ),
    figure(
        image("assets/angulation-3-nodes.svg", width: 45%),
        caption: "Angulation with three anchor nodes"
    )
)
]
]



Many different applications for LoRa/LoRaWAN were evaluated since its release. Because of the scope
of this thesis this section only covers previous work which include some kind of localization with LoRa.
The following section should not be regarded as a comprehensive list of all work including LoRa localization
concepts but rather be used as a short overview of different applications for which LoRa localization
was evaluated prior to this thesis.

Fargas et al. evaluate LoRa for use in an alternative GPS-free geolocation system @fargas_gps-free_2017.
Their proposed approach for localization with LoRa signals is based on precise measurements of the
Time of Arrival (ToA) of one packet at multiple LoRa gateways (anchor node). They then calculate the time difference of
the different ToA timestamps and estimate the distance between the end node and each gateway by using the
propagation velocity of radio waves, which is the speed of light. These distance are then combined by a
multilateration algorithm to estimate the position of the end node.

#figure(
    image("assets/fargas-gw-endnode-multilateration.png", width: 80%),
    caption: "Position estimation with multilateration algorithm © 2017 IEEE"
)

Fargas et al. also showed in their work, that by using the Generalized ESD test for detecting and eliminating outliers in
the distance measurement data they could improve the accuracy of the position estimation.

At last they shortly compared the current consumption of their test system with a GPS + GSM based device and found that their
device had significant lower current consumption and therefore could drastically decrease the power requirements for
devices with localization systems.


This idea is further advanced in @mackey_lora-based_2019 where they evaluate LoRa as alternative localization system
to GPS for Emergency Services. 

They found that simple off-the-shelf LoRa hardware could be used for achieving 
a positioning error between $9 - #qty("20", "meter")$ in an area of $#qty("200", "meter")$ x $#qty("120", "meter")$.

They also estimated the expected battery-life both of the transmitter and the receiver node and found that the transmitter
would possibly run up to 200 hours on a 5000 mAh battery but the receiver would only last about 90 hours with one battery charge.

Another point Fargas et al. highlight is the importance of a method for detecting and removing outliers in the RSSI measurement.
They show the difference 

In @dieng_outdoor_2019 they use RSSI-based LoRa Localization to track individual animals of a cattle herd to better deal with livestock theft.
Their solution is based on a hybrid localization approach where they use both GPS and LoRa RSSI measurements to estimate the positions of the
individual animals. They both deploy hybrid nodes, nodes equipped with both LoRa and GPS, and LoRa-only nodes. The hybrid nodes are used to
continuously improve the RSSI-distance model over time by correlating their GPS position with the current distance estimated by the RSSI-distance
model. Through this mechanism 

In @gotthard_low-cost_2018 they evaluate LoRa in carp

- RSSI-based LoRa localization for a low-cost car park localization implementation @gotthard_low-cost_2018.
- LoRa evaluated for use as communication technology for Emergency Services in off-grid environments @mackey_lora-based_2019.
- Evaluation of LoRaHarbor @priyanta_evaluation_2019
- lightweight boat tracking using LoRa technology @sanchez-iborra_tracking_2019
- LoRa-based mobile emergency management system (LOCATE) @sciullo_design_2020
- tracking of patients in elderly care @fernandes_hybrid_2020
  - indoor and outdoor

== Low Power
@el_agroudy_low_2016

== Deployment
- smart campus @alves_introducing_2020
- coverage @rizzi_using_2017

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

== Similar work
- RSSI-based LoRaWAN localization + evaluation of accuracy, impairments and prospects with SDR (software-defined radio) @kwasme_rssi-based_2019
- low power rssi outdoor using 868 MHz ZigBee @el_agroudy_low_2016
    - current consumption: 20mA in active mode, 6.7 uA in sleep-mode all at 3.3V -> receiver periodically wakes up to receive signals
- (indoor RSSI-based LoRa Localization in 2.4 GHz frequency band @vaishnav_design_2022)
- evaluation of using AoA measurement for LoRa Localization in the cloud @bnilam_angle_2022
- AoA based (indoor?) LoRa Localization @ge_long-range_2024
- LoRaWAPS: wide-area positioning system based on LoRa Mesh @li_lorawaps_2023
- public outdoor LoRa network used for TDoA-based tracking @podevijn_tdoa-based_2018

== Contribution of this Thesis
- implementation and evaluation of mobile localization tag using RSSI-based LoRa localization with off-the-shelf (OTS) components
    - RSSI measurement is implemented in nearly all receivers -> no dedicated hardware
    - accuracy loss due to multipath effect should not play a huge role in outdoor localization because of higher LOS (line-of-sight) component of the signal
- evaluation of the feasibility of a LoRa based localization system
    - accuracy
    - power consumption
    - frequency band usage
