PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

value = $0200	; 2 bytes
mod10 = $0202	; 2 bytes
message = $0204 ; 6 bytes

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
  
  lda #0
  sta message # tom string istedenfor null string
  ; initialiser value som tallet som skal konverteres
  lda number		; hent tall
  sta value		; lagre i RAM
  lda number + 1	; hent neste byte
  sta value + 1		; lagre i RAM
  
divide:
  ; initialiser menten til å bli 0
  lda #0		; last inn 0
  sta mod10		; legg 0 til i mod10
  sta mod10 + 1		;
  clc			; clear carry bit

  ldx #16
divloop:
  ; roter kvotent og mente
  rol value		; flytt ett hakk til venstre 0010 -> 0100 -> 1000
  rol value + 1
  rol mod10
  rol mod10 + 1

  ; a, y = teller - nevner
  sec			; set carry
  lda mod10
  sbc #10
  tay			; lagre laveste bit til y register
  lda mod10 + 1
  sbc #0
  bcc ignore_result	; branch hvis teller < nevner
  sty mod10
  sta mod10 + 1

ignore_result:
  dex			; gjør verdi i x register 1 mindre
  bne divloop		; hvis verdien i x reg ikke er 0
  rol value 		; last inn siste bit til kvotent
  rol value + 1

  lda mod10
  clc
  adc #"0"		; legg til med carry
  jsr push_char

  ; if value != 0, then continue dividing
  lda value
  ora value + 1
  bne divide 		; branch hvis value og value + 1 ikke er lik 0

; Gå gjennom hvert tegn i melding og print til LCD
  ldx #0
print:
  lda message,x
  beq loop		; hvis null, gå til loop
  jsr print_char
  inx
  jmp print

loop:
  jmp loop

number: .word 1729

; Legg til verdien av a registeret til begynnelsen av en null-terminated string 'message'
push_char:
  pha		; push ny første bokstav til stack
  ldy #0	; indexen til meldingen

char_loop:
  lda message,y	; få karakter fra string og putt i a register
  tax		; flytt a til x register
  pla		; hent fra stack
  sta message,y
  iny		; gå til neste bokstav
  txa		; flytt x tilbake til a registeret
  pha		; push fra string til stack
  bne char_loop

  pla
  sta message,y	; flytt null fra stack til slutten av string

  rts

lcd_wait:
  pha			; Lagre a register verdien i stack
  lda #%00000000	; Port B er innganger
  sta DDRB
lcd_busy:
  lda #RW		; Lese modus
  sta PORTA		; Skriv til utgangen på VIA
  lda #(RW | E) 	; OR sammen 010xx... og 100xx...
  sta PORTA
  lda PORTB		; Les data bits på LCD, lagre i A register
  and #%10000000	; Sett alle andre bits enn BF til 0
  bne lcd_busy		; Bli i loopen hvis BF er HØY
  
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
  rts			 ; ReTurn from Subrutine, gÃ¥ tilbake til der funksjonen ble kalt.

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
