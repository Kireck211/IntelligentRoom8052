;/*PROYECTO FINAL
; *FUNDAMENTOS DE MICROPROCESADORES
; *
; *AUTOMATIZACIÓN DE CASAS, DOMÓTICA CON MICROCONTROLADOR AT89S52
; *
; *LUIS ALBERTO ANTÓN DELGADILLO
; *ERICK DE SANTIAGO ANAYA
; */

////////    VARIABLES        ////////////////////////////////////////////////////////////////////////////////////////////////////////

/* DIRECCIONES PARA LA CONFIGURACION DEL TIMER 2 */
T2CON EQU 0C8H
TH2 EQU 0CDH
TL2 EQU 0CCH
RCAP2L EQU 0CAH
RCAP2H EQU 0CBH
T2CON_7 EQU 0CFH
        
/* Variables para conteo de TIEMPO */
T2Iterator EQU 30H
HOR1 EQU 31H
HOR0 EQU 32H
MIN1 EQU 33H
MIN0 EQU 34H
SEC1 EQU 35H
SEC0 EQU 36H                        ;EL TIMER 2 CUENTA EN REALIDAD CADA DOS SEGUNDOS, POR LO QUE "SEC" AUMENTA DE DOS EN DOS

/* Recarga R1 */
REC_R1 EQU 40H
    
/* Contador R2 */
;VAR_R2 EQU 37H
    
/* Variables para LCD */
lcdP  EQU P1
lcdRS EQU P3.6
lcdE  EQU P3.7
    
/* Variables para luces */
LED EQU 37H
LP EQU P0

/* Variables PWM */
PWM0 EQU P3.2
PWM1 EQU P3.3
PWMT EQU 38H
    
/* Variables Motor */
EOUT EQU P3.4
    
/* Variables Temperatura */
TEMP_IN EQU P2
TEMP0 EQU 39H
TEMP1 EQU 3AH

/* SCRATCH PAD */
SP_ONE EQU 20H
    /* 7bit ;ENGINE 
     * 6bit NU
     * 5bit NU
     * 4bit NU
     * 3bit ;FRECUENCIA PWM
     * 2bit ;Bandera para indicar PWM
     * 1bit ;Bandera para Intensidad de Luz
     * 0bit ;Bandera para Nemonic State Machine
     */
     
SP_LED EQU 21H
    /* 7bit NU
     * 6bit NU
     * 5bit NU
     * 4bit ;LED4
     * 3bit ;LED3
     * 2bit ;LED2
     * 1bit ;LED1
     * 0bit ;LED0
     */
     
SP_FLAG_LED EQU 22H
    /* 7bit NU
     * 6bit NU
     * 5bit NU
     * 4bit ;Bandera LED4
     * 3bit ;Bandera LED3
     * 2bit ;Bandero LED2
     * 1bit ;Bandera LED1
     * 0bit ;Bandera LED0
     */
     
SP_FLAG_PWM EQU 23H
    /* 7bit NU
     * 6bit NU
     * 5bit NU
     * 4bit ;Bandera LED4 PWM
     * 3bit ;Bandera LED3 PWM
     * 2bit ;Bandero LED2 PWM
     * 1bit ;Bandera LED1 PWM
     * 0bit ;Bandera LED0 PWM
     */

PWM_TEMP EQU 24H
    /* 7bit NU
     * 6bit NU
     * 5bit NU
     * 4bit ;LED4
     * 3bit ;LED3
     * 2bit ;LED2
     * 1bit ;LED1
     * 0bit ;LED0
     */

////////    ORIGIN            ////////////////////////////////////////////////////////////////////////////////////////////////////////

/* Init */
ORG 00H
LJMP INIT

/* Serial Int */
ORG 23H
LJMP RxINT

/* Timer 2 Int */
ORG 2BH
CLR T2CON_7
LJMP TIM2

////////    INIT            ////////////////////////////////////////////////////////////////////////////////////////////////////////

ORG 40H
INIT:
    
/*** ININICIALIZAR REGISTROS */
    MOV R0, #00H                ;Used / Timer 2
    MOV R1, #00H                ;Used / Nemonics
    MOV R2, #00H                ;Used / Timer 0 LCD
    MOV R3, #00H
    MOV R4, #00H
    MOV R5, #00H
    MOV R6, #00H
    MOV R7, #00H
    
