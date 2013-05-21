 ' Copyright (c) 2007 Scott Lembcke
 ' 
 ' Permission is hereby granted, free of charge, to any person obtaining a copy
 ' of this software and associated documentation files (the "Software"), to deal
 ' in the Software without restriction, including without limitation the rights
 ' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 ' copies of the Software, and to permit persons to whom the Software is
 ' furnished to do so, subject to the following conditions:
 ' 
 ' The above copyright notice and this permission notice shall be included in
 ' all copies or substantial portions of the Software.
 ' 
 ' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 ' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 ' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 ' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 ' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 ' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 ' SOFTWARE.
 '
   
 ' FreeBASIC Headers by Chris Adams (Lithium)
  
' cpHashSet uses a chained hashtable implementation.
' Other than the transformation functions, there is nothing fancy going on.

' cpHashSetBin's form the linked lists in the chained hash table.
type cpHashSetBin
    ' Pointer to the element.
    elt as any ptr
    ' Hash value of the element.
    hash as unsigned integer
    ' Next element in the chain.
    nxt as cpHashSetBin ptr
end type

' Equality function. Returns true if ptr is equal to elt.
#define cpHashSetEqlFuncParam byval pt as any ptr, byval elt as any ptr
#define cpHashSetEqlFunc function cdecl ( cpHashSetEqlFuncParam ) as integer

' Used by cpHashSetInsert(). Called to transform the ptr into an element.
#define cpHashSetTransFuncParam byval pt as any ptr, byval dat as any ptr
#define cpHashSetTransFunc sub cdecl ( cpHashSetTransFuncParam )

' Iterator function for a hashset.
#define cpHashSetIterFuncParam byval pt as any ptr, byval dat as any ptr
#define cpHashSetIterFunc sub cdecl ( cpHashSetIterFuncParam )

' Reject function. Returns true if elt should be dropped.
#define cpHashSetRejectFuncParam byval pt as any ptr, byval dat as any ptr
#define cpHashSetRejectFunc function cdecl ( cpHashSetRejectFuncParam ) as integer

type cpHashSet
    ' Number of elements stored in the table.
    entries as integer
    ' Number of elements stored in the table.
    size as integer
    
    eql as cpHashSetEqlFunc
    trans as cpHashSetTransFunc

    ' Default value returned by cpHashSetFind() when no element is found.
	' Defaults to NULL.
    default_value as any ptr
    
    table as cpHashSetBin ptr ptr
end type

' Basic allocation/destruction functions.
declare sub cpHashSetDestroy cdecl alias "cpHashSetDestroy" ( byval set as cpHashSet ptr )
declare sub cpHashSetFree cdecl alias "cpHashSetFree" ( byval set as cpHashSet ptr )

declare function cpHashSetAlloc cdecl alias "cpHashSetAlloc" ( ) as cpHashSet ptr
declare function cpHashSetInit cdecl alias "cpHashSetInit" ( byval set as cpHashSet ptr, byval size as integer, byval eqlFunc as cpHashSetEqlFunc, byval trans as cpHashSetTransFunc ) as cpHashSet ptr
declare function cpHashSetNew cdecl alias "cpHashSetNew" ( byval size as integer, byval eqlFunc as cpHashSetEqlFunc, byval trans as cpHashSetTransFunc ) as cpHashSet ptr

' Insert an element into the set, returns the element.
' If it doesn't already exist, the transformation function is applied.
declare function cpHashSetInsert cdecl alias "cpHashSetInsert" ( byval set as cpHashSet ptr, byval hash as unsigned integer, byval pt as any ptr, byval dat as any ptr ) as any ptr
' Remove and return an element from the set.
declare function cpHashSetRemove cdecl alias "cpHashSetRemove" ( byval set as cpHashSet ptr, byval hash as unsigned integer, byval pt as any ptr ) as any ptr
' Find an element in the set. Returns the default value if the element isn't found.
declare function cpHashSetFind cdecl alias "cpHashSetFind" ( byval set as cpHashSet ptr, byval hash as unsigned integer, byval pt as any ptr ) as any ptr

' Iterate over a hashset.
declare sub cpHashSetEach cdecl alias "cpHashSetEach" ( byval set as cpHashSet ptr, byval func as cpHashSetIterFunc, byval dat as any ptr )
' Iterate over a hashset while rejecting certain elements.
declare sub cpHashSetReject cdecl alias "cpHashSetReject" ( byval set as cpHashSet ptr, byval func as cpHashSetRejectFunc, byval dat as any ptr )