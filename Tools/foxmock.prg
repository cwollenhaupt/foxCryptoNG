*========================================================================================
* Generic Mockup Framework
*
* Written 2010 by Christof Wollenhaupt
*========================================================================================
Define Class foxMock as Collection

	*--------------------------------------------------------------------------------------
	* When an object accessor returns a new object reference, the object is automatically
	* released before the next step - accessing the property - is executed. Therefore we
	* need an additional reference to those temporary obejcts
	*--------------------------------------------------------------------------------------
	oKeepAlive = NULL
	
	*--------------------------------------------------------------------------------------
	* There's one master objects that keeps track of the test definition for what appears
	* to be a single object to the user. This is the object returned by the new action.
	* Action implementation need to be aware of the master and return it for the next 
	* access.
	*--------------------------------------------------------------------------------------
	oMaster = NULL
	
	*--------------------------------------------------------------------------------------
	* The repository is the first instance of the foxMock object that the user created.
	* This is the place where all objects are located.
	*--------------------------------------------------------------------------------------
	oRepository = NULL
	
	*--------------------------------------------------------------------------------------
	* Context specific operations need to know on which member to work on.
	*--------------------------------------------------------------------------------------
	cActiveMember = ""
	
	*--------------------------------------------------------------------------------------
	* The object operates in to modes: definition and mockup. In definition mode we can
	* call operations to specify the behavior of the object. This definition has to occur
	* in a single line.
	*--------------------------------------------------------------------------------------
	cDefinitionLine = ""
	
	*--------------------------------------------------------------------------------------
	* In definition mode we may have a single expectation that all subsequent operations
	* refer to. The repository keeps track of all expectations in a single location.
	*--------------------------------------------------------------------------------------
	oExpectation = NULL
	Expectations = NULL
	
	*--------------------------------------------------------------------------------------
	* Every object provides a number of simulated members. In this collection we keep
	* track of all members, call frequencies, etc.
	*--------------------------------------------------------------------------------------
	Members = Null
	
	*--------------------------------------------------------------------------------------
	* Many classes require that developers create a subclass and overide methods with the
	* actual implementation. To test those without creating a sub class for every test,
	* we can use these classes as the basis for our mock up object.
	*--------------------------------------------------------------------------------------
	cFoundation = ""
	oFoundation = NULL
	
*========================================================================================
* Internally we instantiate subclasses that need to refer back to the master obejct and
* the repository object.
*========================================================================================
Procedure Init (toMaster, toRepository)
	
	*--------------------------------------------------------------------------------------
	* We need access to the physical object
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.
	
	*--------------------------------------------------------------------------------------
	* Initialize references
	*--------------------------------------------------------------------------------------
	This.Members = CreateObject("Collection")
	This.Expectations = CreateObject("Collection")
	
	If Vartype(m.toMaster) == "O"
		This.oMaster = m.toMaster
	EndIf 
	
	If Vartype(m.toRepository) == "O"
		This.oRepository = m.toRepository
	EndIf 
	
EndProc

*========================================================================================
* Dispatches any request to either the current mock object, a new mock object or the 
* test instance of a mock object.
*========================================================================================
Procedure This_Access (tcMember)

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcMember) == "C"
	
	*--------------------------------------------------------------------------------------
	* Within the Accessor we only reer to the physical object itself.
	*--------------------------------------------------------------------------------------
	If Vartype(foxMock__Accessor) == "L"
		Return This
	Else
		Private foxMock__Accessor
		foxMock__Accessor = .T.
	EndIf
	
	*--------------------------------------------------------------------------------------
	* Prepare parameters
	*--------------------------------------------------------------------------------------
	Local lcMember
	lcMember = Alltrim (Lower (m.tcMember))

	*--------------------------------------------------------------------------------------
	* Which mode do we operate in now?
	*
	* - object has been created with CreateObject: This is the base module. Definition mode main
	* - object has been created by new: Definition mode 
	* - is being called within the same line as corresponding New: definition mode
	* - is being called with mock.Extend(obj). -> definition mode on obj
	* - otherwise we are in test mode
	* - chaining
	*--------------------------------------------------------------------------------------
	Local loImplementation
	If This.InDefinitionMode()
		loImplementation = This.PrepareForCommand (m.lcMember)
	Else
		loImplementation = This.PrepareForTest (m.lcMember)
	EndIf 
	
	*--------------------------------------------------------------------------------------
	* Make sure VFP keeps a reference long enough around to actually access the member.
	*--------------------------------------------------------------------------------------
	This.oKeepAlive = m.loImplementation

Return m.loImplementation

*========================================================================================
* This object has multiple interfaces. It can be called when it's being tested using 
* whatever property or methods have been defined, but it also can be programmed using 
* a fluent interface. The following two lines illustrate this:
*
*   x = mock.New ;
*           .Property("test").Is("Hello")
*   ? x.Test
*
*========================================================================================
Hidden Procedure InDefinitionMode
	
	Local lcCaller, llInDefinitionMode
	If Empty(This.cDefinitionLine)
		llInDefinitionMode = .T.
	Else 
		lcCaller = This.GetCaller (2)
		llInDefinitionMode = (m.lcCaller == This.cDefinitionLine)
	EndIf 

Return m.llInDefinitionMode

