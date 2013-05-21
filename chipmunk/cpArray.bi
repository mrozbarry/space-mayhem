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
 
' NOTE: cpArray is rarely used and will probably go away.

type cpArray
    num as integer
    max as integer
    arr as any ptr ptr
end type

#define cpArrayIterParam byval pt as any ptr, byval dat as any ptr
#define cpArrayIter sub cdecl ( cpArrayIterParam )

'typedef void (*cpArrayIter)(void *ptr, void *data);

declare function cpArrayAlloc cdecl alias "cpArrayAlloc" ( ) as cpArray ptr
declare function cpArrayInit cdecl alias "cpArrayInit" ( byval arr as cpArray ptr, byval size as integer ) as cpArray ptr
declare function cpArrayNew cdecl alias "cpArrayNew" ( byval size as integer ) as cpArray ptr

declare sub cpArrayDestroy cdecl alias "cpArrayDestroy" ( byval arr as cpArray ptr )
declare sub cpArrayFree cdecl alias "cpArrayFree" ( byval arr as cpArray ptr )

sub cpArrayDeepFree ( byval arr as cpArray ptr )
    dim as integer i
    for i = 0 to arr->num-1
        deallocate arr->arr[i]
    next i
    cpArrayFree ( arr )
end sub

declare sub cpArrayClear cdecl alias "cpArrayClear" ( byval arr as cpArray ptr )

declare sub cpArrayPush cdecl alias "cpArrayPush" ( byval arr as cpArray ptr, byval object as any ptr )
declare sub cpArrayDeleteIndex cdecl alias "cpArrayDeleteIndex" ( byval arr as cpArray ptr, byval index as integer )
declare sub cpArrayDeleteObj cdecl alias "cpArrayDeleteObj" ( byval arr as cpArray ptr, byval obj as any ptr )

declare sub cpArrayEach cdecl alias "cpArrayEach" ( byval arr as cpArray ptr, byval iterFunc as cpArrayIter, byval dat as any ptr )

declare function cpArrayContains cdecl alias "cpArrayContains" ( byval arr as cpArray ptr, byval p as any ptr ) as integer
