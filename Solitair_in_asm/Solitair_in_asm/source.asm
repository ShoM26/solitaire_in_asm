;-----------------------------------------
;Solitaire in ASM by Larz Carswell, Logan Pride, Adam Easterday, Yadhu Urs, Merrick Shorter, Nikane Ambos, Nathan Kern, Florida Rwejuna,
;Final Project of CIS-210
;------------------------------------------------

INCLUDE Irvine32.inc
;INCLUDE macros.inc
.data

;Beginning of code by Logan
;-----Card variables-----
cards   DD 0301h,0302h,0303h,0304h,0305h,0306h,0307h,0308h,0309h,030Ah,030Bh,030Ch,030Dh
        DD 0201h,0202h,0203h,0204h,0205h,0206h,0207h,0208h,0209h,020Ah,020Bh,020Ch,020Dh
        DD 0101h,0102h,0103h,0104h,0105h,0106h,0107h,0108h,0109h,010Ah,010Bh,010Ch,010Dh
        DD 0001h,0002h,0003h,0004h,0005h,0006h,0007h,0008h,0009h,000Ah,000Bh,000Ch,000Dh
noCard BYTE "--------", 0
spadeString BYTE " of ",1Bh, "[90;4mSpades", 1Bh,"[0m",0
heartString BYTE " of ",1Bh, "[31;4mHearts", 1Bh,"[0m",0
clubString BYTE " of ",1Bh, "[90;4mClubs", 1Bh,"[0m",0
diamondString BYTE " of ",1Bh, "[31;4mDiamonds", 1Bh,"[0m",0
aceString BYTE "Ace",0
jackString BYTE "Jack",0
queenString BYTE "Queen",0
kingString BYTE "King",0
;End of code by Logan

;Beginning of code by Madison, Nikane, Logan
;-----Menu variables-----
sourceAddr DWORD 0
destAddr DWORD 0
sourceTopAddr DWORD 0
destTopAddr DWORD 0
promptUserAwait BYTE "Please make a choice: ", 0
optionMenuDraw BYTE "1. Draw",0Dh, 0Ah, 0
optionMenuMove BYTE "2. Move a card",0Dh, 0Ah, 0
optionMenuNewGame BYTE "0. New Game",0Dh, 0Ah, 0
optionMenuExit BYTE "9. Exit",0Dh, 0Ah, 0

moveMenuHeader BYTE "Move card options: ",0Dh, 0Ah, 0
moveMenuDestination BYTE "Select a destination: ",0Dh, 0Ah, 0
moveMenuSource BYTE "Select a source: ",0Dh, 0Ah, 0

moveMenuDraw BYTE "0. Draw stack",0Dh, 0Ah, 0
moveMenuPile1 BYTE "1. Pile 1",0Dh, 0Ah, 0
moveMenuPile2 BYTE "2. Pile 2",0Dh, 0Ah, 0
moveMenuPile3 BYTE "3. Pile 3",0Dh, 0Ah, 0
moveMenuPile4 BYTE "4. Pile 4",0Dh, 0Ah, 0
moveMenuPile5 BYTE "5. Pile 5",0Dh, 0Ah, 0
moveMenuPile6 BYTE "6. Pile 6",0Dh, 0Ah, 0
moveMenuPile7 BYTE "7. Pile 7",0Dh, 0Ah, 0
moveMenuSuit0 BYTE "8. Suit 1",0Dh, 0Ah, 0
moveMenuSuit1 BYTE "9. Suit 2",0Dh, 0Ah, 0
moveMenuSuit2 BYTE "10. Suit 3",0Dh, 0Ah, 0
moveMenuSuit3 BYTE "11. Suit 4",0Dh, 0Ah, 0
;End of code by Madison, Nikane, Logan

;Beginning of code by Larz
;-----Procedure variables-----
temp1 DWORD 0
temp2 DWORD 0
temp3 DWORD 0
temp4 DWORD 0
;End of code by Larz

;Beginnning of code by Adam Easterday
;-----Deck variables-----
Deck DWORD 52 DUP(?)
Draw DWORD 52 DUP(?)
deckTops DWORD -1, -1
;End of Code by Adam Easterday

;Beginning of code by Yadhu
;-----Pile variables-----
Pile1 DWORD 19 DUP(?)
Pile2 DWORD 19 DUP(?)
Pile3 DWORD 19 DUP(?)
Pile4 DWORD 19 DUP(?)
Pile5 DWORD 19 DUP(?)
Pile6 DWORD 19 DUP(?)
Pile7 DWORD 19 DUP(?)
pilesTops DWORD 7 DUP (-1)
;End of code by Yadhu

;Beginnning of code by Adam Easterday
;-----Suit variables-----
Suit0 DWORD 13 DUP(?)
Suit1 DWORD 13 DUP(?)
Suit2 DWORD 13 DUP(?)
Suit3 DWORD 13 DUP(?)
suitsTops DWORD 4 DUP(-1)

piles DWORD (DWORD PTR Pile1), DWORD PTR Pile2, DWORD PTR Pile3, DWORD PTR Pile4, DWORD PTR Pile5, DWORD PTR Pile6, DWORD PTR Pile7
suits DWORD (DWORD PTR Suit0), DWORD PTR Suit1, DWORD PTR Suit2, DWORD PTR Suit3

;End of Code by Adam Easterday

