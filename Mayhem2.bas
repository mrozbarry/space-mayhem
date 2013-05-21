#include "fbgfx.bi"
'#include "createtex.bi"
#include "chipmunk/chipmunk.bi"
using FB

const as double pi = 3.1415926, pi_180 = pi / 180

const as integer FPS = 60.0
#define FRAMESTEPS (fix(12*(60/(FPS*2))))

#define GetTicks (cast(single, TIMER) * 1000)

const MAX_PARTICLES = 300
const UNIT_PARTICLE = 0.05
const PARTICLE_LIFE = 0.6
const EXPLOSION_LIFE = 2.0
const PRT_FIRE = -1
const PRT_BLUE = -2
const PRT_BOMB = -3
const PRT_MASS = 10.0

const MAX_MISSLES = 250

enum Collision_Obj_ID
	id_None
	id_Ship
	id_Thruster
	id_Bullet
	id_Surface
	id_Unknown
end enum

type collision_info
	obj_id			as integer
	player_id		as integer
	obj_index		as integer
end type

type any_data
	mass	as cpFloat
	size	as cpFloat
	e		as cpFloat
	u		as cpFloat
end type

type environment_data
	ship		as any_data
	thruster	as any_data
	missle		as any_data
	
	thrust_force	as cpFloat
	fire_rate	as cpFloat
	
	gravity		as cpFloat
end type

type surface_type
	
	land(4)		as cpVect
	staticBody	as cpBody ptr
	id			as integer
	cinfo		as collision_info
	
end type

type main_part_type
	body	as cpBody ptr
	shape	as cpShape ptr
	id		as integer
	cinfo		as collision_info
end type

type spare_part_type
	body	as cpBody ptr
	shape	as cpShape ptr
	joint	as cpJoint ptr
	cinfo		as collision_info
	id		as integer
end type

type missle_type
	shaft	as main_part_type
	control	as spare_part_type
	init	as ubyte
	dead	as integer
	owner	as integer
	cinfo	as collision_info
end type

type spaceship
	body	as main_part_type
	thruster(0 to 1)	as spare_part_type
	shields	as spare_part_type
	
	init		as ubyte
	colour		as integer
	position	as cpVect
	angle		as ushort
	
	num			as integer
	
	dead		as ubyte
	respawn		as double
	
	lastfire	as double
	posfire		as byte
	
	shielding	as ubyte
	health		as ubyte
end type

type particle_type
	inuse as integer
	passive as integer
	sz as cpFloat
	body as cpBody ptr
	shape as cpShape ptr
	last_v as cpVect
	clr as integer
	startTime as double
	life as double
	t as double
	id as integer
end type

/'type id_factory
	
	' ID Tag: 32 Bit Integer
	' 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
	' Bits: 00-07 -> byte -> player identification (which player does this belong to?)...-1 = world ownership
	' Bits: 08-15 -> ubyte -> classification: partice{ thruster, damage, weapon, etc. }, vehicle{ body, thruster, wing, weapon pod }, surface{ wall, landing pad, asteroid, etc. }
	' Bits: 16-23 -> ubyte -> augment type - if there are multiple sets for bits 00-15
	' Bits: 24-31 -> byte -> reserved for future use
	
	declare function generate( )
	declare sub release( byval id as integer = -1 )
	
	max				as integer
	stock(0 to 399)	as integer
	
end type'/

declare sub init ( )
declare sub deinit ( )

declare sub play ( )

declare sub update ( )

declare sub spawnShip( byval p as spaceship ptr, byval x as integer, byval y as integer, byval num as integer, byval colour as integer = &hbcbcbc )
declare sub cleanShipJoints( byval p as spaceship ptr )
declare sub cleanShip( byval p as spaceship ptr )
declare sub thrusterShip( byval p as spaceship ptr )
declare sub turnShip( byval p as spaceship ptr, byval ang as cpFloat )
declare sub updateShips ( )
declare sub drawShip( byval p as spaceship ptr )

declare sub spawnMissle( byval fromShip as spaceship ptr, byval ship_index as integer, byval colour as integer = &hbcbcbc )
declare sub cleanMissle( byval p as missle_type ptr )
declare sub updateMissles ( )
declare sub drawMissles ( )

declare sub addParticle ( byval p as cpVect, byval v as cpVect, byval sz as cpVect, byval life as cpFloat, byval clr as integer, byval passive as integer = 1 )
declare sub updateParticles ( )
declare sub drawParticles ( )