*========================================================================================
* We expect a certain property to be accessed next. Make sure we forward the call 
* accordingly.
*========================================================================================
Procedure PrepareForCommand (tcMember)
	
	*--------------------------------------------------------------------------------------
	* Assertion
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcMember) == "C"
	Assert Lower(m.tcMember) == m.tcMember
	
	*--------------------------------------------------------------------------------------
	* Test for every possible command and dispatch the appropriate implementation
	*--------------------------------------------------------------------------------------
	Local loImplementation
	Do case
	Case m.tcMember == "verifyallexpectations"
		loImplementation = This
	Case m.tcMember == "add"
		loImplementation = This
	Case m.tcMember == "new"
		loImplementation = CreateObject ("foxMock_New", Null, This.GetRepository ())
	Case m.tcMember == "property"
		loImplementation = CreateObject ("foxMock_Property", This.GetMaster ())
	Case m.tcMember == "is"
		loImplementation = CreateObject ("foxMock_Is", This.GetMaster ())
	Case m.tcMember == "isobject"
		loImplementation = CreateObject ("foxMock_IsObject", This.GetMaster ())
	Case m.tcMember == "expect"
		loImplementation = CreateObject ("foxMock_Expect", This.GetMaster ())
	Case m.tcMember == "callto" or m.tcMember == "method"
		loImplementation = CreateObject ("foxMock_CallTo", This.GetMaster ())
	Case m.tcMember == "return" or m.tcMember == "returns"
		loImplementation = CreateObject ("foxMock_Return", This.GetMaster ())
	Case m.tcMember == "asobject"
		loImplementation = CreateObject ("foxMock_AsObject", This.GetMaster ())
	Case m.tcMember == "returnobject" or m.tcMember == "returnsobject"
		loImplementation = CreateObject ("foxMock_ReturnObject", This.GetMaster ())
	Case m.tcMember == "when"
		loImplementation = CreateObject ("foxMock_When", This.GetMaster ())
	Case m.tcMember == "then"
		loImplementation = CreateObject ("foxMock_then", This.GetMaster ())
	Case m.tcMember == "fail"
		loImplementation = CreateObject ("foxMock_Fail", This.GetMaster ())
	Case m.tcMember == "scatter"
		loImplementation = CreateObject ("foxMock_Scatter", This.GetMaster ())
	Otherwise 
		Assert .F. Message "Unknown operation " + m.tcMember
		loImplementation = NULL
	EndCase 
	
Return m.loImplementation

*========================================================================================
* Returns the repository object, which is the very first object created by the user.
*========================================================================================
Procedure GetRepository

	Local loMaster
	If IsNull(This.oRepository)
		If IsNull(This.oMaster)
			Return This
		Else
			Return This.oMaster.GetRepository()
		EndIf
	Else
		Return This.oRepository
	EndIf 

EndProc

*========================================================================================
* Returns the master object implementation
*========================================================================================
Procedure GetMaster

	If IsNull(This.oMaster)
		Return This
	Else
		Return This.oMaster
	EndIf 

EndProc

*========================================================================================
* Return an object with the requested object and the current operation
*========================================================================================
Procedure PrepareForTest (tcMember)

	*--------------------------------------------------------------------------------------
	* Assertion
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcMember) == "C"
	Assert Lower(m.tcMember) == m.tcMember

	*--------------------------------------------------------------------------------------
	* Find member for current operation among the registered members.
	*--------------------------------------------------------------------------------------
	Local lnIndex
	lnIndex = This.Members.GetKey(m.tcMember)
	If Empty(This.cFoundation)
		Assert m.lnIndex > 0 Message "Undefined mocked member '"+m.tcMember+"'"
	EndIf
	
	*--------------------------------------------------------------------------------------
	* We ask the member definition to provide us with an implementation
	*--------------------------------------------------------------------------------------
	Local loImplementation
	If m.lnIndex == 0
		loImplementation = This.GetFoundationMaster ()
	Else 
		loImplementation = This.Members[m.lnIndex].GetImplementation()
	EndIf

Return m.loImplementation

*========================================================================================
* Returns a class that implements the basic interface for FoxMock as well as the 
* foundation class. Technially it's a sub class of the foundation class and therefore
* as the same runtime requirements. Because most classes aren't stateless, we keep a 
* single copy around.
*========================================================================================
Procedure GetFoundationMaster 

	Local loFoundationDefinition
	If IsNull(This.oFoundation)
		loFoundationDefinition = CreateObject("mockFoundationDefinition")
		loFoundationDefinition.cName = This.cFoundation
		This.oFoundation = loFoundationDefinition.GetImplementation (This)
	EndIf 	

Return This.oFoundation

*========================================================================================
* Adds a property or a method to the definition and makes it the current member. Any 
* modifier operates on that member then.
*========================================================================================
Procedure RegisterMember (toMember)

	Local lcName
	lcName = m.toMember.cName
	If This.Members.GetKey(m.lcName) == 0
		This.Members.Add (m.toMember, m.lcName)
	Else
		This.Members[m.lcName].Reset()
	EndIf
	This.ExpectationHandledBy (This.Members[m.lcName])
	This.cActiveMember = m.lcName

EndProc

*========================================================================================
* Returns a reference to the active property definition
*========================================================================================
Procedure GetActiveMember

Return This.Members[This.cActiveMember]

*========================================================================================
* Returns .T. when the currently active member is a property
*========================================================================================
Procedure PropertyIsActive
Return This.ActiveMemberIs ("mockPropertyDefinition")

*========================================================================================
* Returns .T. when the currently active member is a method
*========================================================================================
Procedure MethodIsActive
Return This.ActiveMemberIs ("mockMethodDefinition")

*========================================================================================
* Returns .T. when the currently active member is a scatter operation
*========================================================================================
Procedure ScatterIsActive
Return This.ActiveMemberIs ("mockScatterDefinition")

*========================================================================================
* Returns .T. when the currently active member is the passed type
*========================================================================================
Hidden Procedure ActiveMemberIs (tcClass)

	Local loMember, llIsClass
	loMember = This.GetActiveMember()
	If Lower(m.loMember.Class) == Lower(m.tcClass)
		llIsClass = .T.
	Else
		llIsClass = .F.
	EndIf 
	
