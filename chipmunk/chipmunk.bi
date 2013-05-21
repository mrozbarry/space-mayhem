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

#define cpFloat single

function cpfmax ( byval a as cpFloat, byval b as cpFloat ) as cpFloat
    
    if (a>b) then return a: else return b
    
end function

function cpfmin ( byval a as cpFloat, byval b as cpFloat ) as cpFloat
    
    if (a<b) then return a: else return b
    
end function

#include "cpVect.bi"
#include "cpBB.bi"
#include "cpBody.bi"
#include "cpArray.bi"
#include "cpHashSet.bi"
#include "cpSpaceHash.bi"

#include "cpShape.bi"
#include "cpPolyShape.bi"

#include "cpArbiter.bi"
#include "cpCollision.bi"
	
#include "cpJoint.bi"

#include "cpSpace.bi"

#define CP_HASH_COEF (3344921057ul)
#define CP_HASH_PAIR(A, B) (((unsigned integer)(A)*CP_HASH_COEF) xor ((unsigned integer)(B)*CP_HASH_COEF))

#define INFINITY (1.0e0 / 0)

declare sub cpInitChipmunk cdecl alias "cpInitChipmunk" ( )

declare function cpMomentForCircle cdecl alias "cpMomentForCircle" ( byval m as cpFloat, byval r1 as cpFloat, byval r2 as cpFloat, byval offset as cpVect) as cpFloat
declare function cpMomentForPoly cdecl alias "cpMomentForPoly" ( byval m as cpFloat, byval numVerts as integer, byval verts as cpVect ptr, byval offset as cpVect) as cpFloat