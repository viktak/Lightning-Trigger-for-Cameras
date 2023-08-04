
	LIST	p=16F648a
	include "P16F648a.inc"
	ERRORLEVEL	0,	-302
	__config 0x3F18


		cblock	0x20		;start of general purpose registers
			hold			;Comparator pervious state
  		    count			;used in looping routines
			count1			;used in delay routine
			counta			;used in delay routine
			countb			;used in delay routine
		endc



C1OUTMASK   Equ b'01000000'		;Comparator1 output bit
C2OUTMASK	Equ b'10000000'		;Comparator2 output bit

SW1			Equ 4				;Mode button 
TRIGGER     Equ 3				;Trigger LED
METERING    Equ 2				;Metering LED
LED_CAL		Equ 1				;Calibration LED
LED_MODE	Equ 0				;Mode LED

			org	0x0000

;Init

	      		clrf PORTA
	      		clrf PORTB

				movlw 0x32       	;Internal voltage reference mode CM<2:0>=010
		 		movwf	CMCON

SetPorts
	        	bsf 	STATUS,	RP0		;select bank 1
				movlw	b'000010000'	;select inputs/outputs
				movwf	PORTB
				movlw   0x07
	        	movwf   TRISA			; RA<2:0> Input RS<4:3> output

				bcf 	STATUS,	RP0	;select bank 0


calibrate
				call vrset1041V
				bcf  PORTB, LED_MODE		;Mode led 0


comploop0
				bcf   PORTB, LED_CAL
				bsf   PORTB, LED_MODE
comploop1
				btfss PORTB, SW1
				goto mode_select_switch

				movf CMCON,w
				andlw C2OUTMASK
				btfsc STATUS,Z
		        goto comploop0

				bsf PORTB,LED_CAL
                bcf PORTB,LED_MODE
				goto comploop1


mode_select_switch
				Call Delay250ms

				Call vrset0625V

				bsf PORTB, LED_MODE		;mode led on
				bcf PORTB, LED_CAL		;calibrate led off
				Call Delay250ms
				bcf PORTB, LED_MODE		;mode led off
				bcf PORTB, LED_CAL		;calibrate led off
				bcf PORTB, TRIGGER
				bsf PORTB, METERING



Triggerloop 	btfss PORTB, SW1
				goto exit_trigger_mode

				movf CMCON,w
				andlw C1OUTMASK
				btfsc STATUS,Z
		        goto Triggerloop

       ;Trigger !!

				bsf PORTB, TRIGGER
				call Delay250ms
				call Delay250ms
				bcf  PORTB, TRIGGER
				call Delay50ms
				bcf  PORTB, METERING

				bsf  PORTB, LED_MODE
               	bcf  PORTB, LED_CAL
				call Delay250ms
				bcf  PORTB, LED_MODE
				bsf  PORTB, LED_CAL
				call Delay250ms
				bsf  PORTB, LED_MODE
				bcf  PORTB, LED_CAL
				call Delay250ms
				bcf  PORTB, LED_MODE
				bsf  PORTB, LED_CAL
				call Delay250ms
				bsf  PORTB, LED_MODE
		        bcf  PORTB, LED_CAL
				call Delay250ms
				bcf  PORTB, LED_MODE
				bsf  PORTB, LED_CAL
				call Delay250ms
				bsf  PORTB, LED_MODE
               	bcf  PORTB, LED_CAL
				call Delay250ms
				bcf  PORTB, LED_MODE
				bsf  PORTB, LED_CAL
				call Delay250ms
				bsf  PORTB, LED_MODE
                bcf  PORTB, LED_CAL
				call Delay250ms
				bcf  PORTB, LED_MODE
				bsf  PORTB, LED_CAL
				call Delay250ms
				bsf  PORTB, LED_MODE
                bcf  PORTB, LED_CAL
				call Delay250ms
				bcf  PORTB, LED_MODE
				bsf  PORTB, LED_CAL
				call Delay250ms
				bsf  PORTB, LED_MODE
                bcf  PORTB, LED_CAL
				call Delay250ms
				bcf  PORTB, LED_MODE
				bsf  PORTB, LED_CAL
				call Delay250ms
                bcf  PORTB, LED_CAL
				bsf  PORTB, METERING

		        goto Triggerloop

exit_trigger_mode

				Call Delay250ms
				bcf PORTB,LED_MODE
				bcf PORTB,METERING
				goto calibrate



;Set VREF to 1.041V
vrset1041V
				bsf 	STATUS, RP0			;select bank1
				movlw	0xE5				;1.041V (for check gain)
				movwf	VRCON
				bcf		STATUS,	RP0
				call	Delay250ms			;Time to settle down VREF
				return

;Set VREF to 0.625V
vrset0625V
				bsf 	STATUS, RP0			;select bank1
				movlw	0xE3				;0.625V (for check gain)
				movwf	VRCON
				bcf		STATUS,	RP0
		        call	Delay250ms			;Time to settle down VREF
				return









Delay250ms
				movlw	d'250'			;delay 250 ms (4 MHz clock)
				movwf	count1
d1A				movlw	0xC7
				movwf	counta
				movlw	0x01
				movwf	countb
Delay_0A
				decfsz	counta, f
				goto	$+2
				decfsz	countb, f
				goto	Delay_0A

				decfsz	count1	,f
				goto	d1A
				retlw	0x00


Delay50ms		movlw	d'100'			;delay 50 ms (4 MHz clock)
				movwf	count1
d1B				movlw	0xC7
				movwf	counta
				movlw	0x01
				movwf	countb
Delay_0B
				decfsz	counta, f
				goto	$+2
				decfsz	countb, f
				goto	Delay_0B

				decfsz	count1	,f
				goto	d1B
				retlw	0x00




		end

