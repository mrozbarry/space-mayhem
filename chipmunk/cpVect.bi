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

type cpVect
    x as cpFloat
    y as cpFloat
end type

dim shared as cpVect cpvzero
cpvzero.x = 0: cpvzero.y = 0

function cpv ( byval x as cpFloat, byval y as cpFloat ) as cpVect
    dim as cpVect ret
    ret.x = x
    ret.y = y
    return ret
end function

function cpvadd ( byval v1 as cpVect, byval v2 as cpVect ) as cpVect
    return cpv(v1.x+v2.x, v1.y+v2.y)
end function

function cpvneg ( byval v as cpVect ) as cpVect
    return cpv(-v.x, -v.y)
end function

function cpvsub ( byval v1 as cpVect, byval v2 as cpVect ) as cpVect
    return cpv(v1.x-v2.x, v1.y-v2.y)
end function

function cpvmult ( byval v as cpVect, byval s as cpFloat ) as cpVect
    return cpv(v.x*s, v.y*s)
end function

function cpvdot ( byval v1 as cpVect, byval v2 as cpVect ) as cpFloat
    return v1.x*v2.x + v1.y*v2.y
end function

function cpvcross ( byval v1 as cpVect, byval v2 as cpVect ) as cpFloat
    return v1.x*v2.y - v1.y*v2.x
end function

function cpvperp ( byval v as cpVect ) as cpVect
    return cpv(-v.y, v.x)
end function

function cpvrperp ( byval v as cpVect ) as cpVect
    return cpv(v.y, -v.x)
end function

function cpvproject ( byval v1 as cpVect, byval v2 as cpVect ) as cpVect
    return cpvmult(v2, cpvdot(v1, v2)/cpvdot(v2, v2))
end function

function cpvrotate ( byval v1 as cpVect, byval v2 as cpVect ) as cpVect
	return cpv(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x)
end function

function cpvunrotate ( byval v1 as cpVect, byval v2 as cpVect ) as cpVect
	return cpv(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y)
end function

declare function cpvlength cdecl alias "cpvlength" ( byval v as cpVect ) as cpFloat
declare function cpvlengthsq cdecl alias "cpvlengthsq" ( byval v as cpVect ) as cpFloat ' no SQR
declare function cpvnormalize cdecl alias "cpvnormalize" ( byval v as cpVect ) as cpVect
declare function cpvforangle cdecl alias "cpvforangle" ( byval a as cpFloat ) as cpVect ' convert radians to a normalize vector
declare function cpvtoangle cdecl alias "cpvtoangle" ( byval v as cpVect ) as cpFloat ' convert vector to radians
declare function __cpvstr cdecl alias "cpvstr" ( byval v as cpVect ) as ZString ptr ' get a string representation of a vector

function cpvstr ( byval v as cpVect ) as string
    return str(*__cpvstr(v))
end function