.code
;Beginning of code by Larz
;-----------------------------------
;showCard - shows a formatted display of a card where the lower 16 bits of eax are
;check this reference https://notes.burke.libbey.me/ansi-escape-codes/ for colored text
;the card's suit and rank:
;	ah holds the suit: 00 = spades, 01 = hearts, 02 = clubs, 03 = diamonds
;	al holds the rank: 01 = ace, 02-0A = 2-10, B = jack, C = queen, D = king
;Expects:
;	the raw value of a card in eax (ex: 00000305h is the 5 of diamonds)
;	al must be between 1h and Dh
;	ah must be between 0h and 3h
;-----------------------------------
showCard PROC far uses eax ebx ecx edx
	movzx ebx, al
	movzx ecx, ah
	cmp eax, 0			;placeholder for card
	je showNoCard
	cmp ebx, 1			;EBX == 1 (ace)?
	je showRankAce
	cmp ebx, 11			;EBX < 11?
	jl showRankNumeric	;1 (ace) < EBX < 11 (jack)
	je showRankJack		;EBX == 11 (jack)?
	cmp ebx, 12			;EBX == 12 (queen)?
	je showRankQueen
	cmp ebx, 13			;EBX == 13 (king)?
	je showRankKing

	showNoCard:
		mov edx, OFFSET noCard
		jmp endShowCards
        ;ret
	showRankAce:
		mov edx, OFFSET aceString
		call writeString
		jmp endShowRank
	showRankNumeric:
		mov eax, ebx
		call writeint
		jmp endShowRank
	showRankJack:
		mov edx, OFFSET jackString
		call writeString
		jmp endShowRank
	showRankQueen:
		mov edx, OFFSET queenString
		call writeString
		jmp endShowRank
	showRankKing:
		mov edx, OFFSET kingString
		call writeString
		jmp endShowRank
	endShowRank:


	cmp ecx, 0
	je showspades
	cmp ecx, 1
	je showhearts
	cmp ecx, 2
	je showclubs
	cmp ecx, 3
	je showdiamonds
	jmp endShowCards
	showspades:
		mov edx, OFFSET spadeString
		jmp endShowCards
	showhearts:
		mov edx, OFFSET heartString
		jmp endShowCards
	showclubs:
		mov edx, OFFSET clubString
		jmp endShowCards
	showdiamonds:
		mov edx, OFFSET diamondString
		jmp endShowCards
	endShowCards:
	call writestring		; finally, display the string and return
	ret
showCard ENDP
;Ending of code by Larz

;Beginning of code by Larz
;---------------------------------------------------------
;displayDeckAndDraw - simple display function to show the cards in the deck and draw stacks
;   Calls displayStack on both Deck and Draw
;---------------------------------------------------------
displayDeckAndDraw PROC uses edx ebx
    mov edx, OFFSET Deck
    mov ebx, 52
    call crlf
    call displayStack
    call crlf

    call crlf
    mov edx, OFFSET Draw
    mov ebx, 52
    call crlf
    call displayStack
    call crlf
    call writeDashes
    ret
displayDeckAndDraw ENDP
;End of code by Larz

;Beginning of code by Larz & Yadhu
;---------------------------------------------------------
;displaySuits - simple display function to show the cards in each suit stack
;---------------------------------------------------------
displaySuits PROC USES EAX EBX ECX EDX ESI
    mov edx, OFFSET suits           ; point to piles container
    ;print each stack
    mov ecx, 0
    .WHILE ecx <= 12                ; loop through piles: max index is 3, 3*4 = 12
        mov esi, [edx+ecx]          ; add 4 to go to the next pile

        push ecx                    ; reuse ecx
        mov ecx, 0
        
        .WHILE ecx <= 48            ; loop through cards: max index is 12, 12*4 = 48
            mov eax, 20h
            call writechar
            mov eax, [esi+ecx]      ; add 4 to go the the next element
            call showCard
            ;call crlf
            add ecx, 4
        .ENDW
        call crlf
        pop ecx
        add ecx, 4
    .ENDW
    ret
displaySuits ENDP
;End of code by Larz & Yadhu

;Beginning of code by Larz & Yadhu
;---------------------------------------------------------
;displayPiles - simple display function to show the cards in each pile stack
;---------------------------------------------------------
displayPiles PROC USES EAX EBX ECX EDX ESI
    mov edx, OFFSET piles           ; point to piles container
    ;print each stack
    mov ecx, 0
    .WHILE ecx <= 24                ; loop through piles: max index is 6, 6*4 = 24
        mov esi, [edx+ecx]          ; add 4 to go to the next pile

        push ecx                    ; reuse ecx
        mov ecx, 0
        
        .WHILE ecx <= 72            ; loop through cards: max index is 18, 18*4 = 72
            mov eax, 20h
            call writechar
            mov eax, [esi+ecx]      ; add 4 to go the the next element
            call showCard
            ;call crlf
            add ecx, 4
        .ENDW
        call crlf
        pop ecx
        add ecx, 4
    .ENDW
    ret
displayPiles ENDP
;End of code by Larz & Yadhu

