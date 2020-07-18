# Arduino Manifest

It is a script that reads Arduino source files, usually ".ino" and
".h" files, passed as arguments, indentify "#include <...>" directives
and print a list of used libraries and their versions.

It is not recursive, the list doesn't include nested dependencies.

It requires the "arduino-cli", the Arduino Command Line Interface,
available in the PATH, it parses the output of the "arduino-cli"
command, so changes in "arduino-cli" output can affect this script.

# Usage Examples

Print the *"manifest.txt"* file:

```
valerio@ubu20:~/Arduino/DisplayTemperature$ arduino-manifest.pl  -b esp8266:esp8266:d1_mini *.ino *.h
Library Name                        Version    Author                    Architecture    Type
----------------------------------- ---------- ------------------------- --------------- -------
ESP8266HTTPClient                   1.2        Markus Sattler            esp8266         system
ArduinoOTA                          1.0        Ivan Grokhotkov and Migue esp8266         system
Adafruit RGB LCD Shield Library     1.2.0      Adafruit                  *               user
Wire                                1.0        Arduino                   esp8266         system
ESP8266mDNS                         1.2        multiple, see files       esp8266         system
ESP8266WiFi                         1.0        Ivan Grokhotkov           esp8266         system
OneWire                             2.3.5      Jim Studt, Tom Pollard, R *               user
DallasTemperature                   3.8.0      Miles Burton <miles@mnetc *               user
```

Print the *"requirements.txt"* file, it lists the user libraries; this
can be useful to script the installation of missing libraries:

```
valerio@ubu20:~/Arduino/DisplayTemperature$ arduino-manifest.pl  -r -b esp8266:esp8266:d1_mini *.ino *.h
DallasTemperature
Adafruit RGB LCD Shield Library
OneWire

```

Include the version information in the *"requirements.txt"* file:

```
valerio@ubu20:~/Arduino/DisplayTemperature$ arduino-manifest.pl  -r -b esp8266:esp8266:d1_mini *.ino *.h
Adafruit RGB LCD Shield Library@1.2.0
DallasTemperature@3.8.0
OneWire@2.3.5

```

# Usage

```
arduino-manifest.pl [-h] [-d] [-r] [-v] -b fqbn [file1 file2 ... filen]
```

**Options**

-h
: print help

-d
: print debugging information

-r
: print the "requirements.txt" file, listing only the name of user
libraries

-v
: includes version information in the "requirements.txt" file

-b fqbn
: required argument, the Fully Qualified Board Name (examples
*esp8266:esp8266:d1_mini* or *arduino:avr:uno* etc.)

**Arguments**

*file1 file2 ... filen*
: Arduino source files, usually ".ino" or ".h" files. If the argument
list is empty, it reads source files from the standard input.
