# Arduino Manifest

It is a script that reads Arduino source files, usually ".ino" and
".h" files, passed as arguments, indentify "#include <...>" directives
and print a list of used libraries and their versions.

It is not recursive, the list doesn't include nested dependencies.

It requires the "arduino-cli", the Arduino Command Line Interface,
available in the PATH, it parses the output of the "arduino-cli"
command, so changes in "arduino-cli" output can affect this script.

# Usage Example

```
valerio@ubu20:~/Arduino/DisplayTemperature$ arduino-manifest.pl *.ino *.h
Library Name                        Version    Author                    Architecture
----------------------------------- ---------- ------------------------- ---------------
ArduinoOTA                          1.0        Ivan Grokhotkov and Migue esp8266
Wire                                1.0        Arduino                   esp8266
ESP8266HTTPClient                   1.2        Markus Sattler            esp8266
Adafruit RGB LCD Shield Library     1.2.0      Adafruit                  *
OneWire                             2.3.5      Jim Studt, Tom Pollard, R *
DallasTemperature                   3.8.0      Miles Burton <miles@mnetc *
ESP8266WiFi                         1.0        Ivan Grokhotkov           esp8266
ESP8266mDNS                         1.2        multiple, see files       esp8266
```

# Usage

```
arduino-manifest [-h] [-d] [file1 file2 ... filen]
```

## Options

-h
: print help

-d
: print debugging information

## Arguments

file1 file2 ... filen
: Arduino source files, usually ".ino" or ".h" files