;Beginning of code by Nikane, Logan, & Madison
;---------------------------------------------------------
;await - provides the user with a menu and calls relevant functions
;---------------------------------------------------------
await PROC uses eax ebx ecx edx edi esi
    UserInput:
       mov edx, OFFSET optionMenuDraw
       call WriteString
       mov edx, OFFSET optionMenuMove
       call WriteString
       mov edx, OFFSET optionMenuNewGame
       call writeString
       mov edx, OFFSET optionMenuExit
       call writeString
       mov edx,OFFSET promptUserAwait ;move promptUser into edx
       call WriteString           ;Display promptUser onto the screen
       call ReadInt                 ;input the integer
       ;mov   eax           ;store the value from the register into userNum

       validateUserInput:           ;validate input - LOGAN
       .if eax < 0 || eax > 9
        jmp UserInput
       .endif
       .if eax == 0
            call newgame
       .elseif eax == 1
            call drawfromdeck            ;DRAW A CARD
       .elseif eax == 2
            ;get source option
            getMenu2Selection1:
            mov edx, offset moveMenuHeader
            call writestring
            mov edx, offset moveMenuDraw
            call writestring
            mov edx, offset moveMenuPile1
            call writestring
            mov edx, offset moveMenuPile2
            call writestring
            mov edx, offset moveMenuPile3
            call writestring
            mov edx, offset moveMenuPile4
            call writestring
            mov edx, offset moveMenuPile5
            call writestring
            mov edx, offset moveMenuPile6
            call writestring
            mov edx, offset moveMenuPile7
            call writestring
            mov edx, offset moveMenuSuit0
            call writestring
            mov edx, offset moveMenuSuit1
            call writestring
            mov edx, offset moveMenuSuit2
            call writestring
            mov edx, offset moveMenuSuit3
            call writestring
            mov edx, offset moveMenuSource
            call writestring
            call readint
            ;SET sourceTopAddr AND sourceAddr
            .if eax < 0 || eax > 11
                jmp getMenu2Selection1
            .elseif eax == 0
                mov esi, offset decktops
                add esi, 4  ;&draw top
                mov sourceTopAddr, esi
                mov sourceAddr, offset draw
                
            .elseif eax == 1
                mov edx, offset pilestops
                ;add edx, 0
                mov sourceTopAddr, edx
                mov sourceAddr, offset pile1
            .elseif eax == 2
                mov edx, offset pilestops
                add edx, 4
                mov sourceTopAddr, edx
                mov sourceAddr, offset pile2
            .elseif eax == 3
                mov edx, offset pilestops
                add edx, 8
                mov sourceTopAddr, edx
                mov sourceAddr, offset pile3
            .elseif eax == 4
                mov edx, offset pilestops
                add edx, 12
                mov sourceTopAddr, edx
                mov sourceAddr, offset pile4
            .elseif eax == 5
                mov edx, offset pilestops
                add edx, 16
                mov sourceTopAddr, edx
                mov sourceAddr, offset pile5
            .elseif eax == 6
                mov edx, offset pilestops
                add edx, 20
                mov sourceTopAddr, edx
                mov sourceAddr, offset pile6
            .elseif eax == 7
                mov edx, offset pilestops
                add edx, 24
                mov sourceTopAddr, edx
                mov sourceAddr, offset pile7

            ;------logic for suits begins here------
            .elseif eax == 8                    
                mov edx, offset suitstops
                ;add edx, 0
                mov sourceTopAddr, edx
                mov sourceAddr, offset suit0
            .elseif eax == 9                    
                mov edx, offset suitstops
                add edx, 4
                mov sourceTopAddr, edx
                mov sourceAddr, offset suit1
            .elseif eax == 10                    
                mov edx, offset suitstops
                add edx, 8
                mov sourceTopAddr, edx
                mov sourceAddr, offset suit2
            .elseif eax == 11                    
                mov edx, offset suitstops
                add edx, 12
                mov sourceTopAddr, edx
                mov sourceAddr, offset suit3
            .endif

            ;shl eax, 8              ;store this byte as our source ??00h -> SS00h
            ;push eax
            ;call crlf
            ;call writehex

            call crlf
            ;get dest option
            getMenu2Selection2:
            mov edx, offset moveMenuHeader
            call writestring
            mov edx, offset moveMenuPile1
            call writestring
            mov edx, offset moveMenuPile2
            call writestring
            mov edx, offset moveMenuPile3
            call writestring
            mov edx, offset moveMenuPile4
            call writestring
            mov edx, offset moveMenuPile5
            call writestring
            mov edx, offset moveMenuPile6
            call writestring
            mov edx, offset moveMenuPile7
            call writestring
            mov edx, offset moveMenuSuit0
            call writestring
            mov edx, offset moveMenuSuit1
            call writestring
            mov edx, offset moveMenuSuit2
            call writestring
            mov edx, offset moveMenuSuit3
            call writestring
            mov edx, offset moveMenuDestination
            call writestring
            call readint

            ;LOGIC FOR DESTINATION SELECTION
            .if eax < 1 || eax > 11
                jmp getMenu2Selection2
            .elseif eax == 1
                mov edx, offset pilestops
                ;add edx, 0
                mov destTopAddr, edx
                mov destAddr, offset pile1
            .elseif eax == 2
                mov edx, offset pilestops
                add edx, 4
                mov destTopAddr, edx
                mov destAddr, offset pile2
            .elseif eax == 3
                mov edx, offset pilestops
                add edx, 8
                mov destTopAddr, edx
                mov destAddr, offset pile3
            .elseif eax == 4
                mov edx, offset pilestops
                add edx, 12
                mov destTopAddr, edx
                mov destAddr, offset pile4
            .elseif eax == 5
                mov edx, offset pilestops
                add edx, 16
                mov destTopAddr, edx
                mov destAddr, offset pile5
            .elseif eax == 6
                mov edx, offset pilestops
                add edx, 20
                mov destTopAddr, edx
                mov destAddr, offset pile6
            .elseif eax == 7
                mov edx, offset pilestops
                add edx, 24
                mov destTopAddr, edx
                mov destAddr, offset pile7

            ;------logic for suits begins here------
            .elseif eax == 8                    
                mov edx, offset suitstops
                ;add edx, 0
                mov destTopAddr, edx
                mov destAddr, offset suit0
            .elseif eax == 9                    
                mov edx, offset suitstops
                add edx, 4
                mov destTopAddr, edx
                mov destAddr, offset suit1
            .elseif eax == 10                    
                mov edx, offset suitstops
                add edx, 8
                mov destTopAddr, edx
                mov destAddr, offset suit2
            .elseif eax == 11                    
                mov edx, offset suitstops
                add edx, 12
                mov destTopAddr, edx
                mov destAddr, offset suit3

            .else
                call dumpregs
                jmp leaveGetInput
            .endif
            ;now call take and put
            mov edx, sourceAddr
            mov edi, sourceTopAddr
                
            call take   ;expects edx=&source, edi=&sourcetop -> returns eax = card at top
                
            mov ebx, 18
            mov edx, destAddr
            mov edi, destTopAddr
            call put    ;eax=card,ebx=stackSize,edx=&dest,edi=&desttop
       .elseif eax == 9
            call exitprocess        ;leave game
       .endif
       call  Crlf                   ;new line
       call showBoard
    leaveGetInput:
    ret
