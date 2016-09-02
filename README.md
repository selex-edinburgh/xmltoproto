# xmltoproto
Xquery program to convert ECOA typed from XML to .proto format

To compile .proto files and output in C++ use: 
protoc -I=$SRC_DIR --cpp_out=$DST_DIR $SRC_DIR/*.proto

*.proto will compile all proto files in the source directory
