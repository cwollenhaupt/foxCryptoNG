*========================================================================================
* Copyright 2007-2019 Christof Wollenhaupt
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of this 
* software and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy, modify, 
* merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
* permit persons to whom the Software is furnished to do so, subject to the following 
* conditions:
*
* The above copyright notice and this permission notice shall be included in all copies 
* or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
* INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
* PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
* CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
* OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*========================================================================================
DEFINE CLASS Test_foxCryptoNG as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		LOCAL THIS AS Test_foxCryptoNG OF Test_foxCryptoNG.PRG
	#ENDIF

*========================================================================================
Procedure Test_Load
	Local loRef
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	This.AssertIsObject (m.loRef)

*========================================================================================
Procedure Test_Hash_SHA256
	Local loRef, lcHash
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	lcHash = loRef.Hash_SHA256 ("FoxPro rocks!")
	This.AssertEquals ( ;
		 "A8000A53615647EF29F3CF4F38C21DE6C4E820882573B4F6937267231D61F583" ;
		,m.lcHash ;
	)

*========================================================================================
Procedure Test_Hash_SHA512
	Local loRef, lcHash
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	lcHash = loRef.Hash_SHA512 ("FoxPro rocks!")
	This.AssertEquals ( ;
		 "3A002D3FE28417EC0384800D9FBD2CFC7FF73705D3A36A1CEE9CF6410426BCCD881331DDE37" ;
		+"A02C25421B5D37DCE854A291928FBCC2FBE17D383989F71A9CF84" ;
		,m.lcHash ;
	)


EndDefine