await ENDP
;End of code by Nikane, Logan, & Madison

;Beginning of code by Nathan & Logan
;---------------------------------------------------------
;put - push procedure for an intstack
;Expects:
;   EAX = the value of a card
;   EBX = the value of the stack's max index (the size of the stack - 1 (ex: pile1's max index is 18)) 
;   EDX = the address of the specific stack
;   EDI = the address of the top of the stack
;Modifies: the value of stack[top+1] = eax IF stack is not full
;---------------------------------------------------------
put PROC uses EDX EBX EAX EDI
                            ;--------check if stack is full--------
	push eax                ; store eax and ebx 
    push ebx
    
    mov eax, [edi]          ; edi holds our value for top
    cmp ebx, eax
    pop ebx
    pop eax
    je full                 ; skip directly to a return statement if full

                            ; --------if not full--------
    inc DWORD PTR [edi]     ; update the top of Pile1

    push ebx                ; Let's use ebx to point to the top
    mov ebx, [edi]          ; see ^
    mov [edx+ebx*4], eax    ; now use the new card to update Pile1[1]
    pop ebx                 ; restore ebx
    

    full:
                            ;display is full
        ret
put ENDP
;End of code by Nathan & Logan

;Beginning of code by Nathan & Logan
;---------------------------------------------------------
;take - pop procedure for an intstack
;Expects:
;   EDX = the address of the specific stack
;   EDI = the address of the stack top
;Modifies: stack[top] = 0 if stack is not empty
;Returns: 
;   EAX = the value of the card popped from the stack, else -1
;---------------------------------------------------------
take PROC uses EDX EBX EDI

    ;If stack is not empty
    mov eax, [edi]          ; edi holds our value for top

    cmp eax, -1             ; check if top is 0
    je empty                ; skip directly to a return statement if full

                            ; --------if not full--------
                            ; Let's use ebx to point to the top
    mov ebx, [edi]          ; SET EBX = top of stack
    mov eax,[edx+ebx*4]     ; SET EAX = Stack[ebx]
   
    push eax                
    mov eax, 0              ; set the card at the position we popped to 0
    mov [edx+ebx*4], eax    
    pop eax
    dec DWORD PTR [edi]     ; update the top of Pile1
                            ; restore ebx
    

    empty:

        ret
take ENDP
;End of code by Nathan & Logan

;Beginning of code by Larz
;---------------------------------------------------------
;displayStack - simple display function to show the cards in a single stack
;Expects:
;   EBX = the value of the stack's max index (the size of the stack - 1 (ex: pile1's max index is 18)) 
;   EDX = the pointer to the specific stack
;---------------------------------------------------------
displayStack PROC USES EAX EBX ECX EDX

    mov ecx, 0
    mov eax, 0
    .WHILE ecx < ebx                ; loop through piles: max index is 6, 6*4 = 24
        mov eax, [edx+ecx*4]
        call showCard
        call crlf
        inc ecx
    .ENDW
    ret
displayStack ENDP
;End of code by Larz

;Beginning of code by Larz
;---------------------------------------------------------
;initDeck - copies cards to Deck
;Modifies:
;   Copies cards to Deck
;---------------------------------------------------------
initDeck PROC USES ECX EDX
    mov ecx, 0
    mov edi, OFFSET Deck
    mov esi, OFFSET cards
    .WHILE ecx < 52
        mov eax, [esi+ecx*4]; eax = card from cards
        mov [edi+ecx*4],eax ; write that card to the deck
        

        push edi            ; write the corresponding draw pile card to 0
        mov edi, OFFSET draw
        mov DWORD PTR [edi+ecx*4], 0
        pop edi

        inc ecx             ; move forward
        .ENDW
    mov edi, OFFSET decktops
    mov DWORD PTR [edi], 51           ; set deck top to 51
    add edi, 4              ; go to draw pile top
    mov DWORD PTR [edi], -1
    ret
initDeck ENDP
;End of code by Larz

;Beginning of code by Florida
;---------------------------------------------------------
;drawRandomCard - draws a random card from the deck and places it in EAX
;Modifies:
;   Deck[Random] = 0 if Deck is not empty
;Returns:
;   EAX = the value of a card previously at Deck[Random]
;---------------------------------------------------------
drawRandomCard PROC uses EDI EDX EBX ECX ESI
    mov edx, OFFSET decktops    ; set max value of random function to the top of deck
    mov eax, [edx]              ; set this value in eax for comparison
    cmp eax, -1                 ; check if deck is empty, jump to return if so
    je noDraw
    mov ebx, eax                ; also in ebx (used for function call)
    inc eax                     ; random range is on the interval [0,top); make it [0,top+1)
    call randomrange            ; otherwise EAX = a random number between 0 and top+1
    
    mov edx, OFFSET Deck        ; at this point, EBX = top, EAX = <random>
    mov edi, OFFSET decktops
    ;LOGIC: draw a card, push to memory stack, repeat <random>-1 times
    ;THEN: draw a card, do something with it, and pop from memory stack; push to Deck <random>-1 times
    
    mov esi, eax                ; ESI = <random>-1
    mov ecx, eax
    .WHILE ecx > 0
        call take               ; draw a card into eax
        push eax
        dec ecx
    .ENDW
    call take
    mov temp1, eax              ; Do something with eax?

    mov ecx,esi                 ; loop count to pop back to deck
    mov temp2, ebx              ; store top of deck in ebx
    mov ebx, 52                 ; argument for put
    .WHILE ecx > 0
        pop eax
        call put                    ;EAX = card, EBX = 52, EDX = address, EDI = pointer to top
        dec ecx
    .ENDW
                                    ; Now ensure the return condition (EAX = drawn card)
    mov eax, temp1                  ; note: bad design; this variable is a bandaid solution
    
    ret
    noDraw:
        ret
