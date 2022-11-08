*========================================================================================
* Copyright 2007-2022 Christof Wollenhaupt
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
DEFINE CLASS Test_foxCryptoNGLegacy as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		LOCAL THIS AS Test_foxCryptoNGLegacy OF Test_foxCryptoNGLegacy.PRG
	#ENDIF

*========================================================================================
Procedure Test_Load
	Local loRef
	loRef = NewObject ("foxCryptoNGLegacy", "foxCryptoNGLegacy.prg")
	This.AssertIsObject (m.loRef)

*========================================================================================
Procedure Test_LegacyEncryptSessionBlockString
	Local loRef, lcData, lcKey, llOk, lcEncrypted
	loRef = NewObject ("foxCryptoNGLegacy", "foxCryptoNGLegacy.prg")
	lcData = "FoxPro rocks!"
	lcKey = "0123456789ABCDEF"
	lcEncrypted = ""
	llOk = loRef.LegacyEncryptSessionBlockString (m.lcData, m.lcKey, @lcEncrypted)
	This.AssertTrue (m.llOk)		
	This.AssertEquals ( ;
		 0hCFC45FB18C60E3099BBB785F2DABE24E ;
		,Cast (m.lcEncrypted as varbinary(16));
	)

*========================================================================================
Procedure Test_LegacyEncryptSessionBlockString
	Local loRef, lcData, lcKey, llOk, lcEncrypted
	loRef = NewObject ("foxCryptoNGLegacy", "foxCryptoNGLegacy.prg")
	lcData = "FoxPro rocks!"
	lcKey = "0123456789ABCDEF"
	lcEncrypted = ""
	llOk = loRef.LegacyEncryptSessionBlockString (m.lcData, m.lcKey, @lcEncrypted)
	This.AssertTrue (m.llOk)
	This.AssertEquals ( ;
		 0hCFC45FB18C60E3099BBB785F2DABE24E ;
		,Cast (m.lcEncrypted as varbinary(16));
	)

*========================================================================================
Procedure Test_LegacyDecryptSessionBlockString
	Local loRef, lcData, lcKey, llOk, lcDecrypted
	loRef = NewObject ("foxCryptoNGLegacy", "foxCryptoNGLegacy.prg")
	lcData = Strconv ("CFC45FB18C60E3099BBB785F2DABE24E", 16)
	lcKey = "0123456789ABCDEF"
	lcDecrypted = ""
	llOk = loRef.LegacyDecryptSessionBlockString (m.lcData, m.lcKey, @lcDecrypted)
	This.AssertTrue (m.llOk)
	This.AssertEquals ("FoxPro rocks!", m.lcDecrypted)

EndDefine
