PORTB = $6000 ; I/O PORT B på VIA
PORTA = $6001 ; I/O PORT A på VIA
DDRB = $6002 ; Data retning PORT B på VIA
DDRA = $6003 ; Data retning PORT A på VIA
PCR = $600c ; Write Handshake Control, s.12 i datablad
IFR = $600d ; Interrupt flag register, s.26
IER = $600e ; Input enable register, s.27

vidpage = $0000 ; 2 bytes, adresse som lagrer hvor video minne starter
bakgrunn_farge = $0002 ; 1 byte, adressen til fargen til bakgrunnen

snake_color = $0010 ; 1 byte, adressen til fargen til slangen
snake_x = $0011 ; 1 byte, adresse til x posisjon til slangen
snake_y = $0012 ; 1 byte, adresse til y posisjon til slangen

  .org $8000 ; ROM starter på denne adressen
	
  ; Initialiser program
reset:
  ; Initialiser vidpage som startadresse til video RAM, $2000
  lda #$20
  sta vidpage + 1
  lda #$00
  sta vidpage
  
  lda #$F0 ; Farge på slangen
  sta snake_color
  
  ; Initialiser slangens posisjon
  lda #$0F ; X posisjon til slangen
  sta snake_x
  lda #$04 ; Y posisjon til slangen
  sta snake_y
  
  lda #$AA ; Farge på bakgrunnen, RRBB GG--, 10101000
  sta bakgrunn_farge

; -------------------------------------------------  
  ; Fyll skjermen med bakgrunnsfargen
  ldx #$40 ; Start på x verdi 64 (40 hex)
  ldy #$0 ; Start på y verdi 100 (64 hex)
  
; Lagre fargen til alle pikslene.
fyll:
  sta (vidpage), y ; Skriv fargen til startadresse + y verdi. Parantes betyr at det er et 16 bit nummer.
  
  iny ; Gjør y en større
  bne fyll ; Hvis den har hatt rollover, gått over 255, gå til fyll
  
  inc vidpage + 1 ; Gå til neste rad
  dex ; Gjør x en mindre
  bne fyll ; Hvis den ikke har kommet til 0, gå til fyll
  
  

loop:
  lda snake_color ; Hent fargen på slangen
  sta $2220 ; Skriv fargen til spesifik piksle x = 000 1000 y = 0 0010 0. Adresse = 0001y yyyy yxxx xxxx
  
  jmp loop
	

; Reset/IRQ/NMI vektorer
  .org $fffa
  .word reset
  .word reset
  .word reset