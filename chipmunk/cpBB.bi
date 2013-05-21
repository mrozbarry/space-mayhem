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
 
type cpBB
    l as cpFloat
    b as cpFloat
    r as cpFloat
    t as cpFloat
end type

function cpBBNew ( byval l as cpFloat, byval b as cpFloat, byval r as cpFloat, byval t as cpFloat ) as cpBB
    dim as cpBB bb
    bb.l = l
    bb.b = b
    bb.r = r
    bb.t = t
    return bb
end function

function cpBBintersects ( byval a as cpBB, byval b as cpBB ) as integer
    return (a.l <= b.r) and (b.l <= a.r) and (a.b <= b.t) and (b.b <= a.t)
end function

function cpBBcontainsBB ( byval bb as cpBB, byval other as cpBB ) as integer
    return (bb.l < other.l) and (bb.r > other.r) and (bb.b < other.b) and (bb.t > other.t)
end function

function cpBBcontainsVect ( byval bb as cpBB, byval v as cpVect ) as integer
    return (bb.l < v.x) and (bb.r > v.x) and (bb.b < v.y) and (bb.t > v.y)
end function

declare function cpBBClampVect cdecl alias "cpBBClampVect" ( byval bb as cpBB, byval v as cpVect ) as cpVect ' clamps the vector to lie within the bbox
declare function cpBBWrapVect cdecl alias "cpBBWrapVect" ( byval bb as cpBB, byval v as cpVect ) as cpVect ' wrap a vector to a bbox