declare sub drawLand()

declare sub frameLock ( byval reinit as integer )

declare function cbCollision cdecl ( byval a as cpShape ptr, byval b as cpShape ptr, byval contacts as cpContact ptr, byval numContants as integer, byval normal_coef as cpFloat, byval dat as any ptr ) as integer

declare sub rotozoom( byref dst as FB.IMAGE ptr = 0, byref src as const FB.IMAGE ptr, byval positx as integer, byval posity as integer, byref angle as integer, byref zoomx as single, byref zoomy as single, byval transcol as uinteger  = &hffff00ff)

'' Game Variables
dim shared gSpace as cpSpace Ptr
dim shared as cpBody Ptr staticBody
'dim shared as spaceship testship
dim shared as spaceship player(0 to 3)
dim shared surface as surface_type
dim shared as environment_data  environment
dim shared as particle_type prt(0 to MAX_PARTICLES-1)
dim shared as integer prt_largest = 0
dim shared as missle_type msl(0 to MAX_MISSLES-1)
dim shared as integer msl_largest = 0

'' Framerate Variables
dim shared as integer frameCounter = 0
dim shared frate as integer = 0
dim shared fcount as integer = 0
dim shared ftime as double

' -- Entry Point ***********************************************************
' Setup FB's Graphics Mode
ScreenRes 800, 600, 32, 2, GFX_ALPHA_PRIMITIVES or GFX_ALWAYS_ON_TOP
ScreenSet 1, 0
' Initialize Chipmunk Physics
cpInitChipmunk()

dim key as string * 1

dim mainImg as any ptr = ImageCreate( 304, 100 )
dim blurbImg as any ptr = ImageCreate( 500, 200 )
dim instructImg as any ptr = ImageCreate( 500, 56 )

bload "./gfx/mayhem.bmp", mainImg
bload "./gfx/blurb.bmp", blurbImg
bload "./gfx/instruct.bmp", instructImg

while len( inkey ): wend

do
	cls
	
	put( 248, 50 ), mainImg, TRANS
	put( 150, 200 ), blurbImg, TRANS
	put( 150, 530 ), instructImg, TRANS

	screencopy
	flip
	
	key = input( 1 )
	if key = chr( 27 ) then
		exit do
	elseif len( trim( key ) ) then
		init()
		play()
		deinit()
		while len( inkey ): wend
	end if
loop

ImageDestroy( instructImg )
ImageDestroy( blurbImg )
ImageDestroy( mainImg )

end 0
' -- Exit Point ***********************************************************

sub play()
	
	dim i as integer, id as integer
	
	for i = 0 to 3
		spawnShip( @player(i), 280 + (i * 80), 90, i, RGB( rnd*255, rnd*255, rnd*255 ) )
	next i
	
	ftime = TIMER + 1
	while not multikey( SC_ESCAPE )
		cls
		
		'locate 1,1: Print Using "Frame Rate: ####fps"; frate
		
		id = 0
		if player( id ).dead = 0 then
			if multikey( SC_UP ) then
				thrusterShip( @player(id) )
			end if		
			if multikey( SC_LEFT ) then
				turnShip( @player(id), -1 )
			end if		
			if multikey( SC_RIGHT ) then
				turnShip( @player(id), 1 )
			end if
			if multikey( SC_DOWN ) then
				if TIMER - player( id ).lastfire > environment.fire_rate  then
					spawnMissle( @player( id ), id )
				end if
			end if
		end if

		id = 1
		if player( id ).dead = 0 then
			if multikey( SC_W ) then
				thrusterShip( @player(id) )
			end if		
			if multikey( SC_A ) then
				turnShip( @player(id), -1 )
			end if		
			if multikey( SC_D ) then
				turnShip( @player(id), 1 )
			end if
			if multikey( SC_S ) then
				if TIMER - player( id ).lastfire > environment.fire_rate  then
					spawnMissle( @player( id ), id )
				end if
			end if
		end if
		
		id = 2
		if player( id ).dead = 0 then
			if multikey( SC_T ) then
				thrusterShip( @player(id) )
			end if		
			if multikey( SC_F ) then
				turnShip( @player(id), -1 )
			end if		
			if multikey( SC_H ) then
				turnShip( @player(id), 1 )
			end if
			if multikey( SC_G ) then
				if TIMER - player( id ).lastfire > environment.fire_rate  then
					spawnMissle( @player( id ), id )
				end if
			end if
		end if
		
		id = 3
		if player( id ).dead = 0 then
			if multikey( SC_I ) then
				thrusterShip( @player(id) )
			end if		
			if multikey( SC_J ) then
				turnShip( @player(id), -1 )
			end if		
			if multikey( SC_L ) then
				turnShip( @player(id), 1 )
			end if
			if multikey( SC_K ) then
				if TIMER - player( id ).lastfire > environment.fire_rate  then
					spawnMissle( @player( id ), id )
				end if
			end if
		end if
		
		update()
		updateShips()
		updateParticles()
		updateMissles()
		
		frameLock( 0 )
		if (TIMER - ftime) >= 1 then
			frate = fcount
			fcount = 0
			ftime = TIMER + 1
		end if
		
		' Draw Functions
		for i = 0 to 3
			drawShip( @player(i) )
		next i
		drawParticles( )
		drawMissles ( )
		drawLand()
		
		screencopy
		flip
		
		frameCounter += 1
		fcount += 1
	wend
	
	for i = 0 to 3
		cleanShipJoints( @player(i) )
		cleanShip( @player(i) )
		player(i).init = 0
	next i
	
