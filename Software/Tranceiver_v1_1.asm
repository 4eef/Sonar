;Эхолокатор на ATtiny44A V1.1

.INCLUDE "tn44Adef.inc"

;Переменные
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
	
RESET:	ldi	r16,	low(RAMEND-224)		;Инициализация стека
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

	;Коэффициент усиления
	ldi	r16,	21			;Поправка на ближнюю границу сканированиЯ - 2 м
	sts	GAINCT,	r16
	sts	GAIN1,	r16
	sts	GAIN2,	r16
	sts	GAIN3,	r16
	sts	GAIN4,	r16
	rcall	rdactx

	;Запустить циклические прерывания от собаки
;	ldi	r16,	0b01000100		;WDIE,	0,25 с
;	out	WDTCSR,	r16
	
	;Таймеры
	ldi	r16,	0b10000001		;Sync mode, stop clocks
	out	GTCCR,	r16
	out	TCCR1A,	r0
	out	TCCR1C,	r0
	ldi	r16,	0b00000010
	out	TIMSK1,	r16			;OCIE1A
	ldi	r16,	T0TOP			;Верхнее значение счета
	out	OCR1AH,	r0
	out	OCR1AL,	r16
	ldi	r16,	0b00000010
	out	TIFR1,	r16			;Прерывания от OC1A
	out	TIMSK1,	r16
	out	TCNT1H,	r0
	out	TCNT1L,	r0
	ldi	r16,	0b00001001		;CTC, fcnt=fclk
	out	TCCR1B,	r16
	;Настройка выходного и опорного генераторов
	out	TCNT0,	r0
	ldi	r16,	0b00000001		;Запустить таймер
	out	TCCR0B,	r16	
	;Синхронизация и запуск таймеров
	out	GTCCR,	r0			;Запустить таймер
	sei

;Цикл
main:	clr	r0

	;Временная задержка перед новой передачей
	ldi	r17,	42			;Множитель
	ldi	r16,	240			;3 мс
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	dec	r17
	breq	PC+2
	rjmp	PC-7

	;Запустить оба генератора
	ldi	r16,	T0TOP/2
	out	OCR0A,	r16			;Выходной генератор
	ldi	r16,	T0TOP/2
	out	OCR0B,	r16			;Опорный генератор
	out	TCCR0A,	r0			;Типа синхронизация
	cbi	PORTA,	7
	cbi	PORTB,	2
	ldi	r16,	0b01010000
	out	TCCR0A,	r16
	;11-битная последовательность Баркера |+1|+1|+1|-1|-1|-1|+1|-1|-1|+1|-1|
	;1 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;2 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;3 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	ldi	r17,	phase90			;Сдвинуть фазу на +90 град
	add	r16,	r17
	out	OCR0A,	r16
	;4 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;5 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;6 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	subi	r16,	phase90			;Сдвинуть фазу на -90 град
	out	OCR0A,	r16
	;7 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	ldi	r17,	phase90			;Сдвинуть фазу на +90 град
	add	r16,	r17
	out	OCR0A,	r16
	;8 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	;9 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	subi	r16,	phase90			;Сдвинуть фазу на -90 град
	out	OCR0A,	r16
	;10 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	ldi	r17,	phase90			;Сдвинуть фазу на +90 град
	add	r16,	r17
	out	OCR0A,	r16
	;11 бит
	ldi	r16,	inum
	sleep
	dec	r16
	breq	PC+2
	rjmp	PC-3
	in	r16,	OCR0A
	subi	r16,	phase90			;Сдвинуть фазу на -90 град
	out	OCR0A,	r16

	;Убрать выходной генератор
	ldi	r16,	0b00010000
	out	TCCR0A,	r16
	rjmp	main
	
rdactx:	ldi	zl,	low(RAMEND-223)		;Инициализация указателя
	ldi	zh,	high(RAMEND-223)
	ld	r16,	z			;Инкрементировать счетчик
	inc	r16
	st	z+,	r16
	clr	r14				;Адрес
addr:	cbi	PORTA,	0			;CSN в "0"
	mov	r16,	r14
	rol	r16				;Выделение адреса в область MSB
	rol	r16
	rol	r16
	rol	r16
	rol	r16
	ldi	r17,	3			;Количество бит (для цикла)
abit:	cbi	PORTA,	3			;MOSI
	sbrc	r16,	7
	sbi	PORTA,	3
	sbi	PORTA,	4			;Установить SCK
	clc
	cbi	PORTA,	4			;Сбросить SCK
	sbic	PINA,	5			;MISO
	sec
	rol	r16
	dec	r17
	brne	abit
	ld	r16,	z
	ldi	r17,	8			;Количество бит (для цикла)
bit:	cbi	PORTA,	3			;MOSI
	sbrc	r16,	7
	sbi	PORTA,	3
	sbi	PORTA,	4			;Установить SCK
	clc
	cbi	PORTA,	4			;Сбросить SCK
	sbic	PINA,	5			;MISO
	sec
	rol	r16
	dec	r17
	brne	bit
	sbi	PORTA,	0			;CSN в "1"
	ld	r16,	z			;Инкрементировать текущее значение RDAC
	inc	r16
	st	z+,	r16
	inc	r14
	ldi	r16,	4			;Если настроили все резисторы - закругляемся
	cp	r16,	r14
	brne	addr
	ret
