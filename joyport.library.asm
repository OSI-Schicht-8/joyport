_custom				=		$dff000

CIAA_PRA			=		$bfe001
CIAA_DDRA			=		$200
JOY0DAT				=		$0a
JOY1DAT				=		$0c

POTINP				=		$16
POTGO				=		$34

LIBB_DELEXP			=		3

LIB_VERSION			=		20		
LIB_REVISION		=		22
LIB_IDSTRING		=		24
LIB_NEGSIZE			=		16
LIB_POSSIZE			=		18
LIB_FLAGS			=		14
LIB_OPENCNT			=		32
LIB_SIZE			=		34
RTF_AUTOINIT		=		$80
LN_TYPE				=		8
LN_NAME				=		10
NT_LIBRARY			=		9

joy_port0			=		42
joy_port1			=		46

start			moveq		#-1,d0
				rts

reserved		moveq		#0,d0
				rts

romtag			dc.w		$4afc						; RT_MATCHWORD ($4afc)
				dc.l		romtag						; RT_MATCHTAG
				dc.l		endskip						; RT_ENDSKIP
				dc.b		RTF_AUTOINIT				; RT_FLAGS
				dc.b		1							; RT_VERSION
				dc.b		NT_LIBRARY					; RT_TYPE
				dc.b		0							; RT_PRI
				dc.l		joyportlibname				; RT_NAME
				dc.l		idstring					; RT_IDSTRING
				dc.l		init						; RT_INIT

init			dc.l		LIB_SIZE+16					; LIB_SIZE + private
				dc.l		functable
				dc.l		datatable
				dc.l		initfunction

functable		dc.w		-1
				dc.w		open-functable
				dc.w		close-functable
				dc.w		expunge-functable
				dc.w		reserved-functable
				dc.w		getjoyport-functable
				dc.w		-1

datatable		dc.b		$a0
				dc.b		LN_TYPE
				dc.b		NT_LIBRARY,0

				dc.b		$80
				dc.b		LN_NAME
				dc.l		joyportlibname

				dc.b		$90
				dc.b		LIB_VERSION
				dc.w		1
				
				dc.b		$90
				dc.b		LIB_REVISION
				dc.w		0
				
				dc.b		$80
				dc.b		LIB_IDSTRING
				dc.l		idstring
				
				dc.l 		0

joyportlibname	dc.b		"joyport.library",0
idstring		dc.b		"joyport 1.0 (6.1.2021)",$0d,$0a,0
				cnop		0,4

initfunction	move.l		a1,-(sp)
				movea.l		d0,a1
				movem.l		a0/a6,LIB_SIZE(a1)
				move.l		a1,d0
				move.l		(sp)+,a1
				rts

open			addq.w		#1,LIB_OPENCNT(a6)
				bclr		#LIBB_DELEXP,LIB_FLAGS(a6)
				move.l		a6,d0
				rts

close			subq.w		#1,LIB_OPENCNT(a6)
                bne			reserved
                btst.b		#LIBB_DELEXP,LIB_FLAGS(a6)
                beq			reserved
				
expunge			tst.w		LIB_OPENCNT(a6)
				beq.s		kick
				bset		#LIBB_DELEXP,LIB_FLAGS(a6)
				moveq		#0,d0
				rts

kick			movem.l		a5-a6,-(sp)
				movea.l		a6,a5
				movea.l		(a6)+,a0
				movea.l		(a6),a6
				move.l		a0,(a6)
				move.l		a6,(a0)
				movea.l		a5,a1
				moveq		#0,d0
				move.w		LIB_NEGSIZE(a5),d0
				suba.w		d0,a1
				add.w		LIB_POSSIZE(a5),d0
				movem.l		LIB_SIZE(a5),a5-a6
				jsr			-210(a6)
				move.l		a5,d0
				movem.l		(sp)+,a5-a6
				rts

; ------ getjoyport ------

getjoyport		cmp.w		#1,d0				; port number (0/1)
				bhi			wrongport
				jsr			readjoy
				rts
				
wrongport		moveq		#0,d0
				rts

readjoy			movem.l		d1-d6/a0-a2,-(a7)
				lea			_custom,a0
				lea			CIAA_PRA,a1
				tst.l		d0					; check port number
				
				beq.s		port0
				subq.l		#1,d0
				beq.s		port1
				moveq		#0,d0
				bra.w		readjoyend

port0			moveq		#6,d3				; button1 port 0 (bit 6 at CIAA_PRA)
				moveq		#10,d4				; button2 port 0 (bit 10 at POTGOR)
				move.w		#$f600,d5
				move.w		JOY0DAT(a0),d6
				moveq		#8,d1				; button3 port 0 (bit 8 at PORGOR)
				bra.s		chkButton1

port1			moveq		#7,d3				; button1 port 1 (bit 7 at CIAA_PRA)
				moveq		#14,d4				; button2 port 1 (bit 14 at POTGOR)
				move.w		#$6f00,d5
				move.w		JOY1DAT(a0),d6
				moveq		#12,d1				; button3 port 1 (bit 12 at POTGOR)

chkButton1		moveq		#0,d2				; clear port status
				btst		d3,(a1)				; button1 down?
				bne.s		chkButton2
				bset		#22,d2				; set bit 22 (blue button / button 1)