end sub

sub update( )
	
	dim dt as cpFloat
	dim as integer i, j
	
	dim as cpFloat ifr = iif( frate = 0, (FPS*2), frate )
	
	dt = 1.0 / ifr / FRAMESTEPS
	
	for i = 1 to FRAMESTEPS
		cpSpaceStep( gSpace, dt )
	next i

end sub

sub spawnShip( byval p as spaceship ptr, byval x as integer, byval y as integer, byval num as integer, byval colour as integer )
	
	if (p->init = 1) then
		cleanShip( p )
	end if
	
	p->colour = colour
	p->lastfire = TIMER
	p->num = num
	p->dead = 0
	p->respawn = 0
	p->posfire = 0
	
	dim as cpVect px(4)
	dim i as integer, j as integer
	
	with p->body
		.body = cpBodyNew( environment.ship.mass, cpMomentForCircle(environment.ship.mass, environment.ship.size, 0, cpvzero) )
		.body->p = cpv( x, y )
		cpSpaceAddBody( gSpace, .body )
		.shape = cpCircleShapeNew( .body, environment.ship.size, cpvzero )
		.shape->e = environment.ship.e: .shape->u = environment.ship.u
		.id = id_Ship
		.cinfo.obj_id = .id
		.cinfo.player_id = num
		.cinfo.obj_index = num
		.shape->dat = @.cinfo
		cpSpaceAddShape( gSpace, .shape )
	end with
	
	dim offset as cpVect
	offset = cpv( environment.ship.size * -1.3, environment.ship.size * 0.75 )
	
	for i = 0 to 1
		with p->thruster( i )
			.body = cpBodyNew( environment.thruster.mass, cpMomentForCircle( environment.thruster.mass, environment.thruster.size, 0, cpvzero ) )
			
			.body->p = cpvadd( p->body.body->p, offset )
			cpSpaceAddBody( gSpace, .body )
			.shape = cpCircleShapeNew( .body, environment.thruster.size, cpvzero )
			.shape->e = environment.thruster.e: .shape->u = environment.thruster.u
			.id = id_Thruster
			.cinfo.obj_id = .id
			.cinfo.player_id = num
			.cinfo.obj_index = num
			.shape->dat = @.cinfo
			cpSpaceAddShape( gSpace, .shape )
			.joint = cpPinJointNew( .body, p->body.body, cpvzero, offset )
			cpSpaceAddJoint( gSpace, .joint )
		end with
		offset.x *= -1
	next i
	
	p->init = 1
	
end sub

sub cleanShipJoints( byval p as spaceship ptr )
	if p = 0 then return
	dim i as integer
	for i = 0 to 1
		cpSpaceRemoveJoint( gSpace, p->thruster(i).joint )
	next i
end sub

sub cleanShip( byval p as spaceship ptr )
	if p = 0 then return
	dim i as integer
	for i = 0 to 1
		cpSpaceRemoveShape( gSpace, p->thruster(i).shape)
		cpSpaceRemoveBody( gSpace, p->thruster(i).body )
	next i
	cpSpaceRemoveShape( gSpace, p->body.shape )
	cpSpaceRemoveBody( gSpace, p->body.body )
