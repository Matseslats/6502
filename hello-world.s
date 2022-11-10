PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000

reset:
  ldx #$ff       ; legg til i x registeret
  txs			 ; last inn verdien fra x til stacken

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction	; hopp til subrutine.
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction
  
  ldx #0
print:
  lda message,x		; bruk adresse til message, legg til verdien i x register
  beq loop		; hvis vi lasta inn null, g� til loop
  jsr print_char
  inx			; legg til 1 i reg x
  jmp print
  
loop:
  jmp loop

message: .asciiz "Hello, world!"	; Hva skal skrives p� skjermen?

lcd_wait:
  pha			; Lagre a register verdien i stack
  lda #%00000000	; Port B er innganger
  sta DDRB
lcd_busy:
  lda #RW		; Lese modus
  sta PORTA		; Skriv til utgangen p� VIA
  lda #(RW | E) 	; OR sammen 010xx... og 100xx...
  sta PORTA
  lda PORTB		; Les data bits p� LCD, lagre i A register
  and #%10000000	; Sett alle andre bits enn BF til 0
  bne lcd_busy		; Bli i loopen hvis BF er H�Y
  
  lda #RW		; Tilbake til skrivemodus
  sta PORTA  
  lda #%11111111	; Port B er utganger
  sta DDRB
  pla			; Hent veidien fra stack til a register
  rts

lcd_instruction:
  jsr lcd_wait	 ; Sjekk om LCD er opptatt
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts			 ; ReTurn from Subrutine, gå tilbake til der funksjonen ble kalt.

print_char:
  jsr lcd_wait	  ; Sjekk om LCD er opptatt
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
  rts


  .org $fffc
  .word reset
  .word $0000
