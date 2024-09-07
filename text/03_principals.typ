= Principals

== LoRa
== RSSI-based distance estimation
== Multilateration
Multilateration is a position estimation
algorithm which uses three or more distances between the node which position should be estimated and nodes with
known positions. The algorithm can be geometrically explained by drawing circles, each with the measured distance at the anchor
as radius, around the positions of the anchors. The position of the end node is estimated by the point of intersection of all
the circles. In a perfect scenario this single point of intersection would exist, but in a real-world scenario the distance measurement
always includes an error. Due to this error the circles all intersect at different points. These points describe an area in which the real
position of the end node must be located.

#figure(
    image("assets/multilateration.svg", width: 80%),
    caption: "Position estimation error with multilateration"
)
