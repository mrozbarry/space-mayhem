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

 ' FreeBASIC Headers by Chris Adams (Lithium)
 
' Number of frames that contact information should persist.
extern cp_contact_persistence alias "cp_contact_persistence" as integer

' User collision pair function.
#define cpCollFuncParam byval a as cpShape ptr, byval b as cpShape ptr, byval contacts as cpContact ptr, byval numContants as integer, byval normal_coef as cpFloat, byval dat as any ptr
#define cpCollFunc function cdecl ( cpCollFuncParam ) as integer

' Structure for holding collision pair function information.
' Used internally.
type cpCollPairFunc
    a as unsigned integer
    b as unsigned integer
    func as cpCollFunc
    dat as any ptr
end type

type cpSpace
	' Number of iterations to use in the impulse solver.
	iterations as integer
'	sleepTicks as integer
	
	' Self explanatory.
    gravity as cpVect
    damping as cpFloat
	
	' Time stamp. Is incremented on every call to cpSpaceStep().
    stamp as integer

	' The static and active shape spatial hashes.
    staticShapes as cpSpaceHash ptr
    activeShapes as cpSpaceHash ptr
	
	' List of bodies in the system.
    bodies as cpArray ptr
	' List of active arbiters for the impulse solver.
    arbiters as cpArray ptr
	' Persistant contact set.
    contactSet as cpHashSet ptr
	
	' List of joints in the system.
    joints as cpArray ptr
	
	' Set of collisionpair functions.
    collFuncSet as cpHashSet ptr
	' Default collision pair function.
    defaultPairFunc as cpCollPairFunc
end type

' Basic allocation/destruction functions.
declare function cpSpaceAlloc cdecl alias "cpSpaceAlloc" ( ) as cpSpace ptr
declare function cpSpaceInit cdecl alias "cpSpaceInit" ( byval spacep as cpSpace ptr ) as cpSpace ptr
declare function cpSpaceNew cdecl alias "cpSpaceNew" ( ) as cpSpace ptr

declare sub cpSpaceDestroy cdecl alias "cpSpaceDestroy" ( byval spacep as cpSpace ptr )
declare sub cpSpaceFree cdecl alias "cpSpaceFree" ( byval spacep as cpSpace ptr )

' Convenience function. Frees all referenced entities. (bodies, shapes and joints)
declare sub cpSpaceFreeChildren cdecl alias "cpSpaceFreeChildren" ( byval spacep as cpSpace ptr )

' Collision pair function management functions.
declare sub cpSpaceAddCollisionPairFunc cdecl alias "cpSpaceAddCollisionPairFunc" ( byval spacep as cpSpace ptr, byval a as unsigned integer, byval b as unsigned integer, byval func as cpCollFunc, byval dat as any ptr )
declare sub cpSpaceRemoveCollisionPairFunc cdecl alias "cpSpaceRemoveCollisionPairFunc" ( byval spacep as cpSpace ptr, byval a as unsigned integer, byval b as unsigned integer )
declare sub cpSpaceSetDefaultCollisionPairFunc cdecl alias "cpSpaceSetDefaultCollisionPairFunc" ( byval spacep as cpSpace ptr, byval func as cpCollFunc, byval dat as any ptr )

' Add and remove entities from the system.
declare sub cpSpaceAddShape cdecl alias "cpSpaceAddShape" ( byval pspace as cpSpace ptr, byval shape as cpShape ptr )
declare sub cpSpaceAddStaticShape cdecl alias "cpSpaceAddStaticShape" ( byval pspace as cpSpace ptr, byval shape as cpShape ptr )
declare sub cpSpaceAddBody cdecl alias "cpSpaceAddBody" ( byval pspace as cpSpace ptr, byval body as cpBody ptr )
declare sub cpSpaceAddJoint cdecl alias "cpSpaceAddJoint" ( byval pspace as cpSpace ptr, byval joint as cpJoint ptr )

declare sub cpSpaceRemoveShape cdecl alias "cpSpaceRemoveShape" ( byval pspace as cpSpace ptr, byval shape as cpShape ptr )
declare sub cpSpaceRemoveStaticShape cdecl alias "cpSpaceRemoveStaticShape" ( byval pspace as cpSpace ptr, byval shape as cpShape ptr )
declare sub cpSpaceRemoveBody cdecl alias "cpSpaceRemoveBody" ( byval pspace as cpSpace ptr, byval body as cpBody ptr )
declare sub cpSpaceRemoveJoint cdecl alias "cpSpaceRemoveJoint" ( byval pspace as cpSpace ptr, byval joint as cpJoint ptr )

' Iterator function for iterating the bodies in a space.
#define cpSpaceBodyIteratorParam byval body as cpBody ptr, byval dat as any ptr
#define cpSpaceBodyIterator sub cdecl ( cpSpaceBodyIteratorParam )
declare sub cpSpaceEachBody cdecl alias "cpSpaceEachBody" ( byval pspace as cpSpace ptr, byval func as cpSpaceBodyIterator, byval dat as any ptr )

' Spatial hash management functions.
declare sub cpSpaceResizeStaticHash cdecl alias "cpSpaceResizeStaticHash" ( byval pspace as cpSpace ptr, byval dimm as cpFloat, byval count as integer )
declare sub cpSpaceResizeActiveHash cdecl alias "cpSpaceResizeActiveHash" ( byval pspace as cpSpace ptr, byval dimm as cpFloat, byval count as integer )
declare sub cpSpaceRehashStatic cdecl alias "cpSpaceRehashStatic" ( byval pspace as cpSpace ptr )

' Update the space.
declare sub cpSpaceStep cdecl alias "cpSpaceStep" ( byval pspace as cpSpace ptr, byval dt as cpFloat )