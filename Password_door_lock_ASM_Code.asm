      E BIT P3.5          ;SET P3.5 AS ENABLE PIN
      RW BIT P3.6         ;SET P3.6 AS READ/WRITE PIN
      RS  BIT P3.7         ;SET P3.7 AS REGISTER SELECT PIN
  
   ORG 0000H 
   CLR P0.0
  
   MAIN:  ACALL LCD_COMMANDS              ; CALL LCD_COMMANDS SUBROUTINE
          ACALL READ_KEY                  ; CALL READ KEY SUBROUTINE
          MOV DPTR,#CHECK_CODE_MESG    
          ACALL DISPLAY_LCD_MESG          ;CALL DISPLAY_LCD_MESSAGE FOR LCD DISPLAY
          ACALL DELAY1                   ;CALL TIME DELAY1
          ACALL CHECK_CODE              ; CALL CHECK_CODE SUBROUTINE TO CHECK INPUT CODE
          SJMP MAIN
 
   EXIT:RET          

   CLRSCR: MOV A,#01H
           ACALL CMD_WRITE      ;CALL CMD_WRITE SUBROUTINE
           MOV A,#06H
           ACALL CMD_WRITE      ;CALL CMD_WRITE SUBROUTINE
           RET
		   
   LINE2: MOV A,#0C0H
	       ACALL CMD_WRITE       ;CALL CMD_WRITE SUBROUTINE
	       RET

   CMD_WRITE:MOV P1,A
             CLR RS               ;CLEAR RS PIN
             CLR RW                ;CLEAR RW PIN FOR TAKING COMMAND
             SETB E
			 ACALL DELAY3
             CLR E                 ;H TO L PULSE TO ENABLE
             RET
			 
   DATA_WRITE:MOV P1,A
              SETB RS            ;SET RS PIN FOR DATA WRITING
              CLR RW             ;CLEAR RW PIN FOR TAKING COMMAND
              SETB E
			  ACALL DELAY3
              CLR E
              RET	              ;H TO L PULSE TO ENABLE
			 
			 
	DISPLAY_LCD_MESG: CLR A                ;CLEAR ACCUMULATOR
                      MOVC A,@A+DPTR       ;MOV DPTR VALUE TO A
                      JZ EXIT
                      ACALL DATA_WRITE        ;CALL DATA_WRITE SUBROUTINE
		              INC DPTR                ; INCREASE VALUE OF DPTR BY 1(TO NEXT MEMORY LOCATION)
                      SJMP DISPLAY_LCD_MESG


   DELAY1:  MOV R3,#06              ;DELAY1 SUBROUTINE 
      HERE1:MOV R4,#255
      HERE2:MOV R5,#255
      HERE3:DJNZ R5,HERE3
		    DJNZ R4,HERE2
		    DJNZ R3,HERE1
		 RET
			
       
     DELAY2:  MOV R3,#20            ;DELAY2 SUBROUTINE
        HERE4:MOV R4,#200
        HERE5:MOV R5,#200
        HERE6:DJNZ R5,HERE6
		      DJNZ R4,HERE5
		      DJNZ R3,HERE4
		  RET
			  
			  
     DELAY3:  MOV R3,#50             ;DELAY3 SUBROUTINE
        HERE7:MOV R4,#200
        HERE8:DJNZ R4,HERE8
              DJNZ R3,HERE7
          RET



        READ_KEY:   MOV DPTR,#INITIAL_MSG
					CLR P0.0
                    ACALL DISPLAY_LCD_MESG       ;CALL DISPLAY_LCD_MESSAGE FOR LCD DISPLAY
			        ACALL DELAY1                 ;CALL TIME DELAY1
			        ACALL LINE2
                    MOV R0,#5
                    MOV R1,#40H
             ROTATE:ACALL KEY_SCAN
		            ACALL DATA_WRITE
			        ACALL DELAY1
                    MOV @R1,A   ; 40h=1 41h=4 42h=7 43h=6 44h=9
                    INC R1   ;r1=41h
                    DJNZ R0,ROTATE
					
					ACALL CLRSCR
					ACALL DELAY1
               RET



    CHECK_CODE: MOV R0,#5
                    MOV R1,#40H
                    MOV DPTR,#CORRECT_CODE
					
             AGAIN: CLR A
                    MOVC A,@A+DPTR
                    XRL A,@R1;   
					JNZ FAIL
                    INC R1
                    INC DPTR 
                    DJNZ R0,AGAIN
                    ACALL CLRSCR
                    MOV DPTR,#SUCCESS_MESG1
                    ACALL DISPLAY_LCD_MESG
                    ACALL DELAY1
					ACALL LINE2
					MOV DPTR,#SUCCESS_MESG2
					ACALL DISPLAY_LCD_MESG
                    ACALL DELAY1
					
               SETB P0.0
			   ACALL DELAY2
                  LJMP EXIT
			 
          FAIL:ACALL CLRSCR 
               MOV DPTR,#FAIL_MESG1
               ACALL DISPLAY_LCD_MESG
               ACALL DELAY1
			   ACALL LINE2
			   MOV DPTR,#FAIL_MESG2
			   ACALL DISPLAY_LCD_MESG
               ACALL DELAY1
              
		     CLR P0.0
		     ACALL DELAY2
			    LJMP EXIT

     KEY_SCAN:   MOV P2,#0FFH
                 CLR P2.4 
                 JB P2.0, NEXT1 
                 MOV A,#49D
               RET

           NEXT1:JB P2.1,NEXT2
                 MOV A,#50D
               RET

           NEXT2: JB P2.2,NEXT3
                  MOV A,#51D
               RET

           NEXT3:SETB P2.4
                 CLR P2.5
                 JB P2.0, NEXT4
                 MOV A,#52D
                 RET

           NEXT4:JB P2.1,NEXT5
                 MOV A,#53D
                 RET

           NEXT5:JB P2.2,NEXT6
                 MOV A,#54D
                 RET

           NEXT6:SETB P2.5
                 CLR P2.6
                 JB P2.0, NEXT7
                 MOV A,#55D
                 RET

            NEXT7:JB P2.1,NEXT8
                 MOV A,#56D
                 RET

             NEXT8:JB P2.2,NEXT9
                  MOV A,#57D
                  RET
			 
            NEXT9:SETB P2.6
                  CLR P2.7
                  JB P2.0, NEXT10
                  MOV A,#42D
                  RET

            NEXT10:JB P2.1,NEXT11
                   MOV A,#48D
                   RET

            NEXT11:JB P2.2,NEXT12
                   MOV A,#35D
                   RET	  

           NEXT12:LJMP KEY_SCAN
		   

   
   INITIAL_MSG:   DB "ENTER 5-DIG.CODE",0
   CHECK_CODE_MESG:  DB "CODE CHECKING.....",0
   SUCCESS_MESG1:   DB "ACCESS ALLOWED",0
   SUCCESS_MESG2:   DB "OPENING DOOR" ,0
   FAIL_MESG1:   DB "WRONG CODE",0
   FAIL_MESG2:   DB "DOOR CLOSED",0

   CORRECT_CODE:DB 56D,53D,55D,56D,56D,0
	
	
	LCD_COMMANDS:MOV A,#38H             ; 2 LINES AND 5X7 MATRIX
                 ACALL CMD_WRITE        ;CALL CMD_WRITE SUBROUTINE
                 ACALL DELAY3
			  
                 MOV A,#3CH             ;ACTIVATE 2ND LINE OF LCd
                 ACALL CMD_WRITE        ;CALL CMD_WRITE SUBROUTINE
                 ACALL DELAY3
			  
                 MOV A,#0EH              ; LCD ON CURSOR BLINKING
                 ACALL CMD_WRITE          ;CALL CMD_WRITE SUBROUTINE
                 ACALL DELAY3
			  
                 MOV A,#01H              ; CLEAR SCREEN
                 ACALL CMD_WRITE         ;CALL CMD_WRITE SUBROUTINE
                 ACALL DELAY3
			  
                 MOV A,#06H              ; 
                 ACALL CMD_WRITE         ;CALL CMD_WRITE SUBROUTINE
                 ACALL DELAY3
			  
              RET
			  
  END
