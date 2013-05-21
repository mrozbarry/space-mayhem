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

' Determines how fast penetrations resolve themselves.
extern cp_bias_coef alias "cp_bias_coef" as cpFloat
' Amount of allowed penetration. Used to reduce vibrating contacts.
extern cp_collision_slop alias "cp_collision_slop" as cpFloat

' Data structure for contact points.
type cpContact
	' Contact point and normal.
    p as cpVect
    n as cpVect
	' Penetration distance.
    dist as cpFloat
	
	' Calculated by cpArbiterPreStep().
    r1 as cpVect
    r2 as cpVect
    nMass as cpFloat
    tMass as cpFloat
    bounce as cpFloat

	' Persistant contact information.
    jnAcc as cpFloat
    jtAcc as cpFloat
    jBias as cpFloat
    bias as cpFloat
	
	' Hash value used to (mostly) uniquely identify a contact.
    hash as unsigned integer
end type

' Contacts are always allocated in groups.
declare function cpContactInit cdecl alias "cpContactInit" ( byval con as cpContact ptr, byval p as cpVect, byval n as cpVect, byval dist as cpFloat, byval hash as unsigned integer ) as cpContact ptr

' Sum the contact impulses. (Can be used after cpSpaceStep() returns)
declare function cpContactSumImpulses cdecl alias "cpContactSumImpulses" ( byval contacts as cpContact ptr, byval numContacts as integer ) as cpVect
declare function cpContactSumImpulsesWithFriction cdecl alias "cpContactSumImpulsesWithFriction" ( byval contacts as cpContact ptr, byval numContacts as integer ) as cpVect

' Data structure for tracking collisions between shapes.
type cpArbiter
	' Information on the contact points between the objects.
    numContacts as integer
    contacts as cpContact ptr
	
	' The two shapes involved in the collision.
    a as cpShape ptr
    b as cpShape ptr
	
	' Calculated by cpArbiterPreStep().
    u as cpFloat
    e as cpFloat
    target_v as cpVect
	
	' Time stamp of the arbiter. (from cpSpace)
    stamp as integer
end type

' Basic allocation/destruction functions.
declare function cpArbiterAlloc cdecl alias "cpArbiterAlloc" ( ) as cpArbiter ptr
declare function cpArbiterInit cdecl alias "cpArbiterInit" ( byval arb as cpArbiter ptr, byval a as cpShape ptr, byval b as cpShape ptr, byval stamp as integer ) as cpArbiter ptr
declare function cpArbiterNew cdecl alias "cpArbiterNew" ( byval a as cpShape ptr, byval b as cpShape ptr, byval stamp as integer ) as cpArbiter ptr

declare sub cpArbiterDestroy cdecl alias "cpArbiterDestroy" ( byval arb as cpArbiter ptr )
declare sub cpArbiterFree cdecl alias "cpArbiterFree" ( byval arb as cpArbiter ptr )

' These functions are all intended to be used internally.
' Inject new contact points into the arbiter while preserving contact history.
declare sub cpArbiterInject cdecl alias "cpArbiterInject" ( byval arb as cpArbiter ptr, byval contacts as cpContact ptr, byval numContacts as integer )
' Precalculate values used by the solver.
declare sub cpArbiterPreStep cdecl alias "cpArbiterPreStep" ( byval arb as cpArbiter ptr, byval dt_inv as cpFloat )
' Run an iteration of the solver on the arbiter.
declare sub cpArbiterApplyImpulse cdecl alias "cpArbiterApplyImpulse" ( byval arb as cpArbiter ptr )
