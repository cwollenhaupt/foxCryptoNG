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

*========================================================================================
Procedure Test_GenerateKeys_RSA
	Local loRef, lcPrivate, lcPublic
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	loRef.GenerateKeys_RSA (@lcPrivate, @lcPublic)
	This.AssertNotEmpty (m.lcPrivate, "private 2048")
	This.AssertNotEmpty (m.lcPublic, "public 2048")
	loRef.GenerateKeys_RSA (@lcPrivate, @lcPublic, 2400)
	This.AssertNotEmpty (m.lcPrivate, "private 2400")
	This.AssertNotEmpty (m.lcPublic, "public 2400")

*========================================================================================
Procedure Test_Encrypt_RSA
	Local loRef, lcPublic, lcCipher
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	loRef.GenerateKeys_RSA (, @lcPublic)
	lcCipher = loRef.Encrypt_RSA ("FoxPro rocks!", m.lcPublic)
	This.AssertNotEmpty (m.lcCipher)
	This.AssertEquals (2048, Len (m.lcCipher)*8)

*========================================================================================
Procedure Test_Decrypt_RSA
	Local loRef, lcPrivate, lcPublic, lcCipher, lcPlainText
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	loRef.GenerateKeys_RSA (@lcPrivate, @lcPublic)
	lcCipher = loRef.Encrypt_RSA ("FoxPro rocks!", m.lcPublic)
	lcPlainText = loRef.Decrypt_RSA (m.lcCipher, m.lcPrivate)
	This.AssertEquals ("FoxPro rocks!", m.lcPlainText)
	
*========================================================================================
Procedure Test_Encrypt_AES128
	Local loRef, lcEncrypted
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	lcEncrypted = loRef.Encrypt_AES ("FoxPro rocks!", "0123456789ABCDEF")
	This.AssertEquals ( ;
		 0h382ACC77D1ABD5359495830F7DF6C6C5;
		,Cast (m.lcEncrypted as varbinary(16));
	)

*========================================================================================
Procedure Test_Decrypt_AES128
	Local loRef, lcDecrypted
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	lcDecrypted = loRef.Decrypt_AES ( ;
		0h382ACC77D1ABD5359495830F7DF6C6C5, "0123456789ABCDEF")
	This.AssertEquals (Padr ("FoxPro rocks!", 16), m.lcDecrypted)

*========================================================================================
Procedure Test_EncryptDecrypt_AES128_Binary
	Local loRef, lcData, lcEncrypted, lcDecrypted
	loRef = NewObject ("foxCryptoNG", "foxCryptoNG.prg")
	lcData = Chr(1) + Chr(2) + Chr(3) + Chr(4) + Chr(5)
	lcEncrypted = loRef.Encrypt_AES (m.lcData, "0123456789ABCDEF")
	lcDecrypted = loRef.Decrypt_AES (m.lcEncrypted, "0123456789ABCDEF")
	This.AssertEquals (Padr(m.lcData, 16), m.lcDecrypted)

EndDefine