end sub

sub thrusterShip( byval p as spaceship ptr )
	dim i as integer
	p->body.body->w = 0
	p->body.body->t = 0
	dim as cpVect v = cpvforangle(p->body.body->a+PI/2)
	cpBodyApplyImpulse( p->body.body, cpvmult(v, environment.thrust_force), cpvzero )
	for i = 0 to 1
		p->thruster(i).body->w = 0
		p->thruster(i).body->t = 0
		cpBodyApplyImpulse( p->thruster(i).body, cpvmult(v, environment.thrust_force), cpvzero )
	next i
	if (frameCounter And 2) = 0 then
		for i = 0 to 1
			addParticle ( p->thruster(i).body->p, cpvzero, cpv(1.3, 1.3), 1.0, PRT_FIRE, 1 )
		next i
	end if
end sub

sub turnShip( byval p as spaceship ptr, byval ang as cpFloat )
	dim as cpFloat dt = 1.0/iif(frate = 0, FPS*2, frate)/FRAMESTEPS
	dim as integer j
	p->body.body->w = 0
	p->body.body->t = 0
	for j=1 to FRAMESTEPS
		cpBodySetAngle( p->body.body, p->body.body->a + ((PI/2) / 30 * sgn( ang ) )  )
	next j
end sub

sub updateShips ( )
	dim i as integer
	for i = 0 to 3
		if player( i ).dead then
			if player( i ).respawn = 0 then
				cleanShipJoints( @player( i ) )
				player( i ).respawn = TIMER + 8
			elseif player( i ).respawn < TIMER then
				spawnShip( @player( i ), 400, 300, i, player( i ).colour )
			end if
		end if
	next i
end sub

sub drawShip( byval p as spaceship ptr )
	
	dim i as integer
	dim as integer dx, dy
	
	circle ( p->body.body->p.x, p->body.body->p.y ), environment.ship.size, p->colour

	dx = sin( p->body.body->a ) * environment.ship.size
	dy = -cos( p->body.body->a ) * environment.ship.size
	line ( p->body.body->p.x, p->body.body->p.y )-STEP( dx, dy ), rgb( 255, 100, 100 )

	dx = sin( cpvtoangle( p->body.body->v ) ) * (environment.ship.size / 2)
	dy = cos( cpvtoangle( p->body.body->v ) ) * (environment.ship.size / 2)
	line ( p->body.body->p.x, p->body.body->p.y )-STEP( dx, dy ), rgb( 100, 255, 100 )
	
	for i = 0 to 1
		circle( p->thruster(i).body->p.x, p->thruster(i).body->p.y ), environment.thruster.size, p->colour
	next i
	
end sub

sub spawnMissle( byval fromShip as spaceship ptr, byval ship_index as integer, byval colour as integer = &hbcbcbc )
	
	dim p as missle_type ptr
	dim i as integer, j as integer
	
	dim found as byte = 0
	for i = 0 to MAX_MISSLES-1
		if (msl( i ).init = 0) or (msl( i ).dead = 1) then
			found = 1
			exit for
		end if
	next i
	' Can't shoot, too many missles active
	if found = 0 then return
	
	if msl( i ).init then
		cleanMissle( @msl( i ) )
	end if
	
	if i > msl_largest then msl_largest = i
	
	p = @msl( i )
	msl( i ).owner = ship_index
	fromShip->lastfire = TIMER
	msl( i ).dead = 0
	
	'j = fromShip->posfire
	'j = 0
	
	with p->control
		.body = cpBodyNew( environment.missle.mass, cpMomentForCircle(environment.missle.mass, environment.missle.size, 0, cpvzero) )
		.body->v = cpvforangle( fromShip->body.body->a )
		.body->p = cpv( fromShip->body.body->p.x, fromShip->body.body->p.y )
		.body->a = fromShip->body.body->a
		cpSpaceAddBody( gSpace, .body )
		.shape = cpCircleShapeNew( .body, environment.missle.size, cpvzero )
		.shape->e = environment.missle.e: .shape->u = environment.missle.u
		.id = id_Bullet
		.cinfo.obj_id = .id
		.cinfo.player_id = ship_index
		.cinfo.obj_index = i
		.shape->dat = @.cinfo
		cpSpaceAddShape( gSpace, .shape )
	end with
	'fromShip->posfire += 1
	'if fromShip->posfire > 1 then fromShip->posfire = 0
	
	p->init = 1
	