drawRandomCard ENDP
;End of code by Florida

;Beginning of code by Florida
;---------------------------------------------------------
;drawFromDeck - draws a card from Deck and places it on the top of Draw
;Modifies:
;   *Deck = Deck/Deck[top]; Draw = *Draw + Deck[top] if Deck is not empty
;   *Deck = Draw; Draw = {} if Deck is empty
;---------------------------------------------------------
drawFromDeck PROC uses EDI EAX EDX EBX ECX ESI
    mov edx, OFFSET Deck        ; &Deck
    mov edi, OFFSET deckTops    ; deckTops[0]
    mov eax, [edi]
    cmp eax, -1                 ; check if top is -1
    je deckEmpty                ; skip directly to a return statement if empty
    call take                   ; now eax is a drawn card?
    mov edx, OFFSET Draw        ; &Draw
    mov edi, OFFSET deckTops
    add edi, 4                  ; deckTops[1]
    mov ebx, 52
    call put

    deckEmpty:
        ;TODO - push draw to deck until draw is empty
        ret
drawFromDeck ENDP
;End of code by Florida

;Beginning of code by Nathan
;---------------------------------------------------------
;shuffleDeck - randomizes the order of the deck; called only once at the start of a new game
;Modifies:
;   Elements of Deck are in random order
;---------------------------------------------------------
shuffleDeck PROC uses EDI EAX EDX EBX ECX ESI
    mov ecx, 52
    shuffle1:
        call drawRandomCard                   ; now eax is a drawn card

        mov edx, OFFSET Draw        ; &Draw
        mov edi, OFFSET deckTops
        add edi, 4                  ; deckTops[1]
        mov ebx, 51
        call put
    loop shuffle1

    ;Now that every random card is in Draw, push them all back to Deck
    mov ecx, 52
    shuffle2:
        ;get card from Draw
        mov edx, OFFSET Draw        ; &Draw
        mov edi, OFFSET deckTops
        add edi, 4                  ; deckTops[1]
        call take
        
        ;put card in Deck
        mov edx, OFFSET Deck        ; &Deck
        mov edi, OFFSET deckTops    ; deckTops[0]
        mov ebx, 51
        call put
        loop shuffle2
    ret
shuffleDeck ENDP
;End of code by Nathan

;Beginning of code by Larz and Merrick
;---------------------------------------------------------
;dealPiles - draws a number of cards into their respective pile stacks
;Expects:
;Modifies:
;   *pileN = {<N random cards>}
;   *Deck = Deck/{<piles>}
;---------------------------------------------------------
dealPiles PROC uses ecx edx eax ebx edi
    ;use two loops to deal piles
    mov ecx, 0
    mov edx, OFFSET piles
    mov edi, OFFSET pilesTops
    mov ebx, 18                         ; EBX = max size of any pile

    push ecx
    .while ecx < 7                      ; for each pile
        push edx
        push edi
        
        mov edx, [edx+ecx*4]            ; EDX = the address of piles[ecx]

        push temp1
        push ecx
        add ecx, 1
        mov temp1, 0
        .while temp1 < ecx
            push edx
            push edi
            mov edx, OFFSET Deck
            mov edi, OFFSET deckTops
            call take                       ; EAX = the value of a card
            pop edi
            pop edx
            call put
            inc temp1
        .endw
        pop ecx
        pop temp1
        
        pop edi
        add edi, 4
        pop edx
        inc ecx
    .endw
    pop ecx
    ret
dealPiles ENDP
;End of code by Larz and Merrick

;Beginning of code by Larz
;---------------------------------------------------------
;checkRankPile - checks if a card in eax is a valid PILE successor of ecx
;Expects:
;   EAX = the card to be placed below ECX in the pile (source)
;   ECX = the card to be compared to EAX for placement (destination)
;Returns:
;	EBX = 0 if the swap is not valid, 1 if the swap is valid
;---------------------------------------------------------
checkRankPile PROC uses EAX ECX EDX ESI EDI
    push eax
    push ecx
    mov ebx, 2
    ;format eax and ecx
    ;and eax, 0000ff00h
    shr eax, 8    ; shift eax right 8 bits to leave the suit of the card
    ;and ecx, 0000ff00h
    shr ecx, 8    ; shift ecx right 8 bits to leave the suit of the card
    ;sub ecx, eax  ; subtract the suit of eax from the suit of ecx
    
    ;xchg eax, ecx ; div only works on eax
    and eax, 1      ; eax = 0 or 1
	and ecx, 1      ; ecx = 0 or 1
    add ecx, eax    ; a valid swap consists of one even, one odd (0 + 1 or 1 + 0)
    cmp ecx, 1
 
    pop ecx
    pop eax
    jne invalidPileSwap
    
    ;suitValid:
        push eax
        push ecx
        ;now compare ranks (lower order bits)
        
        and eax, 000000ffh
        and ecx, 000000ffh
        
        cmp ecx, eax
        
        ;this avoids setting eip to ecx and eax
        pop ecx
        pop eax
        jle invalidPileSwap

        ;push eax
        ;push ecx
        
        and eax, 1
        and ecx, 1      
        add ecx, eax  ; find the difference of the two suits (1-0,3-0,3-2)
        cmp ecx, 1    ; for a valid swap: rank_ecx = rank_eax + 1 -> rank_ecx - rank_eax = 1
        ;pop ecx
        ;pop eax
        jne invalidPileSwap
		mov ebx, 1				; finally, our return true value
        ret
    invalidPileSwap:
		mov ebx, 0				; our return false value
    ret