/*** INICIALIZAR MEMORIA */
    MOV REC_R1, #00H
    ;MOV VAR_R2, #00H
    MOV T2Iterator, #00H
    MOV HOR1, #00H
    MOV HOR0, #00H
    MOV MIN1, #00H
    MOV MIN0, #00H
    MOV SEC1, #00H
    MOV SEC0, #00H
    MOV LED, #0FFH                        ;PRENDE EN CEROS LOS LEDS
    MOV PWMT, #00H
    MOV TEMP0, #00H
    MOV TEMP1, #00H
    
/*** INICIALIZAR SCRATCH PAD */
    MOV SP_ONE, #00H
    MOV SP_LED, #00H
    MOV SP_FLAG_LED, #00H
    MOV PWM_TEMP, #00H
    
/*** VALORES INICIALES PARA:
    * - HABILITAR INTERRUPCIONES (TIMER 2, 1, 0 Y INT0, INT1)
    * - PRIORIDAD DE INTERRUPCIONES
    * - VALORES INICIALES DE CONTROL
    * - MODO DE AUTORECARGA TIMER1, MODO 16 BITS TIMER 1
    */
    MOV IE, #10110010B                ;Pag. 133
    MOV IP, #00100000B                ;Pag. 134
    MOV TCON, #00H                    ;Pag. 90
    MOV TMOD, #00100010B            ;Pag. 89
    MOV TH1, #-3                    ;9600 Baud-rate
    MOV SCON, #01010000B            ;Pag. 113
    SETB TR1                        ;Timer 1 Run
    
    
    
    
    
    
    /*********** COMENTARIO AQUI *****/
    MOV DPTR ,#1000H
    
    
    /****** COMENTARIO AQUI *****/

/*** VALORES INICIALES PARA TIMER 2 CON AUTORECARGA */
    MOV RCAP2H, #HIGH(-36864)
    MOV RCAP2L, #LOW(-36864)
    MOV TH2, #HIGH(-36864)
    MOV TL2, #LOW(-36864)
    MOV T2CON, #00000100B
    
/*** Asignar Iterador Timer 2 */
    MOV T2Iterator, #00H
    MOV R0, #T2Iterator
    
/*** Iniciar R1 para Nemónicos */
    MOV R1, #REC_R1

/*** VALORES PARA TIMER 0 CUENTA DE LCD */
    MOV TH0, #-128D
    MOV TL0, #-128D

/*** INICIALIZAR LCD */
    CLR ET0
    LCALL initialization
    SETB ET0
    

MAIN: 
    LCALL NEM_SM                    ;Manda llamar la máquina de estados que descifrará el nemónico entrante del usuario, PROTOCOLO DE TRANSMISIÓN
    LCALL LIGHTHANDLER                ;Manda llamar la subrutina de encendido de luces
    LCALL TIMEHANDLER                ;Manda llamar subrutina de control del tiempo
    LCALL ENGINEHANDLER                ;Manda llamar subrutina para mandar bandera de encendido del motor al segundo microcontrolador
    LCALL TEMPHANDLER                ;Manda llamar subrutina de impresión en LCD de Temperatura
    SJMP MAIN

////////    SUBROUTINES        ////////////////////////////////////////////////////////////////////////////////////////////////////////

/***    HANDLERS    ********/

