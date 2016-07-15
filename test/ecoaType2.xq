declare variable $nl := '&#10;';
declare variable $open-curly := '&#123;';
declare variable $closed-curly := '&#125;';
declare variable $quote := '&#34;';
declare variable $space := ' ';
declare variable $tab := '&#9;';
declare variable $docName := "ECOA.File.types.xml";
        
  
copy $c := doc($docName)
modify ( for $d in $c, 
        $i in 1 to count(7) 
return {
        for $x in $c,
        $s in 1 to count(3)     
        return { if (($c/library/types/record/field/@type)[$i]=($c/library/types/enum/@name)[$s]) then
        (replace value of node ($c/library/types/record/field/@type)[$i] with ($c/library/types/enum/@type)[$s]) else ()}
        }
)
return {  
for $b in $c,
    $s in 1 to count($b/library/types/record)
        return {concat($nl, $nl,"message ", ($b/library/types/record/@name)[$s], $nl, $open-curly),
                for $x in $c/library/types/record[$s],
                    $i in 1 to count($x/field)     
                        return concat($nl, $tab, "required ", ($x/field/@type)[$i], $space, ($x/field/@name)[$i], " = ", $i,";"), $nl,$closed-curly
               }
               }
        

