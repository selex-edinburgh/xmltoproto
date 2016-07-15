let $nl := '&#10;'
let $open-curly := '&#123;'
let $closed-curly := '&#125;'
let $quote := '&#34;'
let $space := ' '
let $tab := '&#9;'

for $b in doc("logger.types.xml"),
    $s in 1 to count($b/library/types/record)
        return {concat($nl, $nl,"message ", ($b/library/types/record/@name)[$s], $nl, $open-curly),
                for $x in doc("logger.types.xml")/library/types/record[$s],
                    $i in 1 to count($x/field)     
                        return concat($nl, $tab, "required ", ($x/field/@type)[$i], $space, ($x/field/@name)[$i], " = ", $i,";"), $nl,$closed-curly
               },
        
let $nl := '&#10;'
let $open-curly := '&#123;'
let $closed-curly := '&#125;'
let $quote := '&#34;'
let $space := ' '
let $tab := '&#9;'
        
        
for $b in doc("logger.types.xml"),
    $s in 1 to count($b/library/types/enum)
        return {concat($nl, $nl,"enum ", ($b/library/types/enum/@name)[$s], $nl, $open-curly),
                for $x in doc("logger.types.xml")/library/types/enum[$s],
                    $i in 1 to count($x/value)     
                        return concat($nl, $tab, ($x/value/@name)[$i], $space, "= ", $i,";"), $nl,$closed-curly
               }          

