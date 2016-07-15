let $nl := '&#10;'
let $open-curly := '&#123;'
let $closed-curly := '&#125;'
let $quote := '&#34;'


for $b in doc("test.xml")

    return 
	
	$b/People/person/*/name()
	
	
(:	      concat($c, $open-curly, $nl, , $quote, $b/name, $quote, $nl,
"email: ", $quote, $b/email, $quote ,$nl, $closed-curly) 
    
     concat("person ", $open-curly, $nl, "name: ", $quote, $b/name, $quote, $nl,
"email: ", $quote, $b/email, $quote ,$nl, $closed-curly) :)