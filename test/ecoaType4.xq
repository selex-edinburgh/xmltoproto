declare variable $nl := '&#10;';
declare variable $open-curly := '&#123;';
declare variable $closed-curly := '&#125;';
declare variable $quote := '&#34;';
declare variable $space := ' ';
declare variable $tab := '&#9;';
declare variable $docName := "ECOA.File.types.xml";
declare variable $protoFile := '"values.proto";';
 declare variable $a := doc($docName);


declare function local:test() {
for $b in doc($docName),
    $s in 1 to count($b/library/types/record/field)
        return { 
                for $x in doc($docName),
                    $i in 1 to count($x/library/types/enum)     
                        return { if (($b/library/types/record/field/@type)[$s] = ($x/library/types/enum/@name)[$i]) then 
                         (concat($nl,$nl, $tab, "required ", (doc($docName)/library/types/enum/@type)[$i], $space, ($b/library/types/record/field/@name)[$s], " = ", $s,";"))
                        else ()
                        },
                for $y in doc($docName),
                    $q in 1 to count($y/library/types/enum)     
                        return { if (($b/library/types/record/field/@type)[$s] != ($y/library/types/enum/@name)[$q]) then 
                         (concat($nl,$nl, $tab, "required ", ($b/library/types/record/field/@type)[$s], $space, ($b/library/types/record/field/@name)[$s], " = ", $s,";"))
                        else ()
                        }
               }
               
};  
declare function local:test2() {
for $b in doc($docName),
    $s in 1 to count($b/library/types/record)
        return {concat($nl, $nl,"message ", ($b/library/types/record/@name)[$s], $nl, $open-curly),
                for $x in doc($docName)/library/types/record[$s],
                    $i in 1 to count($x/field)     
                        return {
                         if (($x/field/@type)[$i] = ($b/library/types/enum/@name)[$s]) then 
                        (concat($nl, $tab, "required ", ($b/library/types/enum/@type)[$s], $space, ($x/field/@name)[$i], " = ", $i,";")) 
                        else concat($nl, $tab, "required ", ($x/field/@type)[$i], $space, ($x/field/@name)[$i], " = ", $i,";")
                        },
                $nl,$closed-curly  
               }
};   

declare function local:test3() {
for $b in doc($docName),
    $s in 1 to count($b/library/types/record)
        return {concat($nl, $nl,"message ", ($b/library/types/record/@name)[$s], $nl, $open-curly),
                for $x in doc($docName)/library/types/record[$s],
                    $i in 1 to count($x/field)     
                        return {
                            for $q in doc($docName),
                                $z in 1 to count($q/library/types/enum)
                                return{
                                        if (($x/field/@type)[$i] = ($b/library/types/enum/@name)[$z]) then 
                                            (concat($nl, $tab, "required ", ($b/library/types/enum/@type)[$z], $space, ($x/field/@name)[$i], " = ", $i,";")) 
                                        else ()
                                        }
                        },
                $nl,$closed-curly  
               }
               
};  

declare function local:message1() {

for $record in doc($docName)//record (: Go through each record in entire doc :)

return {concat($nl, $nl,"message ", $record/@name), $nl, $open-curly,

for $field at $pos in $record/field (: Go through each field in the current record and keep track of index :)

return concat($nl, $tab, "required ", $field/@type, $space, $field/@name, " = ", $pos,";"), $nl,$closed-curly

}

};



declare function local:enum1() {

for $record in doc($docName)//enum (: Go through each enum in entire doc :)

return {concat($nl, $nl,"enum ", $record/@name), $nl, $open-curly,

for $value at $pos in $record/value (: Go through each field in the current record and keep track of index :)

return concat($nl, $tab, $value/@type, $space, $value/@name, " = ", $pos,";"), $nl,$closed-curly

}

};

declare function local:test4() {
for $record in doc($docName)//record (: Go through each record in entire doc :)
    return {concat($nl, $nl,"message ", ($record/@name), $nl, $open-curly),
        for $field at $fieldPos in $record/field (: Go through each field in the current record and keep track of index :)
            return { for $enum at $enumPos in doc($docName)//enum (: Go through each enum in entire doc :)            
                return{ 
                        if (($field/@type) intersect ($enum/@name)) then 
                            (concat($nl, $tab, "required ", ($enum/@type), $space, ($field/@name), " = ", $fieldPos,";")) 
                        else ("field", $fieldPos, "enum", $enumPos)
                      }                        
                   },  $nl,$closed-curly  
         }               
};  

declare updating function local:replaceEnumWithType(){


for $field in doc($docName)//record/field

return if (doc($docName)//enum/@type intersect $field/@type) then 

replace value of node $field/@type with doc($docName)//enum[@name = $field/@type]/@type[0]

else()

};

declare updating function local:replaceEnumWithType1($a){


for $field in $a//record/field

return if ($a//enum/@type intersect $field/@type) then 

replace value of node $field/@type with $a//enum[@name = $field/@type]/@type[0]

else()

};

declare function local:replaceEnumWithType2(){


for $record in doc($docName)//record
let $field := $record/field 
let $enumType := doc($docName)//enum[@name = $field/@type]/@type/string()[1] 
let $typeValue := if ($enumType) then string($enumType) else string($field/@type)

return {concat($nl, $nl,"message ", $record/@name), $nl, $open-curly,
    for $field at $pos in $record/field (: Go through each field in the current record and keep track of index :)
        return concat($nl, $tab, "required ", $typeValue, $space, $field/@name, " = ", $pos,";"), $nl,$closed-curly

        }

};



"import ", $protoFile,

local:replaceEnumWithType2()


