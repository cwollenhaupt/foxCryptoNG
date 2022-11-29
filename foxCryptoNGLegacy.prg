*========================================================================================
* VFP 9 ships with an encryption library that is widely in use among Visual FoxPro 
* developers: _Crypt.vcx. The library used the Cryptography API that Microsoft released
* with Windows XP and Windows Server 2003. Microsoft has deprecated this library a while
* ago and recommends using Cryptography Next Generation APIs.
*
* This wrapper class provides an interface that mimics the _Crypt.vcx interface if 
* possible. All methods use foxCryptoNG instead of the old Cryptography API. The purpose
* of this library is to allow developers to migrate their code away from _Crypt.VCX
* with minimal effort.
*
* #######################################################################################
*
* PLEASE READ CAREFULLY!
*
* _Crypt.vcx doesn't meet todays security standards. Features such as the stream cipher
* or some algorithms like MD5 should not be used in today's applications. 
*
* This library is designed to be compatible with _Crypt.vcx and therefore does make the
* same bad choices and implements the same week standard. Migrating your application to
* this library is the first step to used current APIs. Your next step should be to
* review the security aspects of your application and migrate to modern algorithms and
* best practices.
*
* Remember that cryptography is a moving target. What used to be secure in the past is
* not secure in the present. Presently secure implementations will not be secure in the
* future. Your application needs to be prepared.
*
* #######################################################################################
*
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
Define Class foxCryptoNGLegacy as Custom

*========================================================================================
* Implements the same interface as the EncryptSessionBlockString method in _Crypt.vcx.
*========================================================================================
Procedure EncryptSessionBlockString (tcData, tcKey, rcEncrypted)

	*--------------------------------------------------------------------------------------
	* Stop when we encounter a failure. All encryption routines are in foxCryptoNG.
	*--------------------------------------------------------------------------------------
	Local llOK, loFoxCryptoNG
	llOK = .T.
	loFoxCryptoNG = This.CreateInstance ()
	
	*--------------------------------------------------------------------------------------
	* The API uses the MD5 (128-bit) hash of the key as a password because a fixed length
	* is required for block ciphers. Crypt.VCX removes trailing blanks.
	*--------------------------------------------------------------------------------------
	Local lcHash
	If m.llOK
		lcHash = loFoxCryptoNG.Hash_MD5 (Rtrim (m.tcKey))
		If Empty (m.lcHash)
			llOK = .F.
		Else
			lcHash = Strconv (m.lcHash, 16)
		EndIf 
	EndIf
	
	*--------------------------------------------------------------------------------------
	* With the "Microsoft Enhanced Cryptographic Provider" we use the 128-bit MD5 hash
	* directly. We would use the first five characters of the hash value to encrypt like
	* the 40-bit "Microsoft Base Cryptographic Provider". Windows uses the Enhanced 
	* Provider by default.
	*--------------------------------------------------------------------------------------
	Local lcEncrypted
	If m.llOK
		lcEncrypted = loFoxCryptoNG.Encrypt_RC2 (m.tcData, m.lcHash)
		If Empty (m.lcEncrypted)
			llOK = .F.
		Else 
			rcEncrypted = m.lcEncrypted
		EndIf
	EndIf
	
Return m.llOK

*========================================================================================
* Implements the same interface as the DecryptSessionBlockString method in _Crypt.vcx.
*========================================================================================
Procedure DecryptSessionBlockString (tcData, tcKey, rcDecrypted)

	*--------------------------------------------------------------------------------------
	* Stop when we encounter a failure. All encryption routines are in foxCryptoNG.
	*--------------------------------------------------------------------------------------
	Local llOK, loFoxCryptoNG
	llOK = .T.
	loFoxCryptoNG = This.CreateInstance ()
	
	*--------------------------------------------------------------------------------------
	* The API uses the MD5 (128-bit) hash of the key as a password because a fixed length
	* is required for block ciphers. Crypt.VCX removes trailing blanks.
	*--------------------------------------------------------------------------------------
	Local lcHash
	If m.llOK
		lcHash = loFoxCryptoNG.Hash_MD5 (Rtrim (m.tcKey))
		If Empty (m.lcHash)
			llOK = .F.
		Else
			lcHash = Strconv (m.lcHash, 16)
		EndIf 
	EndIf
	
	*--------------------------------------------------------------------------------------
	* With the "Microsoft Enhanced Cryptographic Provider" we use the 128-bit MD5 hash
	* directly. We would use the first five characters of the hash value to encrypt like
	* the 40-bit "Microsoft Base Cryptographic Provider". Windows uses the Enhanced 
	* Provider by default.
	*--------------------------------------------------------------------------------------
	Local lcDecrypted
	If m.llOK
		lcDecrypted = loFoxCryptoNG.Decrypt_RC2 (m.tcData, m.lcHash)
		If Empty (m.lcDecrypted)
			llOK = .F.
		Else 
			rcDecrypted = Rtrim (m.lcDecrypted)
		EndIf
	EndIf
	
Return m.llOK

*========================================================================================
* Creates an instance of foxCryptoNG. Overide this method in your subclass if you use
* a different mechanism to instantiate objects or have a global cryptohgraphy object 
* that you want to access.
*========================================================================================
Function CreateInstance
	Local loInstance
	loInstance = NewObject ("foxCryptoNG", "foxCryptoNG.fxp")
Return m.loInstance

EndDefine

