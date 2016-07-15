let $nl := '&#10;'
let $open-curly := '&#123;'
let $closed-curly := '&#125;'
let $quote := '&#34;'
let $space := ' '


for $b in doc("ecoaType.xml")
    
     return concat("message ", $b/types/record/@name, $nl, $open-curly),
       {for $x in doc("ecoaType.xml"),
        $i in 1 to count($x/types/record/field)
       let $nl := '&#10;'
       let $space := ' '
       
     return concat($nl, "required ", ($x/types/record/field/@type)[$i], $space, ($x/types/record/field/@name)[$i], " = ", $i,";")}, '&#10;', '&#125;'