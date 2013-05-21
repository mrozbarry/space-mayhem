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

' Axis structure used by cpPolyShape.
type cpPolyShapeAxis
	' normal
    n as cpVect
	' distance from origin
    d as cpFloat
end type

' Convex polygon shape structure.
type cpPolyShape
	shape as cpShape
	
	' Vertex and axis lists.
    numVerts as integer
    verts as cpVect ptr
    axes as cpPolyShapeAxis ptr

	' Transformed vertex and axis lists.
    tVerts as cpVect ptr
	tAxes as cpPolyShapeAxis ptr
end type

' Basic allocation functions.
declare function cpPolyShapeAlloc cdecl alias "cpPolyShapeAlloc" ( ) as cpPolyShape ptr
declare function cpPolyShapeInit cdecl alias "cpPolyShapeInit" ( byval poly as cpPolyShape ptr, byval body as cpBody ptr, byval numVerts as integer, byval verts as cpVect ptr, byval offset as cpVect ) as cpPolyShape ptr
declare function cpPolyShapeNew cdecl alias "cpPolyShapeNew" ( byval body as cpBody ptr, byval numVerts as integer, byval verts as cpVect ptr, byval offset as cpVect ) as cpShape ptr

' Returns the minimum distance of the polygon to the axis.
function cpPolyShapeValueOnAxis ( byval poly as cpPolyShape ptr, byval n as cpVect, byval d as cpFloat ) as cpFloat

    dim as cpVect ptr verts = poly->tVerts
    dim as cpFloat min = cpvdot(n, verts[0])

    dim as integer i
    for i=1 to poly->numVerts-1
		min = cpfmin(min, cpvdot(n, verts[i]))
    next i
	
	return min - d

end function

' Returns true if the polygon contains the vertex.
function cpPolyShapeContainsVerts ( byval poly as cpPolyShape ptr, byval v as cpVect ) as integer

    dim as cpPolyShapeAxis ptr axes = poly->tAxes
    dim as integer i
    
    for i=0 to poly->numVerts-1
		dim as cpFloat dist = cpvdot(axes[i].n, v) - axes[i].d
		if dist > 0.0 then return 0
	next i

    return 1

end function
