# xmltoproto
Xquery program to convert ECOA typed from XML to .proto format

To compile .proto files and output in C++ use: 
protoc -I=$SRC_DIR --cpp_out=$DST_DIR $SRC_DIR/*.proto

*.proto will compile all proto files in the source directory

The Steps/0-Types directory contains example xml files that I used to test the xmlToProto converter. It also contains the values.proto file that is imported to all output proto files as it includes the ECOA types.
