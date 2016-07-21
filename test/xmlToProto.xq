declare variable $nl := '&#10;';
declare variable $open-curly := '&#123;';
declare variable $closed-curly := '&#125;';
declare variable $quote := '&#34;';
declare variable $space := ' ';
declare variable $tab := '&#9;';
declare variable $docName := "superSize.xml"; (: xml file to convert:)
declare variable $protoFile := '"values.proto";'; (: proto file that represents types not represented in proto. int8, int16 etc:)

declare function local:replaceEnumWithType(){

for $record in doc($docName)//record
let $field := $record/field 

return {concat($nl, $nl,"message ", $record/@name), $nl, $open-curly,
    for $field at $pos in $record/field (: Go through each field in the current record and keep track of index :)
        let $enumType := doc($docName)//enum[@name = $field/@type]/@type/string()[1] 
        let $typeValue := if ($enumType) then string($enumType) else string($field/@type)
        return concat($nl, $tab, "required ", $typeValue, $space, $field/@name, " = ", $pos,";"), $nl,$closed-curly
        }
};

declare function local:simple(){

for $simple in doc($docName)//simple

return {concat($nl, $nl,"message ", $simple/@name), $nl, $open-curly,  
        concat($nl, $tab, "required ", $simple/@type, " type = 1;"), 
        if($simple/@unit) then concat($nl, $tab, "optional string ", $simple/@unit, " = 2; //unit")
        else (), 
        $nl,$closed-curly
        }        
};

declare function local:fixedArray(){

for $fixedArray in doc($docName)//fixedArray

return {concat($nl, $nl,"message ", $fixedArray/@name), $nl, $open-curly,  
        concat($nl, $tab, "repeated ", $fixedArray/@itemType, " type = 1; //repeated because it's an array type"), 
        $nl,$closed-curly
        }        
};

declare function local:array(){

for $array in doc($docName)//array

return {concat($nl, $nl,"message ", $array/@name), $nl, $open-curly,  
        concat($nl, $tab, "repeated ", $array/@itemType, " type = 1; //repeated because it's an array type"), 
        $nl,$closed-curly
        }
};

(: Function not used as we are storing everything as messages:)
declare function local:replaceWithType(){

for $record in doc($docName)//record
let $field := $record/field 

return {concat($nl, $nl,"message ", $record/@name), $nl, $open-curly,
    for $field at $pos in $record/field (: Go through each field in the current record and keep track of index :)
        let $enumType := doc($docName)//enum[@name = $field/@type]/@type/string()[1]
        let $fixedArrayType := doc($docName)//fixedArray[@name = $field/@type]/@itemType/string()[1]  
        let $arrayType := doc($docName)//array[@name = $field/@type]/@itemType/string()[1]
        let $simpleType := doc($docName)//simple[@name = $field/@type]/@type/string()[1]  
        let $typeValue := if ($enumType) then string($enumType) 
                          else if ($fixedArrayType) then string($fixedArrayType)
                          else if ($arrayType) then string($arrayType)
                          else if ($simpleType) then string($simpleType)
                          else string($field/@type)
        
        return concat($nl, $tab, "required ", $typeValue, $space, $field/@name, " = ", $pos,";"), $nl,$closed-curly
        }
};

(:Constant function not used:)
declare function local:constant(){

for $constant in doc($docName)//constant

return {concat($nl, $nl,"message ", $constant/@name), $nl, $open-curly,
        concat($nl, $tab, "required ", $constant/@type, " type = 1;"),
        $nl,$closed-curly
        }
};

"import ", $protoFile,
local:replaceEnumWithType(),
local:simple(),
local:fixedArray(),
local:array()



