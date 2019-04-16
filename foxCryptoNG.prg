*========================================================================================
* Implements an easier to use interface to Microsoft's Cryptography Next Generation API.
*
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
Define Class foxCryptoNG as Custom

*========================================================================================
* Initialize API
*========================================================================================
Procedure Init
	This.DeclareApiFunctions ()

*========================================================================================
* Creates a SHA-256 hash value.
*========================================================================================
Procedure Hash_SHA256 (tcData)
	Local lcHash
	lcHash = This.HashData ("SHA256", m.tcData)
Return m.lcHash

*========================================================================================
* Creates a SHA-512 hash value.
*========================================================================================
Procedure Hash_SHA512 (tcData)
	Local lcHash
	lcHash = This.HashData ("SHA512", m.tcData)
Return m.lcHash

*========================================================================================
* Generic routine for hashing binary data.
*========================================================================================
Procedure HashData (tcAlgorithm, tcData)

	*--------------------------------------------------------------------------------------
	* Stop when we encounter a failure
	*--------------------------------------------------------------------------------------
	Local llOK
	llOK = .T.

	*--------------------------------------------------------------------------------------
	* Get a handle to the hashing algorithm provider
	*--------------------------------------------------------------------------------------
	Local lnAlg
	lnAlg = 0
	If m.llOK
		llOK = BCryptOpenAlgorithmProvider( ;
			@lnAlg, Strconv(m.tcAlgorithm+Chr(0),5), NULL, 0 ) == 0
	EndIf

	*--------------------------------------------------------------------------------------
	* Determine how many bytes we need to store the hash object.
	*--------------------------------------------------------------------------------------
	Local lnSizeObj, lnData
	If m.llOK
		lnSizeObj = 0
		lnData = 0
		llOK = BCryptGetProperty( m.lnAlg, ;
			Strconv("ObjectLength"+Chr(0),5), @lnSizeObj, ;
			4, @lnData, 0 ) == 0
	EndIf
	
	*--------------------------------------------------------------------------------------
	* Determine length of hash value
	*--------------------------------------------------------------------------------------
	Local lnSizeHash
	If m.llOK
		lnSizeHash = 0
		llOK = BCryptGetProperty( m.lnAlg, ;
			Strconv("HashDigestLength"+Chr(0),5), ;
			@lnSizeHash, 4, @lnData, 0 ) == 0
	EndIf

	*--------------------------------------------------------------------------------------
	* Create the hash object
	*--------------------------------------------------------------------------------------
	Local lnHash, lcHashObj
	lnHash = 0
	If m.llOK
		lcHashObj = Space(m.lnSizeObj)
		llOK = BCryptCreateHash( m.lnAlg, @lnHash, ;
			@lcHashObj, m.lnSizeObj, NULL, 0, 0 ) == 0
	EndIf
	
	*--------------------------------------------------------------------------------------
	* To create the hash value we add data to the hash object. You can repeat this step 
	* as often as needed.
	*--------------------------------------------------------------------------------------
	If m.llOK
		llOK = BCryptHashData (m.lnHash, m.tcData, Len(m.tcData), 0) == 0
	EndIf 
	
	*--------------------------------------------------------------------------------------
	* Signal the hash object that we are done. The algorithm then calculates the hash value
	* and returns it.
	*--------------------------------------------------------------------------------------
	Local lcHash
	If m.llOK
		lcHash = Space(m.lnSizeHash)
		llOK = BCryptFinishHash (m.lnHash, @lcHash, m.lnSizeHash, 0) == 0
	EndIf
	
	*--------------------------------------------------------------------------------------
	* Hashes are commonly viewed in the hex representation rather than the original 
	* binary form. As the final step we now convert the hash value into a hex string. Use
	* STRCONV() if you do need a binary value, instead.
	*--------------------------------------------------------------------------------------
	If m.llOK
		lcHash = Strconv (m.lcHash, 15)
	EndIf

	*--------------------------------------------------------------------------------------
	* Cleanup
	*--------------------------------------------------------------------------------------
	If m.lnAlg != 0
		BCryptCloseAlgorithmProvider (m.lnAlg, 0)
	EndIf 
	If m.lnHash != 0
		BCryptDestroyHash (m.lnHash)
	EndIf
	If not m.llOK
		lcHash = ""
	EndIf

Return m.lcHash

*========================================================================================
* Various API declarations
*========================================================================================
Procedure DeclareApiFunctions

	Declare Long BCryptOpenAlgorithmProvider ;
		in BCrypt.DLL ;
		Long @phAlgorithm, ;
		String pszAlgId, ;
		String pszImplementation, ;
		Long dwFlags

	Declare Long BCryptGetProperty in BCrypt.DLL ;
		Long hObject, ;
		String pszProperty, ;
    Long @pbOutput, ;
		Long cbOutput, ;
 		Long @pcbResult, ;
 		Long dwFlags

	Declare Long BCryptCreateHash in BCrypt.DLL ;
		Long hAlgorithm, ;
		Long @phHash, ;
		String @pbHashObject, ;
		Long cbHashObject, ;
		String pbSecret, ;
		Long cbSecret, ;
		Long dwFlags

	Declare Long BCryptHashData in BCrypt.DLL ;
		Long hHash, ;
		String pbInput, ;
		Long cbInput, ;
		Long dwFlags

	Declare Long BCryptFinishHash in BCrypt.DLL ;
		Long hHash, ;
		String @pbOutput, ;
		Long cbOutput, ;
		Long dwFlags

	Declare Long BCryptDestroyHash in BCrypt.DLL ;
		Long hHash
	
	Declare Long BCryptCloseAlgorithmProvider ;
		in BCrypt.DLL ;
		Long hAlgorithm, ;
		Long dwFlags

	Declare Long BCryptDestroyKey in BCrypt.DLL ;
		Long hKey

	Declare long BCryptFinalizeKeyPair in BCrypt.DLL ;
		Long hKey, ;
		Long dwFlags
	
	Declare Long BCryptGenerateKeyPair in BCrypt.DLL ;
		long hAlgorithm, ;
		long @phKey, ;
		Long dwLength, ;
		Long dwFlags

	Declare Long BCryptExportKey in BCrypt.DLL ;
		Long hKey, ;
		Long hExportKey, ;
  	String pszBlobType, ;
  	String @pbOutput, ;
  	Long cbOutput, ;
  	Long @pcbResult, ;
  	Long dwFlags
  	
	Declare Long BCryptEncrypt in BCrypt.DLL ;
		Long hKey, ;
		String pbInput, ;
		Long cbInput, ;
		String pPaddingInfo, ;
		String @pbIV, ;
		Long cbIV, ;
		String @pbOutput, ;
		Long cbOutput, ;
		Long @pcbResult, ;
		Long dwFlags
	
	Declare Long BCryptImportKeyPair in BCrypt.DLL ;
		Long hAlgorithm, ;
		Long hImportKey, ;
		String pszBlobType, ;
		Long @phKey, ;
		String pbInput, ;
		Long cbInput, ;
		Long dwFlags
	
	Declare Long BCryptDecrypt in BCrypt.DLL ;
		Long hKey, ;
		String pbInput, ;
		Long cbInput, ;
		String pPaddingInfo, ;
		String @pbIV, ;
		Long cbIV, ;
		String @pbOutput, ;
		Long cbOutput, ;
		Long @pcbResult, ;
		Long dwFlags	


EndDefine