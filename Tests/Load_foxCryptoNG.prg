*========================================================================================
* Copyright 2007-2024 Christof Wollenhaupt
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
DEFINE CLASS Load_foxCryptoNG as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		LOCAL THIS AS Load_foxCryptoNG OF Load_foxCryptoNG.PRG
	#ENDIF

*========================================================================================
Procedure Load_HashData_Exception
	Local loRef, lnIteration, lnSize, lcData, lcHash, lnInvalid
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	Rand(-1)
	lnInvalid = 0
	For m.lnIteration = 1 to 100000
		lnSize = Rand()*10*1024 + Rand()*1024
		lcData = Space (m.lnSize)
		lcHash = loRef.Hash_SHA256 (m.lcData)
		If Empty(m.lcHash)
			lnInvalid = m.lnInvalid + 1
	 		This.MessageOut ("Hash invalid #"+Transform(m.lnInvalid))
		EndIf
		If Int(Rand() * 50) == 42
			Sys(1104)
		EndIf
	EndFor 

EndDefine 