checkRankPile ENDP
;End of code by Larz

;Beginning of code by Larz
;---------------------------------------------------------
;checkRankSuit - checks if a card in eax is a valid SUIT successor of ecx
;   Example: 0301h can be placed in an empty suit pile
;   0302h can be placed on top of 0301h
;   0402h cannot be placed on top of 301h
;Expects:
;   EAX = the card to be placed on top of the suit pile
;   ECX = the card to be compared to EAX for placement
;Returns:
;   EBX = 1 if the swap is valid, 0 if the swap is invalid
;---------------------------------------------------------
checkRankSuit PROC uses EAX ECX EDX
    ;first compare if the destination card is 0000
    cmp ecx, 0000h
    je validSuit
    
	push eax
	push ecx
    ;format eax and ecx
    
    and eax, 0000ff00h
    shr eax, 8    ; shift eax right 8 bits to leave the suit of the card
    and ecx, 0000ff00h
    shr ecx, 8    ; shift ecx right 8 bits to leave the suit of the card
    
    cmp ecx, eax
    ;cmp ah,ch
    pop ecx
    pop eax
    jne invalidSuitSwap
    validSuit:
		
        push eax
        push ecx
        ;now compare ranks (lower order bits)
        and eax, 000000ffh
        and ecx, 000000ffh       
        sub ecx, eax    ; find the difference of the two suits (1-0,3-0,3-2)
        cmp ecx, -1     ; for a valid swap: rank_ecx = rank_eax - 1 -> rank_eax - rank_ecx = 1
        pop ecx
        pop eax
        jne invalidSuitSwap
		mov ebx, 1				; finally, our return true value
        ret
    invalidSuitSwap:
		mov ebx, 0				; our return false value
    ret
checkRankSuit ENDP
;End of code by LArz

;Beginning of code by Larz
;---------------------------------------------------------
;showSuitTops - displays the values in suitTops array for use in debugging
;---------------------------------------------------------
showSuitTops PROC uses edx eax ecx
    mov edx, offset suitstops
    mov ecx, 4
    showsuittops1:
        mov eax, [edx]
        call writeint
        add edx, 4
    loop showsuittops1
    call crlf
    ret
showSuitTops ENDP
;End of code by Larz

;Beginning of code by Larz
;---------------------------------------------------------
;showPileTops - displays the values in suitTops array for use in debugging
;---------------------------------------------------------
showPileTops PROC uses edx eax ecx
    mov edx, offset pilestops
    mov ecx, 7
    showpiletops1:
        mov eax, [edx]
        call writeint
        add edx, 4
    loop showpiletops1
    call crlf
    ret
showPileTops ENDP
;End of code by Larz

;Beginning of code by Adam 
;---------------------------------------------------------
;clearStacks - sets all elements of all stacks within a container of stacks to 0
;Expects:
;   EDX = the offset of the stack container to be cleared
;   EBX = the max index of each stack (18 or 12 are the only valid values)
;Modifies:
;   All elements of suits and piles stacks are set to 0 and their tops are set to -1
;---------------------------------------------------------
clearStacks PROC uses EAX EBX ECX EDX
    cmp ebx, 12
    je clearSuits
    cmp ebx, 18
    je clearPiles
    jne invalidSize
    clearSuits:

        mov ecx, 4
        ;clear tops
        mov eax, -1
        mov edx, OFFSET suitsTops
        clearSuitTops:
            dec ecx
            mov [edx], eax
            add edx, 4
            inc ecx
        loop clearSuitTops
        ;call showSuitTops

        mov edx, OFFSET suits
        mov ecx, 4
        jmp startClear
    clearPiles:
        
        mov ecx, 7
        mov eax, -1
        mov edx, OFFSET pilesTops ;&pilestops[0]
        clearPileTops:
            dec ecx
            mov [edx+ecx*4], eax
            ;add edx, 4
            inc ecx
            loop clearPileTops
        mov edx, OFFSET piles
        mov ecx, 7
    startClear:
        
        push edx            ; store offset container
        mov edx, [edx]
        push ecx            ; store stack counter

        mov eax, ecx
        mov eax, 0          ; for clearing
        mov ecx, ebx        ; should be 12 or 18
        inc ecx             ; 13 or 19
        
        clearCards:
            dec ecx
            mov [edx+ecx*4], eax
            inc ecx
            loop clearCards
        
        pop ecx
        pop edx
        add edx, 4
        loop startClear
    invalidSize:
    ret
clearStacks ENDP
;End of code by Adam

;Beginning of code by Adam
;---------------------------------------------------------
;writeDashes - writes 100 dashes to the console. Used for separating output.
;---------------------------------------------------------
writeDashes proc uses eax ecx
    call crlf
    mov ecx, 100
    mov eax, 2dh
    F1:
        call writechar
    loop F1
    call crlf
    ret
writeDashes endp
;End of code by Adam

;Beginning of code by Nikane
;---------------------------------------------------------
;newGame - starts a new game by clearing every stack, then shuffles and deals the deck into piles
;Modifies: All stacks and tops to an initial state:
;   Deck is reset and shuffled then cards are drawn to each pile
;---------------------------------------------------------
newGame PROC uses eax ebx ecx edx
    mov ebx, 0
    mov eax, 0
    mov edx, 0
    mov ecx, 0
    call initDeck           ;reset deck
    call shuffleDeck        ;shuffle deck
    mov EDX, offset piles   ;clear piles
    mov EBX, 18
    call clearStacks

    mov EDX, offset suits   ;clear suits
    mov EBX, 12
    call clearStacks

    call dealPiles          ;deal piles
    ret
