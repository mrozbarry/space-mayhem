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

' TODO: Comment me!

extern cp_joint_bias_coef alias "cp_joint_bias_coef" as cpFloat

type cpJoint
    a as cpBody ptr
    b as cpBody ptr
    
    preStep as sub cdecl ( byval joint as cpJoint ptr, byval dt_div as cpFloat )
    applyImpulse as sub cdecl ( byval joint as cpJoint ptr )
end type

declare sub cpJointDestroy cdecl alias "cpJointDestroy" ( byval joint as cpJoint ptr )
declare sub cpJointFree cdecl alias "cpJointFree" ( byval joint as cpJoint ptr )

type cpPinJoint
    joint as cpJoint
    anchr1 as cpVect
    anchr2 as cpVect
    dist as cpFloat

    r1 as cpVect
    r2 as cpVect
    n as cpVect
    nMass as cpVect

    jnAcc as cpFloat
    jBias as cpFloat
    bias as cpFloat
end type

declare function cpPinJointAlloc cdecl alias "cpPinJointAlloc" ( ) as cpPinJoint ptr
declare function cpPinJointInit cdecl alias "cpPinJointInit" ( byval joint as cpPinJoint ptr, byval a as cpBody ptr, byval b as cpBody ptr, byval anchr1 as cpVect, byval anchr2 as cpVect ) as cpPinJoint ptr
declare function cpPinJointNew cdecl alias "cpPinJointNew" ( byval a as cpBody ptr, byval b as cpBody ptr, byval anchr1 as cpVect, byval anchr2 as cpVect ) as cpJoint ptr


type cpSlideJoint
    joint as cpJoint
    anchr1 as cpVect
    anchr2 as cpVect
    min as cpFloat
    max as cpFloat

    r1 as cpVect
    r2 as cpVect
    n as cpVect
    nMass as cpFloat

    jnAcc as cpFloat
    jBias as cpFloat
    bias as cpFloat
end type

declare function cpSlideJointAlloc cdecl alias "cpSlideJointAlloc" ( ) as cpSlideJoint ptr
declare function cpSlideJointInit cdecl alias "cpSlideJointInit" ( byval joint as cpSlideJoint ptr, byval a as cpBody ptr, byval b as cpBody ptr, byval anchr1 as cpVect, byval anchr2 as cpVect, byval min as cpFloat, byval max as cpFloat ) as cpSlideJoint ptr
declare function cpSlideJointNew cdecl alias "cpSlideJointNew" ( byval a as cpBody ptr, byval b as cpBody ptr, byval anchr1 as cpVect, byval anchr2 as cpVect, byval min as cpFloat, byval max as cpFloat ) as cpJoint ptr


type cpPivotJoint
    joint as cpJoint
    anchr1 as cpVect
    anchr2 as cpVect

    r1 as cpVect
    r2 as cpVect
    k1 as cpVect
    k2 as cpVect

    jAcc as cpVect
    jBias as cpVect
    bias as cpVect
end type

declare function cpPivotJointAlloc cdecl alias "cpPivotJointAlloc" ( ) as cpPivotJoint ptr
declare function cpPivotJointInit cdecl alias "cpPivotJointInit" ( byval joint as cpPivotJoint ptr, byval a as cpBody ptr, byval b as cpBody ptr, byval pivot as cpVect ) as cpPivotJoint ptr
declare function cpPivotJointNew cdecl alias "cpPivotJointNew" ( byval a as cpBody ptr, byval b as cpBody ptr, byval pivot as cpVect ) as cpJoint ptr


type cpGrooveJoint
    joint as cpJoint
    grv_n as cpVect
    grv_a as cpVect
    grv_b as cpVect
    anchr2 as cpVect
	
    grv_tn as cpVect
    clamp as cpFloat
    r1 as cpVect
    r2 as cpVect
    k1 as cpVect
    k2 as cpVect

    jAcc as cpVect
    jBias as cpVect
    bias as cpVect
end type

declare function cpGrooveJointAlloc cdecl alias "cpGrooveJointAlloc" ( ) as cpGrooveJoint ptr
declare function cpGrooveJointInit cdecl alias "cpGrooveJointInit" ( byval joint as cpGrooveJoint ptr, byval a as cpBody ptr, byval b as cpBody ptr, byval groove_a as cpVect, byval groove_b as cpVect, byval anchr2 as cpVect ) as cpGrooveJoint ptr
declare function cpGrooveJointNew cdecl alias "cpGrooveJointNew" ( byval a as cpBody ptr, byval b as cpBody ptr, byval groove_a as cpVect, byval groove_b as cpVect, byval anchr2 as cpVect ) as cpJoint ptr
