	include  "exec/types.i"
	include  "exec/libraries.i"

	section code

	xref	_joyportBase
	xref	_LVOgetjoyport
	xdef	_getjoyport

_getjoyport:
	move.l		a6,-(sp)		; save register a6
	move.l		8(sp),d0		; copy param to register
	move.l		_joyportBase,a6		; library base to a6
	jsr		_LVOgetjoyport(a6)	; go to joyport routine
	move.l		(sp)+,a6		; restore register a6
	rts

	end