end sub

sub cleanMissle( byval p as missle_type ptr )
	cpSpaceRemoveShape( gSpace, p->control.shape )
	cpSpaceRemoveBody( gSpace, p->control.body )
	p->init = 0
end sub

sub updateMissles ( )
	dim i as integer, x as integer, y as integer
	for i = 0 to msl_largest
		if msl( i ).init = 1 then
			if msl( i ).dead = 1 then
				for x = -1 to 1
					for y = -1 to 1
						addParticle ( msl( i ).control.body->p, cpvmult( cpv( x, y ), 5.0 ), cpv(1.3, 1.3), 1.0, PRT_FIRE, 1 )
				next y, x
				cleanMissle( @msl( i ) )
			else
				msl( i ).control.body->w = 0
				msl( i ).control.body->t = 0
				dim as cpVect v = cpvforangle( msl( i ).control.body->a+PI/2)
				cpBodyApplyImpulse( msl( i ).control.body, cpvmult(v, environment.thrust_force), cpvzero )
				if (frameCounter And 7) = 0 then
					addParticle ( msl( i ).control.body->p, cpvzero, cpv(1.3, 1.3), 1.0, PRT_FIRE, 1 )
				end if
			end if
		end if
	next i
end sub

sub drawMissles ( )
	dim i as integer
	for i = 0 to MAX_MISSLES-1
		if msl( i ).init = 1 then
			if msl( i ).dead = 0 then
				circle ( msl( i ).control.body->p.x, msl( i ).control.body->p.y ), environment.missle.size, rgb( 255, 200, 200 )
			end if
		end if
	next i
end sub

sub addParticle ( byval p as cpVect, byval v as cpVect, byval sz as cpVect, byval life as cpFloat, byval clr as integer, byval passive as integer = 1 )
	
	static as integer skip = 0
	
	dim as cpBody ptr body
	dim as cpShape ptr shape
	
	dim as cpFloat mass = PRT_MASS
	dim as cpFloat size = UNIT_PARTICLE*(rnd*(sz.y-sz.x)+sz.x)
	
	dim as integer i
	
	randomize timer
	
	for i = 0 to MAX_PARTICLES-1
		if prt(i).inuse = 0 then		  
			prt(i).inuse = 1
			prt(i).sz = size/UNIT_PARTICLE
			prt(i).startTime = timer
			prt(i).life = life
			prt(i).passive = passive
			prt(i).last_v = v
			prt(i).id = id_Unknown
			if clr = PRT_FIRE then
				prt(i).clr = rgb( 255, 1 + (rnd * 200), 0 )
			else
				prt(i).clr = clr
			end if

			body = cpBodyNew(mass, cpMomentForCircle(mass, size, 0, cpvzero))
			body->p = p
			body->v = v
			if passive = 0 then cpSpaceAddBody(gSpace, body)
	
			shape = cpCircleShapeNew(body, size, cpvzero)
			shape->e = 0.2
			shape->u = 1.0
			shape->dat = @prt(i).id
		
			if passive = 0 then cpSpaceAddShape(gSpace, shape)
			prt(i).body = body
			prt(i).shape = shape
			exit for
		end if
	next i
end sub
	
sub updateParticles ( )
	
	dim as integer i
	prt_largest = 0
	for i = 0 to MAX_PARTICLES-1
		if prt(i).inuse = 1 then
			if i > prt_largest then prt_largest = i
			prt(i).t = 1.0 - ((timer - prt(i).startTime) / prt(i).life)
			if (prt(i).t < 0) then
				prt(i).inuse = 0
				if prt(i).passive = 0 then
					cpSpaceRemoveBody(gSpace, prt(i).body)
					cpSpaceRemoveShape(gSpace, prt(i).shape)
				end if
				cpShapeFree(prt(i).shape)
				cpBodyFree(prt(i).body)
				continue for
			end if
			prt(i).last_v = prt(i).body->v
			if prt(i).passive = 1 then
				dim as cpFloat dt = 1.0/(FPS*2)/FRAMESTEPS
				dim as integer j
				for j=1 to FRAMESTEPS
					cpBodyUpdateVelocity(prt(i).body, gSpace->gravity, (1.0f) ^ -dt, dt)
					cpBodyUpdatePosition(prt(i).body, dt)
				next j
			end if
		end if
	next i
	
end sub

