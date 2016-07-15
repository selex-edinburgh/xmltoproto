declare variable $nl := '&#10;';
declare variable $open-curly := '&#123;';
declare variable $closed-curly := '&#125;';
declare variable $quote := '&#34;';
declare variable $space := ' ';
declare variable $tab := '&#9;';
declare variable $docName := "ECOA.File.types.xml";    
        
declare updating function local:test($fieldPos,$enumPos) {
        replace value of node (doc($docName)/library/types/record/field/@type)[$fieldPos] with (doc($docName)/library/types/enum/@type)[$enumPos]
};        
  



for $b in doc($docName),
    $s in 1 to count($b/library/types/record/field)
        return {
                for $x in doc($docName),
                    $i in 1 to count($x/library/types/enum)     
                        return  local:test($s,$i)
               },




for $b in doc($docName),
    $s in 1 to count($b/library/types/record)
        return {concat($nl, $nl,"message ", ($b/library/types/record/@name)[$s], $nl, $open-curly),
                for $x in doc($docName)/library/types/record[$s],
                    $i in 1 to count($x/field)     
                        return  concat($nl, $tab, "required ", ($x/field/@type)[$i], $space, ($x/field/@name)[$i], " = ", $i,";"), $nl,$closed-curly
               }
                     

