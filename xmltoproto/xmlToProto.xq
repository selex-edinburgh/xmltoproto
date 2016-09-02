declare namespace an            = "http://zorba.io/annotations";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace file      = "http://expath.org/ns/file";
declare default element namespace "http://www.ecoa.technology/types-1.0"; 

declare variable $nl := '&#10;';
declare variable $open-curly := '&#123;';
declare variable $closed-curly := '&#125;';
declare variable $quote := '&#34;';
declare variable $space := ' ';
declare variable $tab := '&#9;';

declare variable $relativePath := "\Steps\0-Types\"; (: I have assumed xmlToProto will be run to look through the Steps\0-Types folder of an ECOA system. You may want this to be different:)
declare variable $absolutePath := file:resolve-path($relativePath); 
declare variable $docNames := local:getXmlNames($absolutePath); 

declare variable $protoFile := '"values.proto";'; (: this proto file has to be imported to all created .protos. This is where all the types are being stored e.g. ECOA__int16 etc. Proto's won't compile without this!:)
declare variable $protoSyntax := 'syntax = "proto2";';

(:Function getXmlName returns a collection of xml files that are located in the directory of the relativePath variable:)
declare %an:nondeterministic function local:getXmlNames($dName as xs:string)
{
    let $files := file:list($dName, fn:true(),"*.xml")
    for $filename in $files
        return concat($dName,$filename)
};

(:Function prefixCheck returns the prefix that is to be added to the data types e.g. if the type in the xml file is an int16 we want our output file to have the prefix ECOA__int16.
The defaultPrefix is used when the type of a message is made up of another message. The prefix we use will then be the xml file name before the .types e.g. if our xml was called philosopher.types.xml the 
default prefix would be philosopher__ followed by the message type:)
declare function local:prefixType($docName,$input){

        let $defaultPrefix := concat(substring-before(substring-after($docName,$relativePath), '.'), "__")   
        let $prefix := switch($input)
                        case "int16"    return "ECOA__"
                        case "int8"     return "ECOA__"
                        case "char8"    return "ECOA__"
                        case "uint8"    return "ECOA__"
                        case "byte"     return "ECOA__"
                        case "uint16"   return "ECOA__"
                        case "boolean8" return "ECOA__"
                        case "float32"  return "ECOA__"
                        case "double64" return "ECOA__"
                        case "int64"    return "ECOA__"
                        case "int32"    return "ECOA__"
                        case "uint32"   return "ECOA__"
                        case "uint64"   return "ECOA__"
                        case "string"   return "ECOA__"
                        default         return $defaultPrefix                          
          return $prefix              
};

(:Function record iterates through all record types in the xml file:)
declare function local:record($docName){

for $record in doc($docName)//record
let $field := $record/field 
let $messagePrefix := concat(substring-before(substring-after($docName,$relativePath), '.'), "__")

return {concat($nl, $nl,"// record", $nl, "message ", $messagePrefix, $record/@name), $nl, $open-curly,
    for $field at $pos in $record/field (: Go through each field in the current record and keep track of index :)
        let $prefix := local:prefixType($docName,$field/@type)    
        return concat($nl, $tab, "required ", $prefix, $field/@type, $space, $field/@name, " = ", $pos,";"), $nl,$closed-curly
        }
};

(:Function enum iterates through all enum types in the xml file:)
declare function local:enum($docName){

for $enum in doc($docName)//enum
let $prefix := local:prefixType($docName,$enum/@type) 
let $messagePrefix := concat(substring-before(substring-after($docName,$relativePath), '.'), "__")

return {concat($nl, $nl,"// enum", $nl, "message ", $messagePrefix, $enum/@name), $nl, $open-curly,
        concat($nl, $tab, "required ",$prefix, $enum/@type, " type = 1;"), $nl,$closed-curly
        }
};

(:Function simple iterates through all simple types in the xml file:)
declare function local:simple($docName){

for $simple in doc($docName)//simple
let $prefix := local:prefixType($docName,$simple/@type)
let $messagePrefix := concat(substring-before(substring-after($docName,$relativePath), '.'), "__")

return {concat($nl, $nl,"// simple", $nl, "message ", $messagePrefix, $simple/@name), $nl, $open-curly,  
        concat($nl, $tab, "required ",$prefix, $simple/@type, " type = 1;"), 
        if($simple/@unit) then concat($nl, $tab, "optional ECOA__string ", $simple/@unit, " = 2; //unit")
        else (), 
        $nl,$closed-curly
        }        
};

(:Function fixedArray iterates through all fixed array types in the xml file:)
declare function local:fixedArray($docName){

for $fixedArray in doc($docName)//fixedArray
let $prefix := local:prefixType($docName,$fixedArray/@itemType)
let $messagePrefix := concat(substring-before(substring-after($docName,$relativePath), '.'), "__")

return {concat($nl, $nl,"// fixedArray", $nl, "message ", $messagePrefix, $fixedArray/@name), $nl, $open-curly,  
        concat($nl, $tab, "repeated ", $prefix, $fixedArray/@itemType, " type = 1;"), 
        $nl,$closed-curly
        }        
};

(:Function array iterates through all array types in the xml file:)
declare function local:array($docName){

for $array in doc($docName)//array
let $prefix := local:prefixType($docName,$array/@itemType)
let $messagePrefix := concat(substring-before(substring-after($docName,$relativePath), '.'), "__")

return {concat($nl, $nl,"// array", $nl, "message ", $messagePrefix, $array/@name), $nl, $open-curly,  
        concat($nl, $tab, "repeated ", $prefix, $array/@itemType, " type = 1;"), 
        $nl,$closed-curly
        }
};

(:This is where the action happens. The for loop goes through each xml file in the $docNames collection. it runs all the function calls and stores it in a variable. This variable is then serialized 
and written to a file. The output file has the same name as the original xml file however the .xml part is replaced by .proto:)
for $currentDoc in $docNames
  return 
  {
     let $functionCalls :={ $protoSyntax, $nl, "import ", $protoFile, local:record($currentDoc),local:enum($currentDoc),local:simple($currentDoc),local:fixedArray($currentDoc),local:array($currentDoc),$nl}
     return {file:write-text(concat(substring-before($currentDoc,".xml"),".proto"),serialize($functionCalls, 
        <output:serialization-parameters> 
            <output:indent value="no"/> 
            <output:method value="text"/> 
            <output:omit-xml-declaration value="yes"/> 
        </output:serialization-parameters>)  ), 
        concat("Created file at ", substring-before($currentDoc,".xml"),".proto", $nl)}
  }

