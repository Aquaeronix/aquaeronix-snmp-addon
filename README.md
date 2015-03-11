SNMP Plugin for Aquaeronix

Depends on Aquaeronix. Please install using stable .rpm or compile from source for latest development version.

Sources:
  snmp.pl     http://www.docum.org/stef.coene/qos/gui/
  trafgraf.pl by Sébastien Cramatte <scramatte@zensoluciones.com> October 20006



Installation instructions


Add the following line to snmpd.conf

pass_persist .1.3.6.1.4.1.2021.255.65.67 /usr/local/sbin/snmp_persist_aquaero5.pl



Revision history


v0.02 4/13/2013 JinTu <JinTu@praecogito.com>
	Adding support for virtual, software and other sensors.

v0.01 1/29/2013 JinTu <JinTu@praecogito.com>
	First working version. Only supports sensor readings, not settings.



Usage notes (this really belongs in a MIB)


Sensor readings

General device info
.1.3.6.1.4.1.2021.255.65.67.1.1.1

Temperature sensors
.1.3.6.1.4.1.2021.255.65.67.1.1.2
  Name
  .1.3.6.1.4.1.2021.255.65.67.1.1.2.1
  Temp value
  .1.3.6.1.4.1.2021.255.65.67.1.1.2.2

Fans
.1.3.6.1.4.1.2021.255.65.67.1.1.3
  Name
  .1.3.6.1.4.1.2021.255.65.67.1.1.3.1
  VRM temp
  .1.3.6.1.4.1.2021.255.65.67.1.1.3.2
  Current
  .1.3.6.1.4.1.2021.255.65.67.1.1.3.3
  RPM
  .1.3.6.1.4.1.2021.255.65.67.1.1.3.4
  Duty cycle
  .1.3.6.1.4.1.2021.255.65.67.1.1.3.5
  Voltage
  .1.3.6.1.4.1.2021.255.65.67.1.1.3.6

Flow sensors
.1.3.6.1.4.1.2021.255.65.67.1.1.4
  Name
  .1.3.6.1.4.1.2021.255.65.67.1.1.4.1
  Flow value
  .1.3.6.1.4.1.2021.255.65.67.1.1.4.2

CPU temperatures
.1.3.6.1.4.1.2021.255.65.67.1.1.5
  Name
  .1.3.6.1.4.1.2021.255.65.67.1.1.5.1
  CPU temp
  .1.3.6.1.4.1.2021.255.65.67.1.1.5.2

Level sensors
.1.3.6.1.4.1.2021.255.65.67.1.1.6
  Name
  .1.3.6.1.4.1.2021.255.65.67.1.1.6
  Level value
  .1.3.6.1.4.1.2021.255.65.67.1.1.6

Virtual sensors
.1.3.6.1.4.1.2021.255.65.67.1.1.7
  Name
  .1.3.6.1.4.1.2021.255.65.67.1.1.7.1
  Virtual sensor value
  .1.3.6.1.4.1.2021.255.65.67.1.1.7.2

Software sensors
.1.3.6.1.4.1.2021.255.65.67.1.1.8
  Name
  .1.3.6.1.4.1.2021.255.65.67.1.1.8.1
  Software sensor value
  .1.3.6.1.4.1.2021.255.65.67.1.1.8.2

Other sensors
.1.3.6.1.4.1.2021.255.65.67.1.1.9
  Name
  .1.3.6.1.4.1.2021.255.65.67.1.1.9.1
  Other sensor value
  .1.3.6.1.4.1.2021.255.65.67.1.1.9.2



Settings

Fan settings
.1.3.6.1.4.1.2021.255.65.67.1.2.3
  Minimum RPM
  .1.3.6.1.4.1.2021.255.65.67.1.2.3.1
  Maximum RPM
  .1.3.6.1.4.1.2021.255.65.67.1.2.3.2
  Minimum duty cycle
  .1.3.6.1.4.1.2021.255.65.67.1.2.3.3
  Maximum duty cycle
  .1.3.6.1.4.1.2021.255.65.67.1.2.3.4
  Startboost duty cycle
  .1.3.6.1.4.1.2021.255.65.67.1.2.3.5
  Startboost duration
  .1.3.6.1.4.1.2021.255.65.67.1.2.3.6
  Pulses per revolution
  .1.3.6.1.4.1.2021.255.65.67.1.2.3.7
  Programmable fuse
  .1.3.6.1.4.1.2021.255.65.67.1.2.3.8