Return m.llIsClass

*========================================================================================
* Remember from which line we have been called. This is the definition code line.
*========================================================================================
Procedure SetDefinitionLine (tcDefiniton)
	
	Assert Vartype(m.tcDefiniton) == "C"
	This.cDefinitionLine = m.tcDefiniton
	
EndProc

*========================================================================================
* Returns the caller line
*========================================================================================
Procedure GetCaller (m.tnOffset)

	*--------------------------------------------------------------------------------------
	* Assertion
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tnOffset) == "N"
	Assert Program(-1)-m.tnOffset-1 > 0

	*--------------------------------------------------------------------------------------
	* Program and line number uniquely identifiers a caller
	*--------------------------------------------------------------------------------------
	Local laStack[1], lcDefiniton, lnLevel
	AStackInfo(laStack)
	lnLevel = Program(-1) -1 - m.tnOffset
	lcDefiniton = laStack[m.lnLevel,2] + ":" + Transform(laStack[lnLevel,5])
	
Return m.lcDefiniton

*========================================================================================
* Registers a new expectation in the repository and makes it the current expectation in
* the master object.
*========================================================================================
Procedure NewExpectation (toExpectation)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.toExpectation) == "O"
	
	*--------------------------------------------------------------------------------------
	* Make it the current expectation in the master object
	*--------------------------------------------------------------------------------------
	Local loMaster
	loMaster = This.GetMaster()
	loMaster.oExpectation = m.toExpectation
	
	*--------------------------------------------------------------------------------------
	* All expectations are kept track of in a single location
	*--------------------------------------------------------------------------------------
	Local loRepository
	loRepository = This.GetRepository()
	loRepository.Expectations.Add (m.toExpectation)

EndProc

*========================================================================================
* If there's a current expectation, we link with the handler
*========================================================================================
Procedure ExpectationHandledBy (toHandler)

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.toHandler) == "O"
	
	*--------------------------------------------------------------------------------------
	* This expectation is now assigned to a handler.
	*--------------------------------------------------------------------------------------
	If Vartype(This.oExpectation) == "O"
		This.oExpectation.HandledBy = m.toHandler
		This.oExpectation = NULL
		toHandler.lExpectation = .T.
	Else
		toHandler.lExpectation = .F.
	EndIf 
	
EndProc

*========================================================================================
* Verfifies that all expectations have been met.
*========================================================================================
Procedure VerifyAllExpectations
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Query the handler for each registered expectation
	*--------------------------------------------------------------------------------------
	Local loExpectation
	For each loExpectation in This.Expectations FoxObject
		If not loExpectation.HandledBy.VerifyExpectation()
			Error 2005, "Expectation failed for " + loExpectation.HandledBy.cName
		EndIf 
	EndFor 
	
EndProc 

EndDefine 

*========================================================================================
* The new command returns a new mockup object. This new object later becomes the master.
*========================================================================================
Define Class foxMock_New as foxMock
	
	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension New[1]
	
*========================================================================================
* Returns a new mockup object
*========================================================================================
Procedure New_Access (tcClass)

	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Create a new mockup object
	*--------------------------------------------------------------------------------------
	Local loMaster
	loMaster = CreateObject ("foxMock", NULL, This.GetRepository())

	*--------------------------------------------------------------------------------------
	* Everything called from the same line as the New line is considered to be a
	* definition. Everything else uses the mockup.
	*--------------------------------------------------------------------------------------
	loMaster.SetDefinitionLine (m.loMaster.GetCaller( 1))
	If not Empty(m.tcClass)
		loMaster.cFoundation = m.tcClass
	EndIf
	
Return m.loMaster 

EndDefine 

*========================================================================================
* Property adds a new property to the master object
*========================================================================================
Define Class foxMock_Property as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension Property[1]
	
*========================================================================================
* Registers a new property for the mockup 
*========================================================================================
Procedure Property_Access (tcProperty)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcProperty) == "C"
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* We only use lower case names internally
	*--------------------------------------------------------------------------------------
	Local lcProperty
	lcProperty = Lower (m.tcProperty)
	
	*--------------------------------------------------------------------------------------
	* The property object keeps track of a few pieces we need to know about every simulated
	* property.
	*--------------------------------------------------------------------------------------
	Local loProperty
	loProperty = CreateObject("mockPropertyDefinition")
	loProperty.cName = m.lcProperty
	
	*--------------------------------------------------------------------------------------
	* Register the new property in the master object
	*--------------------------------------------------------------------------------------
	Local loMaster
	loMaster = This.GetMaster()
	loMaster.RegisterMember (m.loProperty)
	
Return m.loMaster

EndDefine 

*========================================================================================
* Add properties from a record using SCATTER
*========================================================================================
Define Class foxMock_Scatter as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension Scatter[1]
	
*========================================================================================
* Registers a set of new properties for the mockup 
*========================================================================================
Procedure Scatter_Access (tcDefinition)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcDefinition) == "C"
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.
	
	*--------------------------------------------------------------------------------------
	* Returns the specified record
	*--------------------------------------------------------------------------------------
	Local loRecord, loMaster
	loMaster = This.GetMaster()
	loRecord = This.GetRecord (&tcDefinition)

	*--------------------------------------------------------------------------------------
	* Register each member as a property with a value
	*--------------------------------------------------------------------------------------
	Local laMembers[1], lnMember, lcName
	If Vartype(m.loRecord) == "O"
		For lnMember = 1 to AMembers(laMembers, m.loRecord)
			lcName = Lower (laMembers[m.lnMember])
			This.AddMember (m.loMaster, m.lcName, GetPem (m.loRecord, m.lcName))
		EndFor
	EndIf 