/*** LightHandler */
LIGHTHANDLER:
    
    MOV SP_LED, LED
    JNB SP_ONE.1, LH_ON_OFF_STATE
    
    
    
    ;JNB SP_LED.0, LH_NEXT0
    JNB SP_FLAG_PWM.0, LH_NEXT0
    JB SP_FLAG_LED.0, LED0_NEXT
    MOV C, PWM0
    MOV SP_LED.0, C
    JMP LH_NEXT0
    LED0_NEXT:
        MOV C, PWM1
        MOV SP_LED.0, C
    LH_NEXT0: 
        ;JNB SP_LED.1, LH_NEXT1
        JNB SP_FLAG_PWM.1, LH_NEXT1
        JB SP_FLAG_LED.1, LED1_NEXT
        MOV C, PWM0
        MOV SP_LED.1, C
        JMP LH_NEXT1
        LED1_NEXT:
            MOV C, PWM1
            MOV SP_LED.1, C
    LH_NEXT1:
        ;JNB SP_LED.2, LH_NEXT2
        JNB SP_FLAG_PWM.2, LH_NEXT2
        JB SP_FLAG_LED.2, LED2_NEXT
        MOV C, PWM0
        MOV SP_LED.2, C
        JMP LH_NEXT2
        LED2_NEXT:
            MOV C, PWM1
            MOV SP_LED.2, C
    LH_NEXT2:
        ;JNB SP_LED.3, LH_NEXT3
        JNB SP_FLAG_PWM.3, LH_NEXT3
        JB SP_FLAG_LED.3, LED3_NEXT
        MOV C, PWM0
        MOV SP_LED.3, C
        JMP LH_NEXT3
        LED3_NEXT:
            MOV C, PWM1
            MOV SP_LED.3, C
    LH_NEXT3:
        ;JNB SP_LED.4, LH_NEXT4
        JNB SP_FLAG_PWM.4 , LH_ON_OFF_STATE
        JB SP_FLAG_LED.4, LED4_NEXT
        MOV C, PWM0
        MOV SP_LED.4, C
        JMP LH_ON_OFF_STATE
        LED4_NEXT:
            MOV C, PWM1
            MOV SP_LED.4, C
            
            
            
            
    LH_ON_OFF_STATE:
    MOV LED, SP_LED
    MOV LP, LED
    //TODO: Impimir en LCD: LUCES: 1 0 1 1 0    donde los "0" y "1" son apagado y prendido de las 5 luces contempladas
    
    MOV A, #0C0H                    ;MUEVE CURSOS A SEGUNDA LÍNEA DEL LCD
    LCALL command
    MOV A, #4CH                        ;IMPRIMIR LCD "L"
    LCALL dat
    MOV A, #55H                        ;IMPRIMIR LCD "U"
    LCALL dat
    MOV A, #43H                        ;IMPRIMIR LCD "C"
    LCALL dat
    MOV A, #45H                        ;IMPRIMIR LCD "E"
    LCALL dat
    MOV A, #53H                        ;IMPRIMIR LCD "S"
    LCALL dat
    MOV A, #3AH                        ;IMPRIMIR LCD ":"
    LCALL dat
    MOV A, #20H                        ;IMPRIMIR " "
    LCALL dat
    
    //TODO: CONDICIONAR PARA IMPRIMIR LUCES PRENDIDAS O APAGADAS
    JB SP_FLAG_LED.0, LUZ1_ON
    MOV A, #01H                        ;MUEVE SÍMBOLO LUZ APAGADA
    LCALL dat
    JMP LUZ1_PRINT
    LUZ1_ON:
    MOV A, #00H                        ;MUEVE SÍMBOLO LUZ PRENDIDA
    LCALL dat
    LUZ1_PRINT:
    MOV A, #20H                        ;IMPRIMIR " "
    LCALL dat
    
    
    JB SP_FLAG_LED.1, LUZ2_ON
    MOV A, #01H                        ;MUEVE SÍMBOLO LUZ APAGADA
    LCALL dat
    JMP LUZ2_PRINT
    LUZ2_ON:
    MOV A, #00H                        ;MUEVE SÍMBOLO LUZ PRENDIDA
    LCALL dat
    LUZ2_PRINT:
    MOV A, #20H                        ;IMPRIMIR " "
    LCALL dat
    
    JB SP_FLAG_LED.2, LUZ3_ON
    MOV A, #01H                        ;MUEVE SÍMBOLO LUZ APAGADA
    LCALL dat
    JMP LUZ3_PRINT
    LUZ3_ON:
    MOV A, #00H                        ;MUEVE SÍMBOLO LUZ PRENDIDA
    LCALL dat
    LUZ3_PRINT:
    MOV A, #20H                        ;IMPRIMIR " "
    LCALL dat
    
    JB SP_FLAG_LED.3, LUZ4_ON
    MOV A, #01H                        ;MUEVE SÍMBOLO LUZ APAGADA
    LCALL dat
    JMP LUZ4_PRINT
    LUZ4_ON:
    MOV A, #00H                        ;MUEVE SÍMBOLO LUZ PRENDIDA
    LCALL dat
    LUZ4_PRINT:
    MOV A, #20H                        ;IMPRIMIR " "
    LCALL dat
    
    JB SP_FLAG_LED.4, LUZ5_ON
    MOV A, #01H                        ;MUEVE SÍMBOLO LUZ APAGADA
    LCALL dat
    JMP LUZ5_PRINT
    LUZ5_ON:
    MOV A, #00H                        ;MUEVE SÍMBOLO LUZ PRENDIDA
    LCALL dat
    LUZ5_PRINT:
    
    MOV A, #80H                        ;REGRESA CURSOR A PRIMER LÍNEA
    LCALL command
    
    RET

