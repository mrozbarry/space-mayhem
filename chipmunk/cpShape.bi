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

' For determinism, you can reset the shape id counter.
declare sub cpResetShapeIdCounter cdecl alias "cpResetShapeIdCounter" ( )

' Enumeration of shape types.
#define CP_CIRCLE_SHAPE 0
#define CP_SEGMENT_SHAPE 1
#define CP_POLY_SHAPE 2
#define CP_NUM_SHAPES 3
#define cpShapeType integer

' Basic shape struct that the others inherit from.
type cpShape
    stype as cpShapeType
    
	' Called by cpShapeCacheBB().
    cacheData as function cdecl ( byval shape as cpShape ptr, byval p as cpVect, byval rot as cpVect ) as cpBB
	' Called to by cpShapeDestroy().
    destroy as sub cdecl ( byval shape as cpShape ptr )
	
	' Unique id used as the hash value.
    id as unsigned integer
	' Cached BBox for the shape.
	bb as cpBB
	
	' User defined collision type for the shape.
    collision_type as unsigned integer
	' User defined collision group for the shape.
    group as unsigned integer
	' User defined layer bitmask for the shape.
    layers as unsigned integer
	
	' User defined data pointer for the shape.
    dat as any ptr
	
	' cpBody that the shape is attached to.
    body as cpBody ptr
	
	' Coefficient of restitution. (elasticity)
    e as cpFloat
	' Coefficient of friction.
    u as cpFloat
	' Surface velocity used when solving for friction.
    surface_v as cpVect
end type

' Low level shape initialization func.
declare function cpShapeInit cdecl alias "cpShapeInit" ( byval shape as cpShape ptr, byval stype as cpShapeType, byval body as cpBody ptr ) as cpShape ptr

' Basic destructor functions. (allocation functions are not shared)
declare sub cpShapeDestroy cdecl alias "cpShapeDestroy" ( byval shape as cpShape ptr )
declare sub cpShapeFree cdecl alias "cpShapeFree" ( byval shape as cpShape ptr )

' Cache the BBox of the shape.
declare function cpShapeCacheBB cdecl alias "cpShapeCacheBB" ( byval shape as cpShape ptr ) as cpBB

' Circle shape structure.
type cpCircleShape
    shape as cpShape
		
	' Center. (body space coordinates)
	c as cpVect
	' Radius.
	r as cpFloat
	
	' Transformed center. (world space coordinates)
	tc as cpVect
end type

' Basic allocation functions for cpCircleShape.
declare function cpCircleShapeAlloc cdecl alias "cpCircleShapeAlloc" ( ) as cpCircleShape ptr
declare function cpCircleShapeInit cdecl alias "cpCircleShapeInit" ( byval circle as cpCircleShape ptr, byval body as cpBody ptr, byval radius as cpFloat, byval offset as cpVect ) as cpCircleShape ptr
declare function cpCircleShapeNew cdecl alias "cpCircleShapeNew" ( byval body as cpBody ptr, byval radius as cpFloat, byval offset as cpVect ) as cpShape ptr

' Segment shape structure.
type cpSegmentShape
	shape as cpShape
	
	' Endpoints and normal of the segment. (body space coordinates)
    a as cpVect
    b as cpVect
    n as cpVect
	' Radius of the segment. (Thickness)
	r as cpFloat

	' Transformed endpoints and normal. (world space coordinates)
    ta as cpVect
    tb as cpVect
    tn as cpVect
end type

' Basic allocation functions for cpSegmentShape.
declare function cpSegmentShapeAlloc cdecl alias "cpSegmentShapeAlloc" ( ) as cpSegmentShape ptr
declare function cpSegmentShapeInit cdecl alias "cpSegmentShapeInit" ( byval seg as cpSegmentShape ptr, byval body as cpBody ptr, byval a as cpVect, byval b as cpVect, byval r as cpFloat ) as cpSegmentShape ptr
declare function cpSegmentShapeNew cdecl alias "cpSegmentShapeNew" ( byval body as cpBody ptr, byval a as cpVect, byval b as cpVect, byval r as cpFloat ) as cpShape ptr