chkButton2		move.w		#$ff00,POTGO(a0)	; set pins 5 and 9 high
				move.w		POTINP(a0),d0
				btst		d4,d0				; button2 down?
				bne.s		chkButton3
				bset		#23,d2				; set bit 23 (red button / button 2)

chkButton3		btst		d1,d0				; button3 down?
				bne.s		chkDirection
				bset		#17,d2				; set bit 17 (play button / button 3)

chkDirection	move.w		d6,d0				; JOYxDAT
				bsr.w		chkUDLR				; check direction buttons
				beq.s		nomouse				; possibly no mouse

				bset		#29,d2				; set mouse in port status
				move.w		d0,d2				; include direction buttons to port status
				
				move.l		d3,d0
				subq		#6,d0
				lsl.l		#2,d0
				move.l		#$0a000000,joy_port0(a6,d0)	; set joystick check counter to 10
				bra.s		chkPadBtns

nomouse			move.w		d0,d2				; include direction buttons to port status
				move.l		d3,d0
				subq		#6,d0
				lsl.l		#2,d0
				move.l		joy_port0(a6,d0),d0 ; get previous port status
				btst.l		#28,d0				; was port status joystick or pad last time?
				bne.s		chkPadBtns
				btst.l		#29,d0
				bne.s		wasmouse
				bset		#30,d2				; set no or unknown device in port status
				bra.s		chkPadBtns
wasmouse		move.l		d3,d0
				subq		#6,d0
				lsl.l		#2,d0
				sub.b		#1,joy_port0(a6,d0)	; decrement joystick check counter
				move.b		joy_port0(a6,d0),d0
				and.b		#$0f,d0
				bne.s		stillmouse
				bra.s		chkPadBtns			; was not mouse the lase 10 times, maybe joystick/pad
				
stillmouse		bset		#29,d2				; set mouse in port status

chkPadBtns		moveq		#0,d0				; clear for gamepad button status
				bset		d3,CIAA_DDRA(a1)	; configure FIR0/FIR1 as output
				bclr		d3,(a1)				; clear bit 6/7 (pin 6 = CLK)
				move.w		d5,POTGO(a0)		; configure pin 9 as in, pin 5 as out / pin 5 = low
				moveq		#8,d1				; loop counter
				bra.s		chkPad2

chkPad1			tst.b		(a1)
				tst.b		(a1)
chkPad2			tst.b		(a1)
				tst.b		(a1)
				tst.b		(a1)
				tst.b		(a1)
				tst.b		(a1)
				tst.b		(a1)
				move.w		POTINP(a0),d5		; get data
				bset		d3,(a1)				; trigger CLK (pin 6 = 1)
				bclr		d3,(a1)				; (pin 6 = 0)
				btst		d4,d5				; check pin 9 for Bl->Re->Ye->Gr->FFW->RWD->PLAY
				bne.s		chkloop
				bset		d1,d0				; set related bit in d0

chkloop			dbf			d1,chkPad1			; loop through gamepad shift register

				bclr		d3,CIAA_DDRA(a1)	; reset direction to input
				move.w		#$ff00,POTGO(a0)	; reset port

				lsr.w		#1,d0
				bcc.s		nogamepad
				
				cmp.b		#$ff,d0
				beq.s		nogamepad
				
isgamepad		ori.w		#$1000,d0			; set gampad in port status
				swap		d0
				bclr		#30,d2				; clear no device bit
				or.l		d2,d0
				bra			readjoyend

nogamepad		btst		#29,d2				; already set as mouse?
				bne.s		setportstatus
				cmp.l		#$40000000,d2		; no or unknown device?
				beq.s		setportstatus
				bclr		#30,d2
				ori.l		#$30000000,d2		; set as joystick
setportstatus	move.l		d2,d0
				bra			readjoyend

chkUDLR			move.w		d0,d1					; d1 = ******l? ******r?
				lsr.w		#1,d0					; d0 = *******l b******r
				eor.w		d0,d1					; xor for u/d buttons
				andi.w		#$0101,d0				; d0 = 0000000l 0000000r
				andi.w		#$0101,d1				; d1 = 0000000u 0000000d
				ror.b		#1,d0					; d0 = 0000000l r0000000
				ror.b		#1,d1					; d1 = 0000000u d0000000
				lsr.w		#7,d0					; d0 = 00000000 000000lr
				lsr.w		#5,d1					; d1 = 00000000 0000ud00
				or.w		d1,d0					; d0 = 00000000 0000udlr (final status)
chkmouse		move.w		#%1111111111111011,d1
				and.b		d0,d1					; d1 = 11111111 0000u0lr
				lsr.b		#1,d1					; d1 = 11111111 00000u0l
				and.b		d0,d1					; d1 = 11111111 00000g0h (for mouse checking)
				rts

readjoyend		move.l		d0,d2

				subq		#6,d3
				lsl.l		#2,d3
				moveq		#0,d1
				btst.l		#28,d0
				bne.s		nocounter
				move.l		joy_port0(a6,d3),d1
				and.l		#$0f000000,d1
				or.l		d1,d0					; include counter to port status
				
nocounter		move.l		d0,joy_port0(a6,d3)
				move.l		d2,d0					; return value: port status
				movem.l		(a7)+,d1-d6/a0-a2
				rts
				
endskip			end