/*** EngineHandler */
ENGINEHANDLER:
    MOV C, SP_ONE.7
    MOV EOUT, C
    RET

/*** TempHandler */
TEMPHANDLER:
    
    //TOMAR PARTE ALTA Y SUMARLE 30, TOMAR PARTE BAJA Y SUMARLE 30, DESPUES MANDAR CADA UNO COMO DECENA Y UNIDAD
    MOV A, TEMP_IN
    LCALL BIN_HEX
    MOV R3, A
    ANL A, #0FH
    ADD A, #30H
    MOV TEMP0, A
    MOV A, R3
    ANL A, #0F0H
    SWAP A
    ADD A, #30H
    MOV TEMP1, A
    
    /* IMPRIMIR EN LCD LA TEMPERATURA */
    MOV A, #8CH
    LCALL command
    
    MOV A, TEMP1
    LCALL dat
    MOV A, TEMP0
    LCALL dat
    MOV A, #2AH
    LCALL dat
    MOV A, #43H
    LCALL dat
    
    RET

/*** TimeHandler */
TIMEHANDLER:
    //MOV AAUX, A
    MOV A, #10D
    CJNE A, SEC0, COMPARA_SEC1
    MOV SEC0, #0D
    INC SEC1
    
    COMPARA_SEC1: 
        MOV A, #06D
        CJNE A, SEC1, COMPARA_MIN0
        MOV SEC1, #0D
        INC MIN0
        
    COMPARA_MIN0: 
        MOV A, #10D
        CJNE A, MIN0, THRET
        MOV MIN0, #0D
        INC MIN1
        
        MOV A, #06D
        CJNE A, MIN1, THRET
        MOV MIN1, #0D
        INC HOR0
        
        MOV A, #10D
        CJNE A, HOR0, LBHOR0
        MOV HOR0, #0D
        INC HOR1
    
    LBHOR0:
        MOV A, #02D
        CJNE A, HOR1, THRET
        MOV A, #04D
        CJNE A, HOR0, THRET
    REINICIA_RELOJ: 
        MOV SEC0, #0D
        MOV SEC1, #0D
        MOV MIN0, #0D
        MOV MIN1, #0D
        MOV HOR0, #0D
        MOV HOR1, #0D
        
    ;THRET: RET
    THRET:
        /* MOSTRAR EN LCD LA HORA */
        MOV A, #80H
        LCALL command
        
        MOV A, HOR1                    ;MOVER AL acc VALOR ACTUAL DE LA HORA
        ADD A, #30H                    ;AÑADIR VALOR PARA COMPLETAR ASCII
        LCALL dat                    
        MOV A, HOR0
        ADD A, #30H
        LCALL dat
        MOV A, #3AH                    ;AÑADIR DOS PUNTOS PARA SEPARACIÓN DE LA HORA
        LCALL dat
        MOV A, MIN1
        ADD A, #30H
        LCALL dat
        MOV A, MIN0
        ADD A, #30H
        LCALL dat
        MOV A, #3AH
        LCALL dat
        //TODO: QUITAR SEGUNDOS DEL LCD
        MOV A, SEC1
        ADD A, #30H
        LCALL dat
        MOV A, SEC0
        ADD A, #30H
        LCALL dat
        
        RET

/*** SerialHandler */
SERIALHANDLER:
    ;JB SP_ONE.0, OUT_SH
    HERE: JNB RI, HERE
    MOV A, SBUF                        ;Guarda byte entrante en acc
    MOV @R1, A                        ;Guarda byte más significativo del nemónico
    CJNE @R1, #23H, OUT_SH
    SETB SP_ONE.0                    ;Bandera que inicia Nemonic State Machine
    OUT_SH:
    INC R1
    CLR RI
    RET
    
/****************************/
    