Return m.loMaster

*========================================================================================
* Reads the specified record
*========================================================================================
Procedure GetRecord (tcAlias, tcLocate)

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcAlias) == "C"
	Assert Vartype(m.tcLocate) $ "CL"
	
	*--------------------------------------------------------------------------------------
	* Save environment
	*--------------------------------------------------------------------------------------
	Local lnSelect, lnRecNo
	lnSelect = Select()
	If Used(m.tcAlias)
		Select (m.tcAlias)
		lnRecNo = Recno()
	Else
		Return null
	EndIf
	
	*--------------------------------------------------------------------------------------
	* Load the desired record
	*--------------------------------------------------------------------------------------
	Local loRecord
	If not Empty (m.tcLocate)
		Locate &tcLocate
	EndIf
	Scatter name loRecord Memo
	
	*--------------------------------------------------------------------------------------
	* Restore environment
	*--------------------------------------------------------------------------------------
	If not Empty (m.lnRecNo)
		Locate RECORD m.lnRecNo
	EndIf
	Select (m.lnSelect)

Return m.loRecord

*========================================================================================
* Adds a property member
*========================================================================================
Procedure AddMember (toMaster, tcName, tuValue)

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.toMaster) == "O"
	Assert Vartype(m.tcName) == "C"
	
	*--------------------------------------------------------------------------------------
	* The property object keeps track of a few pieces we need to know about every simulated
	* property.
	*--------------------------------------------------------------------------------------
	Local loProperty
	loProperty = CreateObject("mockPropertyDefinition")
	loProperty.cName = m.tcName
	loProperty.uValue = m.tuValue

	*--------------------------------------------------------------------------------------
	* Register the new property in the master object
	*--------------------------------------------------------------------------------------
	toMaster.RegisterMember (m.loProperty)

EndProc

EndDefine 

*========================================================================================
* The Is operation sets the value for the current property
*========================================================================================
Define Class foxMock_Is as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension Is[1]
	
*========================================================================================
* Stores the value for the active property. Because VFP can only handle numbers and
* strings in an access method, we pass the expression instead of the value.
*========================================================================================
Procedure Is_Access (tcValue)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcValue) == "C"
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Store the value
	*--------------------------------------------------------------------------------------
	Local loMaster, loProperty
	loMaster = This.GetMaster()
	If loMaster.PropertyIsActive()
		loProperty = loMaster.GetActiveMember()
		loProperty.uValue = Evaluate(m.tcValue)
	Else
		Assert .F. Message "operation 'Is' only valid for properties"
	EndIf
		
Return m.loMaster

EndDefine 

*========================================================================================
* The IsObject operation sets the object value for the current property
*========================================================================================
Define Class foxMock_IsObject as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never use this.
	*--------------------------------------------------------------------------------------
	Dimension IsObject[1]
	
*========================================================================================
* Stores the value for the active property. We store the object key rather then the
* actual object.
*========================================================================================
Procedure IsObject_Access (tcId)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcId) == "C"
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Store the value
	*--------------------------------------------------------------------------------------
	Local loMaster, loProperty, loObj, loRepository
	loMaster = This.GetMaster()
	If loMaster.PropertyIsActive()
		loProperty = loMaster.GetActiveMember()
		loRepository = This.GetRepository()
		loObj = loRepository.Item(m.tcId)
		Assert Vartype(m.loObj) == "O"
		loProperty.uValue = m.loObj
	Else
		Assert .F. Message "operation 'IsObject' only valid for properties"
	EndIf
		
Return m.loMaster

EndDefine 

*========================================================================================
* Indicates that the following operation must occur in order to pass the test. 
*========================================================================================
Define Class foxMock_Expect as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Expect = null
	
*========================================================================================
* We set the expect flag in the master object. 
*========================================================================================
Procedure Expect_Access
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Every expectation is handled by an implementation that is created by a subsequent
	* operation. For instance, a CallTo operation expects a method to be called. This is
	* handled by the method definition.
	*--------------------------------------------------------------------------------------
	Local loExpectation
	loExpectation = CreateObject("Empty")
	AddProperty (loExpectation, "HandledBy", NULL)
	
	*--------------------------------------------------------------------------------------
	* Subsequent operations query the Expect flag
	*--------------------------------------------------------------------------------------
	Local loMaster
	loMaster = This.GetMaster()
	loMaster.NewExpectation (m.loExpectation)
	
Return m.loMaster

EndDefine 

*========================================================================================
* The CallTo operation adds a simulated method to the master object
*========================================================================================
Define Class foxMock_CallTo as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension CallTo[1]
	Dimension Method[1]
	
*========================================================================================
* Registers a new method for the mockup 
*========================================================================================
Procedure CallTo_Access (tcMethod)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcMethod) == "C"
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the master object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* We only use lower case names internally
	*--------------------------------------------------------------------------------------
	Local lcMethod
	lcMethod = Lower (m.tcMethod)

	*--------------------------------------------------------------------------------------
	* The method object keeps track of a few pieces we need to know about every simulated
	* method.
	*--------------------------------------------------------------------------------------
	Local loMethod, loMaster
	loMaster = This.GetMaster()
	loMethod = CreateObject("mockMethodDefinition")
	loMethod.cName = m.lcMethod
	loMaster.RegisterMember (m.loMethod)
	
Return m.loMaster

*========================================================================================
* Define aliases for this operation
*========================================================================================
Procedure Method_Access (tcMethod)
	Private foxMock__Accessor
	foxMock__Accessor = .T.
Return This.CallTo_Access (m.tcMethod)

EndDefine 