newGame ENDP
;End of code Nikane

;Beginning of code by Merrick, Larz, Florida, & Adam
;---------------------------------------------------------
;swapToPile - swaps cards from draw or a pile stack to a pile
;Expects:
;   EBX = &source top
;   ECX = &dest top
;   ESI = the address of the source pile or suit stack, not container
;   EDI = the address of the destination pile, not container
;Modifies:
;   Source = Source/Source[top]
;   Source top -= 1
;   Destination = Destination+Source[top]
;   Destination top += 1
;---------------------------------------------------------
swapToPile PROC uses eax ebx ecx edx esi edi
    mov temp1, ebx
    mov temp2, ecx
    mov temp3, esi
    mov temp4, edi
    ;check source.top != -1
    mov edx, esi            ;edx = &sourceStack
    mov eax, [ebx]          ;eax = source top
    cmp eax, -1             ; leave if source stack is empty
    je leaveSwapToPile

    mov eax, [edx+eax*4]    ; mov the top card to eax
    push eax                ; store this card (source)

    ;check dest.top != max (18)
    mov edx, edi            ;edx = &sourceStack
    mov eax, [ecx]          ;eax = source top
    cmp eax, 18             ; leave if dest stack is full
    je leaveSwapToPile
    
    mov eax, [edx+eax*4]    ; move the top card to eax
    push eax                ; store this card (destination)

    

    ;now check if this is a valid swap
    mov edx, ebx            ; store ebx
    pop ebx                 ; EBX = destination card value
    pop eax                 ; EAX = destination card value
    push ecx                ; store &dest.top
    mov ecx, ebx            ; ECX = destination card value
    call checkRankPile      ; EBX = <0|1>
    call dumpregs
    pop ecx
    cmp ebx, 0              ; leave if ebx = 0 (the src and dest cards did not pass validation)
    mov ebx, edx            ; restore ebx
    je leaveSwapToPile
    
    ;if swap is valid, take a card from the source stack
    mov edx, temp3    ;edx = &source
    push edi        ;store &dest
    mov edi, temp1    ;edi = &src.top 
    
    call take       ;expects edx=&source, edi=&sourcetop -> returns eax = card at top
                    ;now eax = a card
    ;finally, put this card into the destination stack
    mov ebx, 18 ;ebx = stack size
    pop edx     ;edx = &dest
    mov edx, temp4
    mov edi, temp2
    call put    ;eax=card,ebx=stackSize,edx=&dest,edi=&desttop
    ret
    leaveSwapToPile:
        ret
swapToPile ENDP
;End of code by Merrick, Larz, Florida, & Adam

;Beginning of code by Merrick, Larz, Florida, & Adam
;---------------------------------------------------------
;swapToSuit - swaps cards from draw or a pile stack to a suit stack
;Expects:
;   EBX = &source top
;   ECX = &dest top
;   ESI = the address of the source pile or suit stack, not container
;   EDI = the address of the destination suit, not container
;Modifies:
;   Source = Source/Source[top]
;   Source top -= 1
;   Destination = Destination+Source[top]
;   Destination top += 1
;---------------------------------------------------------
swapToSuit PROC uses eax ebx ecx edx esi edi
   push ebx
   push ecx
   push esi
   push edi
   mov ebx,[ebx]
   mov ecx,[ecx]
   mov esi,[esi]
   mov edi,[edi]
   pop edi
   pop esi
   pop ecx
   pop ebx
    mov temp1, ebx
    mov temp2, ecx
    mov temp3, esi
    mov temp4, edi
    ;check source.top != -1
    mov edx, temp3            ; edx = &sourceStack
    mov eax, [temp1]          ; eax = source top
    cmp eax, -1             ; leave if source stack is empty
    je leaveSwapToSuit
    mov eax, [edx+eax*4]    ; mov the top card of source to eax
    push eax                ; store this card (source)

    ;check dest.top != max (12)
    mov edx, temp4            ; edx = &destStack
    mov eax, [temp2]          ; eax = dest top
    test eax, 12             ; leave if dest stack is full
    je leaveSwapToSuit
    mov edx, temp4
    mov eax, [edx+eax*4]
    ;mov eax, [edx+eax*4]    ; move the top card to eax
    call dumpregs
    push eax                ; store this card (dest)

    

    ;now check if this is a valid swap
    
    mov edx, ebx            ; store ebx
    pop ebx                 ; EBX = destination card value
    pop eax                 ; EAX = destination card value
    push ecx                ; store &dest.top
    mov ecx, ebx            ; ECX = destination card value
    call dumpregs
    call checkRankSuit      ; EBX = <0|1>
    
    pop ecx
    cmp ebx, 0              ; leave if ebx = 0
    mov ebx, edx            ; restore ebx
    
    je leaveSwapToSuit
    
    ;take a card
    mov edx, temp3    ;edx = &source
    push edi        ;store &dest
    mov edi, temp1    ;edi = &src.top 
    call take       ;expects edx=&source, edi=&sourcetop -> returns eax = card at top
                    ;now eax = a card
    ;NOPE
    ;put a card
    mov ebx, 12 ;ebx = stack size
    pop edx     ;edx = &dest
    mov edx, temp4
    mov edi, temp2
    call put    ;eax=card,ebx=stackSize,edx=&dest,edi=&desttop
    ret
    leaveSwapToSuit:
        call writeDashes
        ret
swapToSuit ENDP
;End of code by Merrick, Larz, Florida, & Adam