sub drawParticles ( )
	dim i as integer
	dim drawn as ubyte = 0
	
	for i = 0 to prt_largest
		if prt(i).inuse then
			circle( prt(i).body->p.x, prt(i).body->p.y ), 3 - (((timer - prt(i).startTime) / prt(i).life)*3), prt(i).clr
		end if
	next i
end sub

sub drawLand()
	dim i as integer
	
	pset( surface.land(0).x, surface.land(0).y ), rgb( 255, 255, 255 )
	for i = 1 to 3
		line -( surface.land(i).x, surface.land(i).y ), rgb( 255, 255, 255 )
	next i
	line -( surface.land(0).x, surface.land(0).y ), rgb( 255, 255, 255 )
	
end sub

sub init()
	
	' Environment Data
	with environment
		' Ship Defaults
		.ship.mass = 15.0
		.ship.size = 10.0
		.ship.e = 0.0
		.ship.u = 100.0
		
		' Thruster Defaults
		.thruster.mass = 4.0
		.thruster.size = 5.0
		.thruster.e = 0.0
		.thruster.u = 10.0

		.missle.mass = 4.0
		.missle.size = 2.0
		.missle.e = 2.0
		.missle.u = 10.0
		
		.thrust_force = -20.0
		.fire_rate = 0.4
		
		.gravity = 10.0
	end with
		
	' Setup the physics world
	gSpace = cpSpaceNew()
	gSpace->gravity = cpv(0.0, environment.gravity)
	gSpace->damping = 1
	
	cpSpaceAddCollisionPairFunc( gSpace, 0, 0, @cbCollision, 0 )
	
	cpSpaceResizeStaticHash(gSpace, 50.0, 2000)
	cpSpaceResizeActiveHash(gSpace, 50.0, 100)
	
	dim i as integer
	
	surface.land(0) = cpv( 10.0, 550.0 )
	surface.land(1) = cpv( 790.0, 550.0 )
	surface.land(2) = cpv( 790.0, 10.0 )
	surface.land(3) = cpv( 10.0, 10.0 )
	
	surface.staticBody = cpBodyNew(1e31, 1e31 )
	for i = 0 to 3
		dim as cpShape ptr pShape = cpSegmentShapeNew( surface.staticBody, surface.land(i), surface.land((i+1) and 3), 1 )
		pShape->e = 0.25: pShape->u = 500.0
		surface.id = id_Surface
		surface.cinfo.obj_id = surface.id
		surface.cinfo.player_id = -1
		surface.cinfo.obj_index = -1
		pShape->dat = @surface.cinfo
		cpSpaceAddStaticShape( gSpace, pShape )
	next i
	
	randomize timer
	
end sub

sub deinit()
	
	dim i as integer
	/'for i = 0 to 3
		cpSpaceRemoveStaticShape( gSpace, surface.land( i ) )
		cpShapeFree( surface.land( i ) )
	next i'/
	cpSpaceRemoveBody( gSpace, surface.staticBody )
	cpBodyFree( surface.staticBody )
	
	cpSpaceFree( gSpace )
	
end sub

function cbCollision cdecl ( byval a as cpShape ptr, byval b as cpShape ptr, byval contacts as cpContact ptr, byval numContants as integer, byval normal_coef as cpFloat, byval dat as any ptr ) as integer
	dim as collision_info ptr ida = cptr( collision_info ptr, a->dat ), idb = cptr( collision_info ptr, b->dat )
	
	' Collision objects have a NULL pointer for data -> assume no collision
	if ( ida = 0 ) or ( idb = 0 ) then return 0
	
	' If they are both bullets, bullets cannot collide with each other
	'if ( ida->obj_id = id_Bullet ) and ( idb->obj_id = id_Bullet ) then return 0
	
	' Player objects cannot collide with each other
	'if ( ida->player_id = idb->player_id ) then return 0
	'dim iCons as integer = freefile
	'open cons for output as #iCons
	if ida->obj_id = id_Bullet then
		'print #iCons, "This is a bullet"
		if ida->player_id = idb->player_id then
			'print #iCons, "and it doesn't count (player hit his/her own bullet)"
			return 0
		end if
		if ( idb->obj_id = id_Ship ) or ( idb->obj_id = id_Thruster ) then
			'print #iCons, "and it hurt (" & ida->player_id, idb->player_id & ")"
			player( idb->player_id ).dead = 1
		end if
		msl( ida->obj_index ).dead = 1
		return 1
	end if
	if idb->obj_id = id_Bullet then
		'print #iCons, "This is a bullet"
		if ida->player_id = idb->player_id then
			'print #iCons, "and it doesn't count (player hit his/her own bullet)"
			return 0
		end if
		if ( ida->obj_id = id_Ship ) or ( ida->obj_id = id_Thruster ) then
			'print #iCons, "and it hurt (" & idb->player_id, ida->player_id & ")"
			player( ida->player_id ).dead = 1
		end if
		msl( idb->obj_index ).dead = 1
		return 1
	end if
	'close #iCons
	
	return 1
	