*========================================================================================
* The Return operation specifies the return value for a method
*========================================================================================
Define Class foxMock_ReturnOperation as foxMock

*========================================================================================
* Stores the return value for the active method.
*========================================================================================
Procedure Store (tuValue)
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Keep the value
	*--------------------------------------------------------------------------------------
	Local loMaster, loMethod
	loMaster = This.GetMaster()
	If loMaster.MethodIsActive()
		loMethod = loMaster.GetActiveMember()
		loMethod.SetReturnValue(m.tuValue)
	Else
		Assert .F. Message "operation of the 'Return'-family only valid for methods"
	EndIf
		
Return m.loMaster

EndDefine 

*========================================================================================
* The Return operation expects the return value as an expression
*========================================================================================
Define Class foxMock_Return as foxMock_ReturnOperation 

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension Return[1]
	Dimension Returns[1]
	
*========================================================================================
* Stores the return value for the active method. Because VFP can only handle numbers and
* strings in an access method, we pass the expression instead of the value.
*========================================================================================
Procedure Return_Access (tcValue)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcValue) == "C"
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

Return This.Store (Evaluate (m.tcValue))

*========================================================================================
* Define aliases for this operation
*========================================================================================
Procedure Returns_Access (tcMethod)
	Private foxMock__Accessor
	foxMock__Accessor = .T.
Return This.Return_Access (m.tcMethod)

EndDefine 

*========================================================================================
* The ReturnObject operation specifies the object that a method returns.
*========================================================================================
Define Class foxMock_ReturnObject as foxMock_ReturnOperation

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension ReturnObject[1]
	Dimension ReturnsObject[1]
	
*========================================================================================
* We keep a reference of the object in the method definition.
*========================================================================================
Procedure ReturnObject_Access (tcId)

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcId) == "C"
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Store the object
	*--------------------------------------------------------------------------------------
	Local loObj, loRepository
	loRepository = This.GetRepository()
	loObj = loRepository.Item(m.tcId)
	Assert Vartype(m.loObj) == "O"
	
Return This.Store (m.loObj)

*========================================================================================
* Define aliases for this operation
*========================================================================================
Procedure ReturnsObject_Access (tcMethod)
	Private foxMock__Accessor
	foxMock__Accessor = .T.
Return This.ReturnObject_Access (m.tcMethod)

EndDefine 

*========================================================================================
* Visual FoxPro can only chain property calls, but not method calls. To implement the
* fluent interface we therefore are limited to property accessors. What appears to be 
* a function call is technically an array access. The appearant parameter is the index
* specification.
*
* An index can only be a number or a string, even when an access method is used. The
* framework requires some operations that accept any value such as the Is() and Return()
* operations. For most parts we can simply pass an expression such as ".T." and evaluate
* this inside the operation.
*
* Unfortunately, this doesn't work well for objects. In order to deal with objects, we
* would either have to nest calls to mock object which raises scope and readability 
* issues, or create a private variable in the caller, assign the object and evaluate the
* name of the private variable.
*
* We pick a more accessible approach here. The AsObject operation stores the current
* master object in a collection using a unique key and returns the key as a string. Later
* we can pass this string into a function to retrieve the object from the collection.
*
* Important: Because this function returns a string, it stops the fluent interface.
*            AsObject must be the final operation in an expression.
*========================================================================================
Define Class foxMock_AsObject as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension AsObject[1]
	
*========================================================================================
* Store the master under a unique Id
*========================================================================================
Procedure AsObject_Access (tcId)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcId) $ "CN"
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Store the master
	*--------------------------------------------------------------------------------------
	Local loMaster, lcKey, loRepository
	loMaster = This.GetMaster()
	If Vartype(m.tcId) == "C"
		lcKey = m.tcId
	else
		lcKey = Sys(2015)
	EndIf
	loRepository = This.GetRepository()
	loRepository.Add(m.loMaster, m.lcKey)
		
Return m.lcKey

EndDefine 

*========================================================================================
* The when operation specifies alternative calling patterns for a single method.
*========================================================================================
Define Class foxMock_When as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension When[1]
	
*========================================================================================
* When receives a list of parameters in a single string. Later, when the simulated method
* is called, it compares the parameters against the ones specified here. Only if there's
* a match, the following actions apply. Otherwise the default action is carried out.
*========================================================================================
Procedure When_Access (tcParamList)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcParamList) == "C"
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Keep the value
	*--------------------------------------------------------------------------------------
	Local loMaster, loMethod, loCall
	loMaster = This.GetMaster()
	If loMaster.MethodIsActive()
		loMethod = loMaster.GetActiveMember()
		loCall = CreateObject("mockMethodCall", m.tcParamList)
		loMethod.AddCall (m.loCall)
	Else
		Assert .F. Message "operation 'when' only valid for methods"
	EndIf
		
Return m.loMaster

EndDefine 

*========================================================================================
* The then operation specifies a sequence of return values.
*========================================================================================
Define Class foxMock_Then as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Dimension Then[1]
	
*========================================================================================
* Then enables the return value queue. 
*========================================================================================
Procedure Then_Access
	
	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* enable the return value queue
	*--------------------------------------------------------------------------------------
	Local loMaster, loMethod, loCall
	loMaster = This.GetMaster()
	If loMaster.MethodIsActive()
		loMethod = loMaster.GetActiveMember()
		loMethod.EnableReturnValueQueue ()
	Else
		Assert .F. Message "operation 'then' only valid for methods"
	EndIf
		
Return m.loMaster

EndDefine 

