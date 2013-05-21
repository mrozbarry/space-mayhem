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

type cpBody
    ' Mass and it's inverse.
    m as cpFloat
    m_inv as cpFloat
    ' Moment of inertia and it's inverse.
    i as cpFloat
    i_inv as cpFloat

    ' NOTE: v_bias and w_bias are used internally for penetration/joint correction.
	' Linear components of motion (position, velocity, and force)
	p as cpVect
    v as cpVect
    f as cpVect
    v_bias as cpVect
    ' Angular components of motion (angle, angular velocity, and torque)
    a as cpFloat
    w as cpFloat
    t as cpFloat
    w_bias as cpFloat
    
    ' Unit length
    rot as cpVect
end type

' Basic allocation/destruction functions
declare function cpBodyAlloc cdecl alias "cpBodyAlloc" () as cpBody ptr
declare function cpBodyInit cdecl alias "cpBodyInit" ( byval body as cpBody ptr, byval m as cpFloat, byval i as cpFloat ) as cpBody ptr
declare function cpBodyNew cdecl alias "cpBodyNew" ( byval m as cpFloat, byval i as cpFloat ) as cpBody ptr

declare sub cpBodyDestroy cdecl alias "cpBodyDestroy" ( byval body as cpBody ptr )
declare sub cpBodyFree cdecl alias "cpBodyFree" ( byval body as cpBody ptr )

' Setters for some of the special properties (mandatory!)
declare sub cpBodySetMass cdecl alias "cpBodySetMass" ( byval body as cpBody ptr, byval m as cpFloat )
declare sub cpBodySetMoment cdecl alias "cpBodySetMoment" ( byval body as cpBody ptr, byval i as cpFloat )
declare sub cpBodySetAngle cdecl alias "cpBodySetAngle" ( byval body as cpBody ptr, byval a as cpFloat )

' Modify the velocity of an object so that it will 
declare sub cpBodySlew cdecl alias "cpBodySlew" ( byval body as cpBody ptr, byval p as cpVect, byval dt as cpFloat )

' Integration functions.
declare sub cpBodyUpdateVelocity cdecl alias "cpBodyUpdateVelocity" ( byval body as cpBody ptr, byval gravity as cpVect, byval damping as cpFloat, byval dt as cpFloat )
declare sub cpBodyUpdatePosition cdecl alias "cpBodyUpdatePosition" ( byval body as cpBody ptr, byval dt as cpFloat )

' Convert body local to world coordinates
function cpBodyLocal2World ( byval body as cpBody ptr, byval v as cpVect ) as cpVect
    return cpvadd(body->p, cpvrotate(v, body->rot))
end function

' Convert world to body local coordinates
function cpBodyWorld2Local ( byval body as cpBody ptr, byval v as cpVect ) as cpVect
    return cpvunrotate(cpvsub(v, body->p), body->rot)
end function

' Apply an impulse (in world coordinates) to the body.
sub cpBodyApplyImpulse ( byval body as cpBody ptr, byval j as cpVect, byval r as cpVect )
	body->v = cpvadd(body->v, cpvmult(j, body->m_inv))
    body->w += body->i_inv*cpvcross(r, j)
end sub

' Not intended for external use. Used by cpArbiter.c and cpJoint.c.
sub cpBodyApplyBiasImpulse ( byval body as cpBody ptr, byval j as cpVect, byval r as cpVect )
	body->v_bias = cpvadd(body->v_bias, cpvmult(j, body->m_inv))
	body->w_bias += body->i_inv*cpvcross(r, j)
end sub

' Zero the forces on a body.
declare sub cpBodyResetForces cdecl alias "cpBodyResetForces" ( byval body as cpBody ptr )
' Apply a force (in world coordinates) to a body.
declare sub cpBodyApplyForce cdecl alias "cpBodyApplyForce" ( byval body as cpBody ptr, byval f as cpVect, byval r as cpVect )

' Apply a damped spring force between two bodies.
declare sub cpDampedSpring cdecl alias "cpDampedSpring" ( byval a as cpBody ptr, byval b as cpBody ptr, byval anchr1 as cpVect, byval anchr2 as cpVect, byval rlen as cpFloat, byval k as cpFloat, byval dmp as cpFloat, byval dt as cpFloat )

'int cpBodyMarkLowEnergy(cpBody *body, cpFloat dvsq, int max);
