PORTB = $6000 ; I/O PORT B på VIA
PORTA = $6001 ; I/O PORT A på VIA
DDRB = $6002 ; Data retning PORT B på VIA
DDRA = $6003 ; Data retning PORT A på VIA
PCR = $600c ; Write Handshake Control, s.12 i datablad
IFR = $600d ; Interrupt flag register, s.26
IER = $600e ; Input enable register, s.27

vidpage = $0000 ; 2 bytes, adresse som lagrer hvor video minne starter
bakgrunn_farge = $0002 ; 1 byte, adressen til fargen til bakgrunnen
skriv_piksel = $0003 ; 2 bytes, et sted å lagre pikselen som skal skrives

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
  
  lda #$07 ; Farge på slangen
  sta snake_color
  
  ; Initialiser slangens posisjon
  lda #$10 ; X posisjon til slangen
  sta snake_x
  lda #$20 ; Y posisjon til slangen
  sta snake_y

  lda #$AA ; Farge på bakgrunnen, --GGBBRR, 10101010
  sta bakgrunn_farge
  
loop:
  ; Fyll skjermen med bakgrunnsfargen
  ldx #$40 ; Start på x verdi 64 (40 hex)
  ldy #$0 ; Start på y verdi 100 (64 hex)
  lda bakgrunn_farge
  
; Lagre fargen til alle pikslene.
fyll_bakgrunnen:
  sta (vidpage), y ; Skriv fargen til startadresse + y verdi. Parantes betyr at det er et 16 bit nummer.
  
  iny ; Gjør y en større
  bne fyll_bakgrunnen ; Hvis den har hatt rollover, gått over 255, gå til fyll
  
  inc vidpage + 1 ; Gå til neste rad
  dex ; Gjør x en mindre
  bne fyll_bakgrunnen ; Hvis den ikke har kommet til 0, gå til fyll
  
  
; Tegn piksel på skjermen
  inc snake_y
  ; Tøm pikselverdien
  lda #$0
  sta skriv_piksel
  lda #$20
  sta skriv_piksel + 1
  ; Legg til snake sin y verdi i byten til venstre
  lda snake_y
  clc
  ror ; Flytt bitene en til høyre
  and #%00011111 ; Bare ta vare på de fem minste bitene
  ora skriv_piksel + 1 ; Legg til startpos
  sta skriv_piksel + 1 ; Lagre byte
  ; Legg til snake sin y verdi i vyten til høyre
  lda snake_y
  clc
  ror ; y bit 0 går inn i carry
  ror ; y bit 0 går til bit 7 posisjonen
  and #%10000000 ; Bare ta vare på det som var bit y0
  ora skriv_piksel
  sta skriv_piksel
  ; Legg til snake sin x verdi i pikselverdien
  clc
  lda snake_x
  and #%01111111 ; Ikke ta vare på verdien der y er
  ora skriv_piksel
  sta skriv_piksel
  
  
  lda snake_color ; Hent fargen på slangen
  ldx #$0
  sta (skriv_piksel, x) ; En to byte variabel.
  
  jmp loop
	

; Reset/IRQ/NMI vektorer
  .org $fffa
  .word reset
  .word reset
  .word reset