*========================================================================================
* The Fail operation lets a method call break the test. You either use it when you want
* to make sure that nobody ever calls this method at all, or as the default action when
* you setup several When actions.
*========================================================================================
Define Class foxMock_Fail as foxMock

	*--------------------------------------------------------------------------------------
	* Just so that VFP can actually find the definition. We never us this.
	*--------------------------------------------------------------------------------------
	Fail = NULL
	
*========================================================================================
* Calling a method raises an error
*========================================================================================
Procedure Fail_Access

	*--------------------------------------------------------------------------------------
	* The following code operates on the object directly
	*--------------------------------------------------------------------------------------
	Private foxMock__Accessor
	foxMock__Accessor = .T.

	*--------------------------------------------------------------------------------------
	* Keep the value
	*--------------------------------------------------------------------------------------
	Local loMaster, loMethod, loCall
	loMaster = This.GetMaster()
	If loMaster.MethodIsActive()
		loMethod = loMaster.GetActiveMember()
		loMethod.SetAction ("fail")
	Else
		Assert .F. Message "operation 'fail' only valid for methods"
	EndIf
		
Return m.loMaster

EndDefine 

*========================================================================================
* Manages one possible outcome of a method call.
*========================================================================================
Define Class mockMethodCall as Custom

	uReturnValue = .T.
	lHasBeenCalled = .F.
	cAction = "return"
	cCondition = ""
	Dimension aCondition[23]
	lExpectation = .F.
	oQueue = null
	
*========================================================================================
* Upon creating a method call, we can pass a condition. Only when the actual call 
* meets these criteria, this MethodCall object will handle the call.
*========================================================================================
Procedure Init (tcCondition)
	
	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcCondition) $ "CL"
	
	*--------------------------------------------------------------------------------------
	* Evaluate all parameters and store the result in an array.
	*--------------------------------------------------------------------------------------
	If Vartype(m.tcCondition) == "C"
		This.cCondition = m.tcCondition
		This.EvaluateParameters (&tcCondition)
	EndIf
	
EndProc

*========================================================================================
* Store all parameters in the array
*========================================================================================
Procedure EvaluateParameters ( ;
	t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22,t23 ;
)

	Assert Pcount() <= Alen(This.aCondition)

	Local lnParam
	For lnParam = 1 to Pcount()
		This.aCondition[m.lnParam] = Evaluate ("t"+Transform (m.lnParam))
	EndFor 
	
EndProc

*========================================================================================
* Verifies that the actual outcome of a method call matches the expectation
*========================================================================================
Procedure VerifyExpectation
	If This.lExpectation
		Return This.lHasBeenCalled
	Else
		Return .T.
	EndIf
EndProc

*========================================================================================
* Tests if the current condition meets the parameters being passed. We use this to filter
* the MethodCall object that applies to a particular call.
*========================================================================================
Procedure Applies( ;
	t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22,t23 ;
)

	*--------------------------------------------------------------------------------------
	* If there's no condition defined, this method call always applies
	*--------------------------------------------------------------------------------------
	If Empty(This.cCondition)
		Return .T.
	EndIf

	*--------------------------------------------------------------------------------------
	* Otherwise we check if the values match the ones we have stored
	*--------------------------------------------------------------------------------------
	Local lnParam, luValue
	For lnParam = 1 to Pcount()
		luValue = Evaluate ("t"+Transform (m.lnParam))
		If Vartype (m.luValue) == Vartype (This.aCondition[m.lnParam])
			Do case
			Case IsNull(m.luValue) and IsNull(This.aCondition[m.lnParam])
				* matches
			Case m.luValue == This.aCondition[m.lnParam]
				* matches
			Otherwise 
				Return .F.
			EndCase 
		EndIf
	EndFor 

Return .T.

*========================================================================================
* Enables the return value queue. It's safe to call this method repeatedly.
*========================================================================================
Procedure EnableReturnValueQueue

	If Vartype (This.oQueue) != "O"
		This.oQueue = CreateObject ("Collection")
		This.oQueue.Add (This.uReturnValue)
		This.uReturnValue = .T.
	EndIf
	
EndProc

*========================================================================================
* Sets the return value. 
*========================================================================================
Procedure SetReturnValue (tuValue)

	If Vartype (This.oQueue) == "O"
		This.oQueue.Add (m.tuValue)
	Else
		This.uReturnValue = m.tuValue
	EndIf	

EndProc

*========================================================================================
* Returns the next value from either the queue or the storedd return value.
*========================================================================================
Procedure GetReturnValue ()

	Local luReturnValue
	If Vartype (This.oQueue) == "O" and This.oQueue.Count > 0
		luReturnValue = This.oQueue.Item (1)
		This.oQueue.Remove (1)
	Else
		luReturnValue = This.uReturnValue
	EndIf
	
Return m.luReturnValue

EndDefine

*========================================================================================
* Keeps track of a single simulated member
*========================================================================================
Define Class mockDefinition as Custom
	
	cName = ""
	oMaster = NULL
	lExpectation = .F.

*========================================================================================
* Returns an implementation of the property
*========================================================================================
Procedure GetImplementation (toMaster)

	Local loImplementation, lcScript
	lcScript = This.CreateClassDefinition()
	This.oMaster = m.toMaster
	Do (m.lcScript) with m.loImplementation, This

Return m.loImplementation

*========================================================================================
* We can't use EXECSCRIPT to create a class on the fly, because VFP deletes the FXP file
* when the script returns.
*========================================================================================
Procedure CreateClassDefinition

	Local lcScript, lcFile
	lcScript = This.GetStubDefinition (Sys(2015))
	lcFile = Addbs(GetEnv("TEMP")) + Sys(2015) + ".prg"
	StrToFile (m.lcScript, m.lcFile)
	Compile (m.lcFile)

Return m.lcFile

*========================================================================================
* abstract methods
*========================================================================================
Procedure GetStubDefinition	(tcClass)
Procedure Reset

