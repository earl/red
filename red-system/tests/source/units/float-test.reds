Red/System [
	Title:   "Red/System integer! datatype tests"
	Author:  "Peter W A Wood, Nenad Rakocevic"
	File: 	 %float-test.reds
	Version: 0.1.0
	Rights:  "Copyright (C) 2012 Peter W A Wood, Nenad Rakocevic. All rights reserved."
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"
]

#include %../../../../quick-test/quick-test.reds

~~~start-file~~~ "float"

===start-group=== "float assignment"
  --test-- "float-1"
    f: 100.0
  --assert f = 100.0
  --test-- "float-2"
    f: 1.222090944E+33
  --assert f = 1.222090944E+33
  --test-- "float-3"
    f: 9.99999E-45
  --assert f = 9.99999E-45
  --test-- "float-4"
    f: 1.0
    f1: f
  --assert f1 = 1.0
===end-group===

===start-group=== "float argument to external function"

	#import [
		LIBM-file cdecl [
			sin: "sin" [
				x 		[float!]
				return: [float!]
			]
			cos: "cos" [
				x 		[float!]
				return: [float!]
			]
		]
	]
	pi: 3.14159265358979
	
	--test-- "float-ext-1"
	--assert -1.0 = cos pi
	
	;--test-- "float-ext-2"
	;--assert  0.0 = sin pi		; not working, because of rounding error.
	
	--test-- "float-ext-3"
	--assert -1.0 = cos 3.14159265358979
	
===end-group===

===start-group=== "float function arguments"
    ff: func [
      fff     [float!]
      ffg     [float!]
      return: [integer!]
      /local
      ffl [float!]
    ][
       ffl: fff
       if ffl <> fff [return 1]
       ffl: ffg
       if ffl <> ffg [return 2]
       1
    ]
    
  --test-- "float-func-args-1"
  --assert 1 = ff 1.0 2.0
  
  --test-- "float-func-args-2"
  --assert 1 = ff 1.222090944E+33 9.99999E-45
  
===end-group===

===start-group=== "float locals"

	local-float: func [n [float!] return: [float!] /local p][p: n p]

	--test-- "float-loc-1"
	pi: local-float 3.14159265358979
	--assert pi = 3.14159265358979
	--assert -1.0 = cos pi
	--assert -1.0 = local-float cos pi
	
	--test-- "float-loc-2"
	f: local-float pi
	--assert pi = local-float f

	--test-- "float-loc-3"
	local-float2: func [n [float!] return: [float!] /local p][p: n local-float p]
	
	pi: local-float2 3.14159265358979
	--assert -1.0 = local-float2 cos pi
	f: local-float2 pi
	--assert pi = local-float2 f

	--test-- "float-loc-4"
	local-float3: func [n [float!] return: [float!] /local p [float!]][p: n local-float p]

	pi: local-float3 3.14159265358979
	--assert -1.0 = local-float3 cos pi
	f: local-float3 pi
	--assert pi = local-float3 f

	--test-- "float-loc-5"
	local-float4: func [n [float!] return: [float!] /local r p][p: n p]
	--assert -1.0 = local-float4 cos pi
	f: local-float4 pi
	--assert pi = local-float4 f
	
	--test-- "float-loc-6"
	local-float5: func [n [float!] return: [float!] /local r p][p: n local-float p]
	--assert -1.0 = local-float5 cos pi
	f: local-float5 pi
	--assert pi = local-float5 f

===end-group===

===start-group=== "float function return"

 
    ff1: func [
      ff1i      [integer!]
      return:   [float!]
    ][
      switch ff1i [
        1 [1.0]
        2 [1.222090944E+33]
        3 [9.99999E-45]
      ]
    ]
  --test-- "float return 1"
  --assert 1.0 = ff1 1
  --test-- "float return 2"
  --assert 1.222090944E+33 = ff1 2
  --test-- "float return 3"
  --assert 9.99999E-45 = ff1 3
  
===end-group===

===start-group=== "float members in struct"

  --test-- "float-struct-1"
    sf1: declare struct! [
      a   [float!]
    ]
  --assert 0.0 = sf1/a
  
  --test-- "float-struct-2"
    sf2: declare struct! [
      a   [float!]
    ]
    sf1/a: 1.222090944E+33
  --assert 1.222090944E+33 = sf1/a

   
    sf3: declare struct! [
      a   [float!]
      b   [float!]
    ]
  
  --test-- "float-struct-3"
    sf3/a: 1.222090944E+33
    sf3/b: 9.99999E-45
    
  --assert 1.222090944E+33 = sf3/a
  --assert 9.99999E-45 = sf3/b
    
  --test-- "float-struct-4"
    sf4: declare struct! [
      c   [byte!]
      a   [float!]
      l   [logic!]
      b   [float!]
    ]
    sf4/a: 1.222090944E+33
    sf4/b: 9.99999E-45
  --assert 1.222090944E+33 = sf4/a
  --assert 9.99999E-45 = sf4/b
  
  --test-- "float-struct-5"
  sf5: declare struct! [f [float!] i [integer!]]
  
  sf5/i: 1234567890
  sf5/f: 3.14159265358979
  --assert sf5/i = 1234567890
  --assert sf5/f = pi
  
  --test-- "float-struct-6"
  sf6: declare struct! [i [integer!] f [float!]]
  
  sf6/i: 1234567890
  sf6/f: 3.14159265358979
  --assert sf6/i = 1234567890
  --assert sf6/f = pi

===end-group===

===start-group=== "float pointers"

  --test-- "float-point-1"
  pi: 3.14159265358979
  p: declare pointer! [float!]
  p/value: 3.14159265358979
  --assert pi = p/value
 
 ;TBD: add more float pointer tests in %pointer-test.reds.

===end-group===

===start-group=== "expressions with returned float values"

    fe1: function [
      return: [float!]
    ][
      1.0
    ]
    fe2: function [
      return: [float!]
    ][
      2.0
    ]
  
  --test-- "ewrfv0"
  --assertf~= 1.0 (fe1 * 1.0) 0.1E-13
    
  --test-- "ewrfv1"
  --assertf~= 1.0 (1.0 * fe1) 0.1E-13
  
  --test-- "ewrfv2"
  --assertf~= 0.5 (fe1 / fe2) 0.1E-13

===end-group===

 ===start-group=== "float arguments to typed functions"
    fatf1: function [
      [typed]
      count [integer!]
      list [typed-float!]
      return: [float!]
      /local
        a [float!]
    ][
      a: as float! list/value
      a
    ]
    
    fatf2: function [
      [typed]
      count [integer!]
      list [typed-float!]
      return: [float!]
      /local
        a [float!]
        b [float!]
    ][
      a: as float! list/value 
      list: list + 1
      b: as float! list/value
      a + b
    ]
  
  --test-- "fatf-1"
  --assert 2.0 = fatf1 2.0
  
  --test-- "fatf-2"
  --assert 2.0 = fatf1 1.0 + fatf1 1.0
  
  --test-- "fatf-3"
  --assert 3.0 = fatf2 [1.0 2.0]
  

===end-group===

===start-group=== "calculations"

  --test-- "fc-1"
    fc1: 2.0
    fc1: fc1 / (fc1 - 1.0)
  --assertf~= 2.0 fc1 0.1E-13
  
===end-group===

~~~end-file~~~
