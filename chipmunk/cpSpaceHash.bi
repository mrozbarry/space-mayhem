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

' The spatial hash is Chipmunk's default (and currently only) spatial index type.
' Based on a chained hash table.

' Used internally to track objects added to the hash
type cpHandle
    ' Pointer to the object
    obj as any ptr
    ' Retain count
    retain as integer
    ' Query stamp. Used to make sure two objects
    ' aren't identified twice in the same query.
    stamp as integer
end type

' Linked list element for in the chains.
type cpSpaceHashBin
    handle as cpHandle ptr
    nxt as cpSpaceHashBin ptr
end type

' BBox callback. Called whenever the hash needs a bounding box from an object.
#define cpSpaceHashBBFuncParam byval obj as any ptr
#define cpSpaceHashBBFunc function cdecl ( cpSpaceHashBBFuncParam ) as cpBB

type cpSpaceHash
    ' Number of cells in the table.
    numcells as integer
    ' Dimentions of the cells.
    celldim as cpFloat
	
    ' BBox callback.
    bbfunc as cpSpaceHashBBFunc

    ' Hashset of all the handles.
    handleSet as cpHashSet ptr
	
    table as cpSpaceHashBin ptr ptr
    ' List of recycled bins.
    bins as cpSpaceHashBin ptr

    ' Incremented on each query. See cpHandle.stamp.
    stamp as integer
end type

' Basic allocation/destruction functions.
declare function cpSpaceHashAlloc cdecl alias "cpSpaceHashAlloc" ( ) as cpSpaceHash ptr
declare function cpSpaceHashInit cdecl alias "cpSpaceHashInit" ( byval hash as cpSpaceHash ptr, byval celldim as cpFloat, byval cells as integer, byval bbfunc as cpSpaceHashBBFunc ) as cpSpaceHash ptr
declare function cpSpaceHashNew cdecl alias "cpSpaceHashNew" ( byval celldim as cpFloat, byval cells as integer, byval bbfunc as cpSpaceHashBBFunc ) as cpSpaceHash ptr

declare sub cpSpaceHashDestroy cdecl alias "cpSpaceHashDestroy" ( byval hash as cpSpaceHash ptr )
declare sub cpSpaceHashFree cdecl alias "cpSpaceHashFree" ( byval hash as cpSpaceHash ptr )

' Resize the hashtable. (Does not rehash! You must call cpSpaceHashRehash() if needed.)
declare sub cpSpaceHashResize cdecl alias "cpSpaceHashResize" ( byval hash as cpSpaceHash ptr, byval celldim as cpFloat, byval numcells as integer )

' Add an object to the hash.
declare sub cpSpaceHashInsert cdecl alias "cpSpaceHashInsert" ( byval hash as cpSpaceHash ptr, byval obj as any ptr, byval id as unsigned integer, byval bb as cpBB )
' Remove an object from the hash.
declare sub cpSpaceHashRemove cdecl alias "cpSpaceHashRemove" ( byval hash as cpSpaceHash ptr, byval obj as any ptr, byval id as unsigned integer )

' Iterator function
#define cpSpaceHashIteratorParam byval obj as any ptr, byval dat as any ptr
#define cpSpaceHashIterator sub cdecl ( cpSpaceHashIteratorParam )
' Iterate over the objects in the hash.
declare sub cpSpaceHashEach cdecl alias "cpSpaceHashEach" ( byval hash as cpSpaceHash ptr, byval func as cpSpaceHashIterator, byval dat as any ptr )

' Rehash the contents of the hash.
declare sub cpSpacehashRehash cdecl alias "cpSpaceHashRehash" ( byval hash as cpSpaceHash ptr )
' Rehash only a specific object.
declare sub cpSpaceHashRehashObject cdecl alias "cpSpacehashRehashObject" ( byval hash as cpSpaceHash ptr, byval obj as any ptr, byval id as unsigned integer )

' Query callback.
#define cpSpaceHashQueryFuncParam byval obj1 as any ptr, byval obj2 as any ptr, byval dat as any ptr
#define cpSpaceHashQueryFunc function cdecl ( cpSpaceHashQueryFuncParam ) as integer
' Query the hash for a given BBox.
declare sub cpSpaceHashQuery cdecl alias "cpSpaceHashQuery" ( byval hash as cpSpaceHash ptr, byval obj as any ptr, byval bb as cpBB, byval func as cpSpacehashQueryFunc, byval dat as any ptr )
' Run a query for the object, then insert it. (Optimized case)
declare sub cpSpaceHashQueryInsert cdecl alias "cpSpaceHashQueryInsert" ( byval hash as cpSpaceHash ptr, byval obj as any ptr, byval bb as cpBB, byval func as cpSpaceHashQueryFunc, byval dat as any ptr )
' Rehashes while querying for each object. (Optimized case) 
declare sub cpSpaceHashQueryRehash cdecl alias "cpSpaceHashQueryRehash" ( byval hash as cpSpaceHash ptr, byval func as cpSpaceHashQueryFunc, byval dat as any ptr )