EndDefine 

*========================================================================================
* Implements a FoxMock compatible object based on the 
*========================================================================================
Define Class mockFoundationDefinition as mockDefinition 
	
*========================================================================================
* Returns the class definition for the foundation class
*========================================================================================
Procedure GetStubDefinition	(tcClass)

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcClass) == "C"
		
	*--------------------------------------------------------------------------------------
	* Extract class and library name
	*--------------------------------------------------------------------------------------
	Local lcClass, lcLibrary
	lcClass = StrExtract(This.cName, "", "|", 1, 2)
	lcLibrary = StrExtract(This.cName, "|", "")
	
	*--------------------------------------------------------------------------------------
	* The script returns the new instance by reference, because we call it using the
	* DO command. We cannot use TEXTMERGE here, as the code might be triggered when we
	* access a mocked object from within a textmerge statement. VFP triggers in this case
	* an "Textmerge is recursive" error.
	*--------------------------------------------------------------------------------------
	Local lcScript
	lcScript = "" ;
		+'Lparameters roRef, toDefinition' + Chr(13)+Chr(10) ;
		+'roRef = CreateObject ("'+m.tcClass+'")' + Chr(13)+Chr(10) ;
		+'roRef.__oDefinition = m.toDefinition' + Chr(13)+Chr(10) ;
		+'Define Class '+m.tcClass+' as '+m.lcClass+' '+Iif(Empty(m.lcLibrary),"","OF")+' '+m.lcLibrary + Chr(13)+Chr(10) ;
		+'__oDefinition = NULL' + Chr(13)+Chr(10) ;
		+'Procedure This_Access (tcMember)' + Chr(13)+Chr(10) ;
		+'	If Vartype(foxMock__Accessor) == "L"' + Chr(13)+Chr(10) ;
		+'		Return This' + Chr(13)+Chr(10) ;
		+'	Else' + Chr(13)+Chr(10) ;
		+'		Private foxMock__Accessor' + Chr(13)+Chr(10) ;
		+'		foxMock__Accessor = .T.' + Chr(13)+Chr(10) ;
		+'	EndIf' + Chr(13)+Chr(10) ;
		+'	Local lcMember, loMaster' + Chr(13)+Chr(10) ;
		+'	lcMember = Lower(m.tcMember)' + Chr(13)+Chr(10) ;
		+'	loMaster = This.__oDefinition.oMaster' + Chr(13)+Chr(10) ;
		+'	If loMaster.Members.GetKey(m.lcMember) == 0' + Chr(13)+Chr(10) ;
		+'		If PemStatus(This.ParentClass, "This_Access", 5)' + Chr(13)+Chr(10) ;
		+'			Return DoDefault(m.tcMember)' + Chr(13)+Chr(10) ;
		+'		Else ' + Chr(13)+Chr(10) ;
		+'			Return This' + Chr(13)+Chr(10) ;
		+'		EndIf' + Chr(13)+Chr(10) ;
		+'	Else' + Chr(13)+Chr(10) ;
		+'		Local loImplementation' + Chr(13)+Chr(10) ;
		+'		loImplementation = loMaster.PrepareForTest (m.lcMember)' + Chr(13)+Chr(10) ;
		+'		loMaster.oKeepAlive = m.loImplementation' + Chr(13)+Chr(10) ;
		+'		Return m.loImplementation' + Chr(13)+Chr(10) ;
		+'	EndIf' + Chr(13)+Chr(10) ;
		+'EndDefine ' + Chr(13)+Chr(10)
	
Return m.lcScript

EndDefine 

*========================================================================================
* Keeps track of a single simulated property
*========================================================================================
Define Class mockPropertyDefinition as mockDefinition 
	
	uValue = .F.

*========================================================================================
* Returns the class definition for the method stub. 
*========================================================================================
Procedure GetStubDefinition	(tcClass)

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcClass) == "C"
		
	*--------------------------------------------------------------------------------------
	* The script returns the new instance by reference, because we call it using the
	* DO command.
	*--------------------------------------------------------------------------------------
	Local lcScript
	lcScript = "" ;
		+'Lparameters roRef, toDefinition' + Chr(13)+Chr(10) ;
		+'roRef = CreateObject ("'+m.tcClass+'", m.toDefinition)' + Chr(13)+Chr(10) ;
		+'Define Class '+m.tcClass+' as Custom' + Chr(13)+Chr(10) ;
		+'	'+This.cName+' = .F.' + Chr(13)+Chr(10) ;
		+'	oDefinition = Null' + Chr(13)+Chr(10) ;
		+'Procedure Init (toDefinition)' + Chr(13)+Chr(10) ;
		+'	This.oDefinition = m.toDefinition ' + Chr(13)+Chr(10) ;
		+'EndProc ' + Chr(13)+Chr(10) ;
		+'Procedure '+This.cName+'_Access' + Chr(13)+Chr(10) ;
		+'Return This.oDefinition.uValue' + Chr(13)+Chr(10) ;
		+'Procedure '+This.cName+'_Assign (tuValue)' + Chr(13)+Chr(10) ;
		+'	This.oDefinition.uValue = m.tuValue' + Chr(13)+Chr(10) ;
		+'EndProc ' + Chr(13)+Chr(10) ;
		+'EndDefine '

Return m.lcScript

EndDefine 

*========================================================================================
* Keeps track of a single simulated method
*========================================================================================
Define Class mockMethodDefinition as mockDefinition 
	
	nCurrentCall = 0
	
	Add Object Calls as Collection
	
*========================================================================================
* We always have a default method outcome
*========================================================================================
Procedure Init
	This.AddCall (CreateObject ("mockMethodCall"))
