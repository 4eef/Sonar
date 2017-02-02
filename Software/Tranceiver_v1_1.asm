;���������� �� ATtiny44A V1.1

.INCLUDE "tn44Adef.inc"

;����������
.equ	GAINCT	= RAMEND-223
.equ	GAIN1	= RAMEND-222
.equ	GAIN2	= RAMEND-221
.equ	GAIN3	= RAMEND-220
.equ	GAIN4	= RAMEND-219
.equ	DAMPCT	= RAMEND-218
.equ	T0TOP	= 100-1
.equ	inum	= 40
.equ	phase45 = 25
.equ	phase90 = 48

	rjmp	RESET
	reti	;rjmp	EINT0
	reti	;rjmp	PCI0
	reti	;rjmp	PCI1
	reti	;rjmp	WDT
	reti	;rjmp	T1CAPT
	out	TCNT0,	r0			;T1CA
	reti	;rjmp	T1CB
	reti	;rjmp	T1OVF
	reti	;rjmp	T0CA
	reti	;rjmp	T0CB
	reti	;rjmp	T0OVF
	reti	;rjmp	ANA_COMP
	reti	;rjmp	ADC
	reti	;rjmp	EE_RDY
	reti	;rjmp	USI_STR
	reti	;rjmp	USI_OVF
	
RESET:	ldi	r16,	low(RAMEND-224)		;������������� �����
	out	SPL,	r16
	ldi	r16,	high(RAMEND-224)
	out	SPH,	r16

	ldi	r16,	0b10011111		;0 - #CS, 1 - #PR, 2 - #SHDN, 3 - SDI, 4 - CLK, 5 - SDO, 6 - Start, 7 - BSS138
	out	DDRA,	r16
	ldi	r16,	0b01000111
	out	PORTA,	r16

	ldi	r16,	0b00000100		;0 - Reserved, 1 - Reserved, 2 - FTZ851, 3 - RESET
	out	DDRB,	r16
	ldi	r16,	0b00001000
	out	PORTB,	r16

	clr	r0

	ldi	r16,	0b00100000		;Sleep enable
	out	MCUCR,	r16

	;����������� ��������
	ldi	r16,	21			;�������� �� ������� ������� ������������ - 2 �
	sts	GAINCT,	r16
	sts	GAIN1,	r16
	sts	GAIN2,	r16
	sts	GAIN3,	r16
	sts	GAIN4,	r16
	rcall	rdactx

	;��������� ����������� ���������� �� ������
;	ldi	r16,	0b01000100		;WDIE,	0,25 �
;	out	WDTCSR,	r16
	
	;�������
	ldi	r16,	0b10000001		;Sync mode, stop clocks
	out	GTCCR,	r16
	out	TCCR1A,	r0
	out	TCCR1C,	r0
	ldi	r16,	0b00000010
	out	TIMSK1,	r16			;OCIE1A
	ldi	r16,	T0TOP			;������� �������� �����
	out	OCR1AH,	r0
	out	OCR1AL,	r16
	ldi	r16,	0b00000010
	out	TIFR1,	r16			;���������� �� OC1A
	out	TIMSK1,	r16
	out	TCNT1H,	r0
	out	TCNT1L,	r0
	ldi	r16,	0b00001001		;CTC, fcnt=fclk
	out	TCCR1B,	r16
	;��������� ��������� � �������� �����������
	out	TCNT0,	r0
	ldi	r16,	0b00000001		;��������� ������
	out	TCCR0B,	r16	
	;������������� � ������ ��������
	out	GTCCR,	r0			;��������� ������
	sei

;����
main:	clr	r0

	;��������� �������� ����� ����� ���������
	ldi	r17,	42			;���������
	ldi	r16,	240			;3 ��
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	dec	r17
	breq	PC+2
	rjmp	PC-7

	;��������� ��� ����������
	ldi	r16,	T0TOP/2
	out	OCR0A,	r16			;�������� ���������
	ldi	r16,	T0TOP/2
	out	OCR0B,	r16			;������� ���������
	out	TCCR0A,	r0			;���� �������������
	cbi	PORTA,	7
	cbi	PORTB,	2
	ldi	r16,	0b01010000
	out	TCCR0A,	r16
	;11-������ ������������������ ������� |+1|+1|+1|-1|-1|-1|+1|-1|-1|+1|-1|
	;1 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;2 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;3 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	ldi	r17,	phase90			;�������� ���� �� +90 ����
	add	r16,	r17
	out	OCR0A,	r16
	;4 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;5 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;6 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	subi	r16,	phase90			;�������� ���� �� -90 ����
	out	OCR0A,	r16
	;7 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	ldi	r17,	phase90			;�������� ���� �� +90 ����
	add	r16,	r17
	out	OCR0A,	r16
	;8 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;9 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	subi	r16,	phase90			;�������� ���� �� -90 ����
	out	OCR0A,	r16
	;10 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	ldi	r17,	phase90			;�������� ���� �� +90 ����
	add	r16,	r17
	out	OCR0A,	r16
	;11 ���
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	subi	r16,	phase90			;�������� ���� �� -90 ����
	out	OCR0A,	r16

	;������ �������� ���������
	ldi	r16,	0b00010000
	out	TCCR0A,	r16
	rjmp	main
	
rdactx:	ldi	zl,	low(RAMEND-223)		;������������� ���������
	ldi	zh,	high(RAMEND-223)
	ld	r16,	z			;���������������� �������
	inc	r16
	st	z+,	r16
	clr	r14				;�����
addr:	cbi	PORTA,	0			;CSN � "0"
	mov	r16,	r14
	rol	r16				;��������� ������ � ������� MSB
	rol	r16
	rol	r16
	rol	r16
	rol	r16
	ldi	r17,	3			;���������� ��� (��� �����)
abit:	cbi	PORTA,	3			;MOSI
	sbrc	r16,	7
	sbi	PORTA,	3
	sbi	PORTA,	4			;���������� SCK
	clc
	cbi	PORTA,	4			;�������� SCK
	sbic	PINA,	5			;MISO
	sec
	rol	r16
	dec	r17
	brne	abit
	ld	r16,	z
	ldi	r17,	8			;���������� ��� (��� �����)
bit:	cbi	PORTA,	3			;MOSI
	sbrc	r16,	7
	sbi	PORTA,	3
	sbi	PORTA,	4			;���������� SCK
	clc
	cbi	PORTA,	4			;�������� SCK
	sbic	PINA,	5			;MISO
	sec
	rol	r16
	dec	r17
	brne	bit
	sbi	PORTA,	0			;CSN � "1"
	ld	r16,	z			;���������������� ������� �������� RDAC
	inc	r16
	st	z+,	r16
	inc	r14
	ldi	r16,	4			;���� ��������� ��� ��������� - ������������
	cp	r16,	r14
	brne	addr
	ret