end function

sub rotozoom( byref dst as FB.IMAGE ptr = 0, byref src as const FB.IMAGE ptr, byval positx as integer, byval posity as integer, byref angle as integer, byref zoomx as single, byref zoomy as single, byval transcol as uinteger  = &hffff00ff)
	
	'Rotozoom for 32-bit FB.Image by Dr_D(Dave Stanley) and yetifoot(Simon Nash)
	'No warranty implied... use at your own risk ;) 
	
	static as integer mx, my, col, nx, ny
	static as single nxtc, nxts, nytc, nyts
	static as single tcdzx, tcdzy, tsdzx, tsdzy
	static as integer sw2, sh2, dw, dh
	static as single tc, ts, _mx, _my
	static as uinteger ptr dstptr, srcptr, odstptr
	static as integer xput, yput, startx, endx, starty, endy
	static as integer x(3), y(3), xa, xb, ya, yb, lx, ly
	static as ubyte ptr srcbyteptr, dstbyteptr
	static as integer dstpitch, srcpitch, srcbpp, dstbpp, srcwidth, srcheight
	
	if zoomx <= 0 or zoomy <= 0 then exit sub
	
	if dst = 0 then
		dstptr = screenptr
		odstptr = dstptr
		screeninfo dw,dh,,,dstpitch
	else
		dstptr = cast( uinteger ptr, dst + 1 )
		odstptr = cast( uinteger ptr, dst + 1 )
		dw = dst->width
		dh = dst->height
		dstbpp = dst->bpp
		dstpitch = dst->pitch
	end if
	
	srcptr = cast( uinteger ptr, src + 1 )
	srcbyteptr = cast( ubyte ptr, srcptr )
	dstbyteptr = cast( ubyte ptr, dstptr )
	
	sw2 = src->width\2
	sh2 = src->height\2
	srcbpp = src->bpp
	srcpitch = src->pitch
	srcwidth = src->width
	srcheight = src->height
	
	tc = cos( angle * pi_180 )
	ts = sin( angle * pi_180 )
	tcdzx = tc/zoomx
	tcdzy = tc/zoomy
	tsdzx = ts/zoomx
	tsdzy = ts/zoomy
	
	xa = sw2 * tc * zoomx + sh2  * ts * zoomx
	ya = sh2 * tc * zoomy - sw2  * ts * zoomy
	
	xb = sh2 * ts * zoomx - sw2  * tc * zoomx
	yb = sw2 * ts * zoomy + sh2  * tc * zoomy
	
	x(0) = sw2-xa
	x(1) = sw2+xa
	x(2) = sw2-xb
	x(3) = sw2+xb
	y(0) = sh2-ya
	y(1) = sh2+ya
	y(2) = sh2-yb
	y(3) = sh2+yb
	
	for i as integer = 0 to 3
		for j as integer = i to 3
			if x(i)>=x(j) then
				swap x(i), x(j)
			end if
		next
	next
	startx = x(0)
	endx = x(3)
	
	for i as integer = 0 to 3
		for j as integer = i to 3
			if y(i)>=y(j) then
				swap y(i), y(j)
			end if
		next
	next
	starty = y(0)
	endy = y(3)
	
	positx-=sw2
	posity-=sh2
	if posity+starty<0 then starty = -posity
	if positx+startx<0 then startx = -positx
	if posity+endy<0 then endy = -posity
	if positx+endx<0 then endx = -positx
	
	if positx+startx>(dw-1) then startx = (dw-1)-positx
	if posity+starty>(dh-1) then starty = (dh-1)-posity
	if positx+endx>(dw-1) then endx = (dw-1)-positx
	if posity+endy>(dh-1) then endy = (dh-1)-posity
	if startx = endx or starty = endy then exit sub
	
	
	xput = (startx + positx) * 4
	yput = starty + posity
	ny = starty - sh2
	nx = startx - sw2
	nxtc = (nx * tcdzx)
	nxts = (nx * tsdzx)
	nytc = (ny * tcdzy)
	nyts = (ny * tsdzy)
	dstptr += dstpitch * yput \ 4
	
	dim as integer y_draw_len = (endy - starty) + 1
	dim as integer x_draw_len = (endx - startx) + 1
	
	
	'and we're off!
	asm
		mov edx, dword ptr [y_draw_len]
		
		test edx, edx ' 0?
		jz y_end	  ' nothing to do here
		
		fld dword ptr[tcdzy]
		fld dword ptr[tsdzy]
		fld dword ptr [tcdzx]
		fld dword ptr [tsdzx]
		
		y_inner:
		
		fld dword ptr[nxtc]	 'st(0) = nxtc, st(1) = tsdzx, st(2) = tcdzx, st(3) = tsdzy, st(4) = tcdzy
		fsub dword ptr[nyts]	'nxtc-nyts
		fiadd dword ptr[sw2]	'nxtc-nyts+sw2
		
		fld dword ptr[nxts]	 'st(0) = nxts, st(1) = tsdzx, st(2) = tcdzx, st(3) = tsdzy, st(4) = tcdzy
		fadd dword ptr[nytc]	'nytc+nxts
		fiadd dword ptr[sh2]	'nxts+nytc+sh2
		'fpu stack returns to: st(0) = tsdzx, st(1) = tcdzx, st(2) = tsdzy, st(3) = tcdzy 
		
		mov ebx, [xput]
		add ebx, [dstptr]
		
		mov ecx, dword ptr [x_draw_len]
		
		test ecx, ecx ' 0?
		jz x_end	  ' nothing to do here
		
		x_inner:
		
		fist dword ptr [my] ' my = _my
		
		fld st(1)		   ' mx = _mx
		fistp dword ptr [mx]
		
		mov esi, dword ptr [mx]		 ' esi = mx
		mov edi, dword ptr [my]		 ' edi = my
		
		' bounds checking
		test esi, esi	   'mx<0?
		js no_draw		  
		'mov esi, 0
		
		test edi, edi
		'mov edi, 0
		js no_draw		  'my<0?

		cmp esi, dword ptr [srcwidth]   ' mx >= width?
		jge no_draw
		cmp edi, dword ptr [srcheight]  ' my >= height?
		jge no_draw
		
		' calculate position in src buffer
		mov eax, dword ptr [srcbyteptr] ' eax = srcbyteptr
		imul edi, dword ptr [srcpitch]  ' edi = my * srcpitch
		add eax, edi
		shl esi, 2
		' eax becomes src pixel color
		mov eax, dword ptr [eax+esi]
		cmp eax, [transcol]
		je no_draw
		
		' draw pixel
		mov dword ptr [ebx], eax
		no_draw:
		
		fld st(3)
		faddp st(2), st(0) ' _mx += tcdzx
		fadd st(0), st(2) ' _my += tsdzx
		
		' increment the output pointer
		add ebx, 4
		
		' increment the x loop
		dec ecx
		jnz x_inner
		
		x_end:
		
		fstp dword ptr [_my]
		fstp dword ptr [_mx]
		
		'st(0) = tsdzx, st(1) = tcdzx, st(2) = tsdzy, st(3) = tcdzy
		'nytc += tcdzy
		fld dword ptr[nytc]
		fadd st(0), st(4)
		fstp dword ptr[nytc]
		
		'st(0) = tsdzx, st(1) = tcdzx, st(2) = tsdzy, st(3) = tcdzy
		'nyts+=tsdzy
		fld dword ptr[nyts]
		fadd st(0), st(3) 
		fstp dword ptr[nyts]
		
		'dstptr += dst->pitch
		mov eax, dword ptr [dstpitch]
		add dword ptr [dstptr], eax
		
		dec edx
		jnz y_inner
		
		y_end:
		
		finit
	end asm
	
end sub

sub frameLock ( byval reinit as integer )
	static lastFrame as double
	static initFlag as integer = 0
	
	if reinit then initFlag = 0
	
	if initFlag = 0 then
		lastFrame = timer
		initFlag = 1
	else
		while ((timer - lastFrame) <= (1.0/FPS)): wend
		lastFrame = timer
	end if
end sub