EndProc

*========================================================================================
* Adds a call and makes it the default
*========================================================================================
Procedure AddCall (toCall)

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.toCall) == "O"
	
	*--------------------------------------------------------------------------------------
	* Add the call
	*--------------------------------------------------------------------------------------
	This.Calls.Add (m.toCall)
	toCall.lExpectation = This.lExpectation
	This.nCurrentCall = This.Calls.Count	

EndProc

*========================================================================================
* Returns the class definition for the method stub. 
*========================================================================================
Procedure GetStubDefinition	(tcClass)

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcClass) == "C"
	
	*--------------------------------------------------------------------------------------
	* Generate the generic parameter list
	*--------------------------------------------------------------------------------------
	Local lcParams, lnParam
	lcParams = ""
	For lnParam = 1 to 23
		If not Empty(m.lcParams)
			lcParams = m.lcParams + ","
		EndIf
		lcParams = m.lcParams + "t" + Transform(m.lnParam)
	EndFor 
	
	*--------------------------------------------------------------------------------------
	* The script returns the new instance by reference, because we call it using the
	* DO command.
	*--------------------------------------------------------------------------------------
	Local lcScript
	lcScript = "" ;
		+'Lparameters roRef, tuValue' + Chr(13)+Chr(10) ;
		+'roRef = CreateObject ("'+m.tcClass+'", m.tuValue)' + Chr(13)+Chr(10) ;
		+'Define Class '+m.tcClass+' as Custom' + Chr(13)+Chr(10) ;
		+'	oDefinition = Null' + Chr(13)+Chr(10) ;
		+'Procedure Init (toDefinition)' + Chr(13)+Chr(10) ;
		+'	This.oDefinition = m.toDefinition' + Chr(13)+Chr(10) ;
		+'EndProc ' + Chr(13)+Chr(10) ;
		+'Procedure '+This.cName+' ('+m.lcParams+')' + Chr(13)+Chr(10) ;
		+'	Local lnCall, loCall' + Chr(13)+Chr(10) ;
		+'	For lnCall = This.oDefinition.Calls.Count to 1 Step -1' + Chr(13)+Chr(10) ;
		+'		loCall = This.oDefinition.Calls[m.lnCall]' + Chr(13)+Chr(10) ;
		+'		If loCall.Applies('+m.lcParams+')' + Chr(13)+Chr(10) ;
		+'			Exit' + Chr(13)+Chr(10) ;
		+'		EndIf ' + Chr(13)+Chr(10) ;
		+'	EndFor ' + Chr(13)+Chr(10) ;
		+'	loCall.lHasBeenCalled = .T.' + Chr(13)+Chr(10) ;
		+'	Do case' + Chr(13)+Chr(10) ;
		+'	Case m.loCall.cAction == "return"' + Chr(13)+Chr(10) ;
		+'		Return loCall.GetReturnValue()' + Chr(13)+Chr(10) ;
		+'	Case m.loCall.cAction == "fail"' + Chr(13)+Chr(10) ;
		+'		Local lcValues, lnParm' + Chr(13)+Chr(10) ;
		+'		lcValues = ""' + Chr(13)+Chr(10) ;
		+'		For lnParm = 1 to Pcount()' + Chr(13)+Chr(10) ;
		+'			lcValues = m.lcValues + " " + Transform(Evaluate("T"+Transform(m.lnParm)))' + Chr(13)+Chr(10) ;
		+'		EndFor' + Chr(13)+Chr(10) ;
		+'		If Empty(m.lcValues)' + Chr(13)+Chr(10) ;
		+'			Error 2005, "call to '+This.cName+' failed"' + Chr(13)+Chr(10) ;
		+'		Else' + Chr(13)+Chr(10) ;
		+'			Error 2005, "call to '+This.cName+' failed with" + m.lcValues' + Chr(13)+Chr(10) ;
		+'		EndIf' + Chr(13)+Chr(10) ;
		+'	EndCase' + Chr(13)+Chr(10) ;
		+'EndDefine ' + Chr(13)+Chr(10)
	
Return m.lcScript

*========================================================================================
* verifies that all calls with expecations have actually been called. The default call
* is a special case here as it is added before the expectation is registered. Therefore
* we check the handlers expectation flag if there's only one registered call
*========================================================================================
Procedure VerifyExpectation 

	If This.Calls.Count == 1 and This.lExpectation
		This.Calls[1].lExpectation = This.lExpectation
	EndIf
	
	Local loCall, llPassed
	llPassed = .T.
	For each loCall in This.Calls foxobject
		llPassed = m.llPassed and m.loCall.VerifyExpectation ()
	EndFor 

Return m.llPassed

*========================================================================================
* Sets the return value in the current method call outcome.
*========================================================================================
Procedure SetReturnValue (tuValue)

	Local loCall
	loCall = This.Calls[This.nCurrentCall]
	loCall.SetReturnValue (m.tuValue)
	
EndProc

*========================================================================================
* Enables the return value queue on the current call object
*========================================================================================
Procedure EnableReturnValueQueue 

	Local loCall
	loCall = This.Calls[This.nCurrentCall]
	loCall.EnableReturnValueQueue ()
	
EndProc

*========================================================================================
* Sets the action for the current method call outcome
*========================================================================================
Procedure SetAction (tcAction)

	Assert Vartype(m.tcAction) == "C"
	
	Local loCall
	loCall = This.Calls[This.nCurrentCall]
	loCall.cAction = m.tcAction

EndProc

*========================================================================================
* When the same method is declared a second time, we need to operate on the default
* call outcome, unless there's another When operation.
*========================================================================================
Procedure Reset
	This.nCurrentCall = 1
EndProc

EndDefine 