/*** Nemonic State Machine */
NEM_SM:
;TODO: TRABAJAR CON EL NEMÓNICO ENTRANTE Y DISTRIBUIRLO
    JNB SP_ONE.0, MID_ERROR
    MOV R1, #REC_R1
    
    STATE_1:
    ;(L)??
        CJNE @R1, #4CH, STATE_2
        INC R1
        STATE_4:
        ;L(E)#
            CJNE @R1, #45H, STATE_5
            CLR SP_ONE.1            ;LIMPIAR BANDERA DE INTENSIDAD DE LUCES
            INC R1
            ;LE(#)
            ;PROGRAMA EN JAVA TIENE QUE MANDAR UN BYTE EN HEXADECIMAL QUE SE SACARÁ POR EL PUERTO ASIGNADO A LAS LUCES
            MOV LED, @R1
            MOV A, LED
            CPL A                            ;COMPLEMENTO DE LA SALIDA PARA PRENDER CON CEROS
            MOV LED, A
            
            MOV R1, #REC_R1
            CLR SP_ONE.0
            JMP ERROR
        STATE_5:
        ;L(I)##
            CJNE @R1, #49H, MID_ERROR
            INC R1
            ;LI(#)#
            MOV PWM_TEMP, @R1
            INC R1
            ;LI#(#)
            MOV A, @R1
            CJNE A, #31H, S5_NEXT
                JNB PWM_TEMP.0, S5_0_LED1
                SETB SP_FLAG_PWM.0
                CLR SP_FLAG_LED.0
                S5_0_LED1:
                JNB PWM_TEMP.1, S5_0_LED2
                SETB SP_FLAG_PWM.1
                CLR SP_FLAG_LED.1
                S5_0_LED2:
                JNB PWM_TEMP.2, S5_0_LED3
                SETB SP_FLAG_PWM.2
                CLR SP_FLAG_LED.2
                S5_0_LED3:
                JNB PWM_TEMP.3, S5_0_LED4
                SETB SP_FLAG_PWM.3
                CLR SP_FLAG_LED.3
                S5_0_LED4:
                JNB PWM_TEMP.4, S5_END
                SETB SP_FLAG_PWM.4
                CLR SP_FLAG_LED.4
                JMP S5_END
            S5_NEXT:
                JNB PWM_TEMP.0, S5_1_LED1
                SETB SP_FLAG_PWM.0
                SETB SP_FLAG_LED.0
                S5_1_LED1:
                JNB PWM_TEMP.1, S5_1_LED2
                SETB SP_FLAG_PWM.1
                SETB SP_FLAG_LED.1
                S5_1_LED2:
                JNB PWM_TEMP.2, S5_1_LED3
                SETB SP_FLAG_PWM.2
                SETB SP_FLAG_LED.2
                S5_1_LED3:
                JNB PWM_TEMP.3, S5_1_LED4
                SETB SP_FLAG_PWM.3
                SETB SP_FLAG_LED.3
                S5_1_LED4:
                JNB PWM_TEMP.4, S5_END
                SETB SP_FLAG_PWM.4
                SETB SP_FLAG_LED.4
            S5_END:
            SETB SP_ONE.1            ;INICIAR BANDERA DE INTENSIDAD DE LUCES
            MOV A, PWM_TEMP
            CPL A
            MOV PWM_TEMP, A
            MOV LED, PWM_TEMP
            
            MOV R1, #REC_R1
            CLR SP_ONE.0
            MID_ERROR: JMP ERROR
    STATE_2:
    ;(E)#
        CJNE @R1, #45H, STATE_3
        INC R1
        ;E(#)
        MOV A, @R1
        CJNE A, #30H, S2_NEXT        ;DEBE DE LLEGAR UN "0" EN ASCII
        CLR SP_ONE.7
        JMP S2_END
        S2_NEXT:
        SETB SP_ONE.7
        
        S2_END:
        MOV R1, #REC_R1
        CLR SP_ONE.0
        JMP ERROR
    STATE_3:
    ;(C)nnnn#
        CJNE @R1, #43H, ERROR
        INC R1
        ;C(n)nnn#
        MOV A, @R1
        SUBB A, #30H
        MOV @R1, A
        MOV HOR1, @R1
        INC R1
        ;Cn(n)nn#
        MOV A, @R1
        ;LCALL HEX_BIN
        SUBB A, #30H
        MOV @R1, A
        MOV HOR0, @R1
        INC R1
        ;Cnn(n)n#
        MOV A, @R1
        ;LCALL HEX_BIN
        SUBB A, #30H
        MOV @R1, A
        MOV MIN1, @R1
        INC R1
        ;Cnnn(n)#
        MOV A, @R1
        ;LCALL HEX_BIN
        SUBB A, #30H
        MOV @R1, A
        MOV MIN0, @R1
        
        MOV R1, #REC_R1
        CLR SP_ONE.0
        
    ERROR: RET

/*** LCD */
    initialization:
        MOV A, #38H ; Initialize, 2-lines, 5X7 matrix.
        LCALL Command
        MOV A, #38H ; Initialize, 2-lines, 5X7 matrix.
        LCALL Command
        MOV A, #38H ; Initialize, 2-lines, 5X7 matrix.
        LCALL Command
        
        //TODO: GENERAR FIGURAS LEDS DE ERICK
        MOV A, #40H
        LCALL command
        MOV A, #0EEH
        LCALL dat
        MOV A, #0F1H
        LCALL dat
        MOV A, #0F1H
        LCALL dat
        MOV A, #0F1H
        LCALL dat
        MOV A, #0F1H
        LCALL dat
        MOV A, #0F1H
        LCALL dat
        MOV A, #0EEH
        LCALL dat
        MOV A, #0EEH
        LCALL dat
        MOV A, #0EEH
        LCALL dat
        MOV A, #0FFH
        LCALL dat
        MOV A, #0FFH
        LCALL dat
        MOV A, #0FFH
        LCALL dat
        MOV A, #0FFH
        LCALL dat
        MOV A, #0FFH
        LCALL dat
        MOV A, #0EEH
        LCALL dat
        MOV A, #0EEH
        LCALL dat
        
        MOV A, #01H ; Clear LCD Screen
        LCALL Command
        MOV A, #0CH ; LCD on, cursor on
        LCALL Command
        RET
    ready:
        SETB TR0
        JNB TF0, $
        INC R2
        CLR TF0
        CJNE R2, #108D, ready
        MOV R2, #00H
        CLR TR0
        RET
    dat:
        CLR ET0
        MOV lcdP, A ;move acc. dat to port
        SETB lcdRS ;RS=1 dat
        SETB lcdE ;H->L pulse on E
        CLR lcdE
        LCALL ready
        SETB ET0
        RET
    Command:
        CLR ET0
        MOV lcdP, A ;move acc. dat to port
        CLR lcdRS ;RS=0 for cmd
        SETB lcdE ;H->L pulse on E
        CLR lcdE
        LCALL ready
        SETB ET0
        RET
    clear:
        SETB lcdE ;enable EN
        CLR lcdRS ;RS=0 for cmd.
        MOV A,#01h
        CLR lcdE ;disable EN
        LCALL ready
        RET


/**** COMENTARIO AQUI **/

BIN_HEX: MOVC A, @A + DPTR
    RET

////////    INTERRUPTIONS    ////////////////////////////////////////////////////////////////////////////////////////////////////////

/* Timer 2 para el conteo de dos segundos */
TIM2: 
//TODO: CALCULAR SEGUNDO CON RELOJ DE 11.0592 MHZ
    INC T2Iterator
    CJNE @R0, #25D, OUT
    INC SEC0                        ;Incrementa primer segundo
    ;INC SEC0                        ;Incrementa segundo segundo
    MOV T2Iterator, #00H
    ;LCALL TIMEHANDLER

    OUT: RETI
    
/* Interrupción Serial (SERIALHANDLER) */
RxINT:
    CLR P3.1                        ;PRUEBA SERIAL, BORRAR AL FINAL
    LCALL SERIALHANDLER
    RETI

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* LOOK UP TABLE */
ORG 1000H
DB 00H
DB 01H
DB 02H
DB 03H
DB 04H
DB 05H
DB 06H
DB 07H
DB 08H
DB 09H
DB 10H
DB 11H
DB 12H
DB 13H
DB 14H
DB 15H
DB 16H
DB 17H
DB 18H
DB 19H
DB 20H
DB 21H
DB 22H
DB 23H
DB 24H
DB 25H
DB 26H
DB 27H
DB 28H
DB 29H
DB 30H
DB 31H
DB 32H
DB 33H
DB 34H
DB 35H
DB 36H
DB 37H
DB 38H
DB 39H
DB 40H
DB 41H
DB 42H
DB 43H
DB 44H
DB 45H
DB 46H
DB 47H
DB 48H
DB 49H
DB 50H
DB 51H
DB 52H
DB 53H
DB 54H
DB 55H
DB 56H
DB 57H
DB 58H
DB 59H
DB 60H



END