;Beginning of code by Merrick
;---------------------------------------------------------
;swap - swaps cards between stacks then checks for the win condition. Valid options are:
;   -from the draw stack to a pile or suit
;   -between a pile to another pile,
;   -between a pile and a suit
;   logic: validate then go to the next empty space (dest = 00000000h) then swap with the source card value
;Expects:
;   EAX = action code
;       0 <= AH <= 0B
;       0 <= AL <= 0B
;---------------------------------------------------------
swap PROC uses eax
    ;TODO Finish this procedure - Beginning of code by Beginning of code by Larz
    ;check action code - let's say it's a 16-bit (0000h-ffffh) code
    ;<source (8 bits)><dest (8 bits)> -> ex: 0001 takes the card on the top of draw and performs a swap with the first pile's top
    ;00 - draw stack
    ;01-07 = pile1-pile7
    ;08, 09, 0A, 0B = suit1, suit2, suit3, suit4

    ;Store source in temp1
    push eax
    and eax, 0000ff00h
    mov temp1, eax
    pop eax

    ;Store destination in temp2
    push eax
    and eax, 000000ffh
    mov temp2, eax
    pop eax


    ;CHECK SOURCE SIZE
    ;check source first -> set temp3 to the source card
    .if temp1 == 0                  ;*****SOURCE = DRAW*****
        mov edx, offset draw
        mov edi, offset decktops    ; tops container
        add edi, 4                  ; address of top of draw stack
        mov eax, [edi]
        cmp eax, -1                 ; if top is -1, leave
        je leaveSwap
        mov ebx, eax                ; store eax
        mov eax, [edx+eax*4]        ; eax = card at top of draw stack
        
        mov temp3, eax
	
    .elseif temp1 > 0 && temp1 < 8  ;*****SOURCE = PILE_N*****
        ;logic for pile
        mov ecx, temp1          ; pileIndex+1
        dec ecx                 ; this should be our pile index
        mov edx, offset piles   ; go to piles[0]
        mov edx, [edx+ecx*4]    ; go to piles[ecx]

        mov edi, offset pilesTops ;goal: go to piles[ecx][pileTop]
        mov ecx, temp1
        .while ecx > 0
            add edi, 4
            dec ecx
        .endw
        mov ecx, [edi]
        cmp ecx, -1                 ; if top is -1, leave
        je leaveSwap
        mov temp3, ecx
    .else                       ;*****SOURCE = SUIT_N*****
        ;logic for suit
        mov ecx, temp1
        sub ecx, 8                ; this should be our suit index
        mov edx, offset suits
        mov edx, [edx+ecx*4]	;&SUIT_N
        mov edi, offset suitsTops
        mov ecx, temp1
        .while ecx > 0
            add edi, 4
            dec ecx
        .endw
        mov ecx, [edi]			;ecx = the index of the top of SUIT_N
		cmp ecx, -1                 ; if top is -1, leave
        je leaveSwap
        mov temp3, ecx
    .endif
	
    .if temp2 > 0 && temp2 < 8
        ;logic for pile
        mov ecx, temp2
        dec ecx                 ; this should be our pile index
        mov edx, offset piles
        mov edx, [edx+ecx*4]
        mov edi, offset pilesTops
        mov ecx, temp2
        .while ecx > 0
            add edi, 4
            dec ecx
        .endw
        mov eax, [edi]
        mov ecx, [edx+eax]
        ;mov eax, [edi]
        
		cmp ecx, -1                 ; if top is -1, leave
        je leaveSwap
        mov temp4, ecx
        mov ebx, 1
    .else
        ;logic for suit
        mov ecx, temp2
        sub ecx, 8                ; this should be our suit index
        mov edx, offset suits
        mov edx, [edx+ecx*4]
        mov edi, offset suitsTops
        mov ecx, temp2
        .while ecx > 0
            add edi, 4
            dec ecx
        .endw
        mov ecx, [edi]
		cmp ecx, -1                 ; if top is -1, leave
        je leaveSwap
        mov temp4, ecx
        mov ebx, 2
    .endif
    
	.if ebx == 1
    mov eax, temp3
    mov ecx, temp4
    call checkRankPile
    
    ;take from source, put in dest
    ;take from source, put in dest
    .endif
	mov ecx, temp4
    mov eax, temp3

    ;TODO filter by destination to determine whether to perform a take from source then put to destination
    ;call checkRankSuit

    call checkWinCondition
        ;display "win"
    leaveSwap:
        ret
swap ENDP
;End of code by Merrick

;Beginning of code by Larz & Adam
;---------------------------------------------------------
;checkWinCondition - Checks if the game is finished by summing the top of each suit pile.
;   If each suit contains all of its respective cards, the tops will all be 12. 12 * 4 = 48
;Returns: 
;   eax = 1 if win condition is met, 0 if win condition is not met
;---------------------------------------------------------
checkWinCondition PROC uses edx ecx
    mov edx, OFFSET suitsTops
    mov eax, 0
    mov ecx, 4
    checkNextSuit:
        add eax, [edx]  ;max possible value is 48 (12 is max index * 4 suit stacks)
        add edx, 4  ;go to next suit
    loop CheckNextSuit
    cmp eax, 48
    jne gameNotWon
    mov eax, 1
    ret
    gameNotWon:
        mov eax, 0
    ret
checkWinCondition ENDP
;End of code by Larz & Adam

;Beginning of code by Florida & Yadhu
;---------------------------------------------------------
;showBoard - Displays all stacks YADHU, FLORIDA
;---------------------------------------------------------
showBoard PROC
    call displayDeckAndDraw
    call displayPiles
    call displaysuits
    ret
showBoard ENDP
;End of code by Florida & Yadhu

;Beginning of code by Nikane
main PROC
    call randomize                  ;seed RNG
    call newGame                    ;initialize the board
    call showboard                  ;display the board
    getInput:                       ;main game loop
        call await
    jmp getInput

    call exitprocess
main ENDP
END main
;End of code by Nikane