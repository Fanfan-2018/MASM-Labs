INCLUDE Irvine32.inc
INCLUDE macros.inc

BufferSize = 200

.data
Buffer      BYTE    BufferSize DUP(?)
StdInHandle HANDLE  ?
OperatorStack    BYTE    BufferSize DUP(?)
OperatorStackBase   DD      ?
BytesRead   DWORD 	?
Plus        DB      "+", 0
Minus       DB      "-", 0
LeftComma   DB      "(", 0
RightComma  DB      ")", 0

.code
main PROC
	INVOKE GetStdHandle, STD_INPUT_HANDLE 		; ��ȡ��׼������
	MOV	StdInHandle, eax
	INVOKE ReadConsole,                         ; �ӿ���̨����
		StdInHandle,
		ADDR Buffer,                            ; Buffer <- String
	  	BufferSize,
		ADDR BytesRead,
		0
	MOV ecx, BytesRead                          ; �����ܴ���
    SUB ecx, 2                                  ; ע�����������ַ�
	MOV al, 0                                   ; 0 <- Character | 1 <- Number
	MOV ah, 0                                   ; 0 <- Minus | 1 <- Negative
	MOV bl, 0                                   ; 0 <- Positive | 1 <- Negative
	MOV edi, OFFSET OperatorStack
	MOV esi, OFFSET OperatorStackBase
	MOV [esi], edi
	MOV esi, OFFSET Buffer

	.WHILE (ecx > 0)
		MOV bh, BYTE PTR [esi]
		.IF (bh == Minus)                       ; ��ǰ�ַ� '-'
			.IF (ah == 0)                       ; ����
				.IF (al == 1 && bl == 1)        ; �����֣��Ǹ���
					MOV edx, eax
					POP eax
					NEG eax                     ; ȡ��
					PUSH eax
					MOV eax, edx
				.ENDIF
				MOV edx, OFFSET OperatorStackBase
				MOV edx, [edx]
				.IF (edx != edi)                ; ջ��������ջ��
                    MOV dl, [edi]               ; dl <- ջ��
					.IF (dl == Plus)
						POP edx
						ADD [esp], edx          ; �������֣���ջ
						DEC edi                 ; ջ��ָ������
					.ELSEIF (dl == Minus)
						POP edx
						SUB [esp], edx          ; �������֣���ջ
						DEC edi                 ; ջ��ָ������
					.ENDIF
				.ENDIF
				inc edi                         ; ������ջ
				MOV [edi], BYTE PTR 2DH         ; '-'
                MOV al, 0                       ; Character
				MOV ah, 1                       ; Minus
				MOV bl, 0                       ; Positive
			.ELSE                               ; ����
				MOV al, 0                       ; Character
                MOV ah, 0                       ; Negative
                MOV bl, 1                       ; Negative
			.ENDIF
		.ELSEIF (bh == Plus)                    ; ��ǰ�ַ� '+'
			.IF (al == 1 && bl == 1)            ; �����֣��Ǹ���
				MOV edx, eax
				POP eax
				NEG eax                         ; ȡ��
				PUSH eax
				MOV eax, edx
			.ENDIF
			MOV edx, OFFSET OperatorStackBase
			MOV edx, [edx]
			.IF (edx != edi)                    ; ջ��������ջ��
				MOV dl, [edi]                   ; dl <- ջ��
				.IF (dl == Plus)
					POP edx
					ADD [esp], edx              ; �������֣���ջ
					DEC edi                     ; ջ��ָ������
				.ELSEIF (dl == Minus)
					POP edx
					SUB [esp], edx              ; �������֣���ջ
					DEC edi                     ; ջ��ָ������
				.ENDIF
			.ENDIF
			inc edi                             ; ������ջ
			MOV [edi], BYTE PTR 2BH             ; '+'
            MOV al, 0                           ; Character
            MOV ah, 1                           ; Minus
			MOV bl, 0                           ; Positive
		.ELSEIF (bh == LeftComma)
			INC edi
			MOV [edi], BYTE PTR 28H             ; '('
            MOV al, 0                           ; Character
			MOV bl, 0                           ; Negative
			MOV ah, 1                           ; Negative
		.ELSEIF (bh == RightComma)
			.IF (al == 1 && bl == 1)             ; �����֣��Ǹ���
				MOV edx, eax
				POP eax
				NEG eax                         ; ȡ��
				PUSH eax
				MOV eax, edx
			.ENDIF
			.WHILE 1 LT 2                       ; ѭ������
				MOV bh, [edi]                   ; bh <- ����ջ��
				.IF (bh == LeftComma)           ; ��ջ
					DEC edi                     ; �ƶ�ջ��ָ��
					.BREAK
				.ELSE
					DEC edi                     ; �ƶ�ջ��ָ��
					POP edx                     ; ���ֳ�ջ
					.IF (bh == Plus)
						ADD [esp], edx
					.ELSEIF(bh == Minus)
						SUB [esp], edx
					.ENDIF
				.ENDIF
			.ENDW
		.ELSE
			.IF (al == 0)                       ; ����
				MOVZX edx, BYTE PTR [esi]
				SUB edx, 30H                    ; Char -> Number
				PUSH edx                        ; ����ѹջ
			.ELSE                               ; ����
				MOV edx, eax
				POP eax
				PUSH ecx
				MOV ecx, 10
				MUL ecx                         ; al *= 10
				POP ecx
				ADD al, BYTE PTR [esi]          ; eax += ջ������
                SUB eax, 30H                    ; eax -= 48
				PUSH eax                        ; ��ջ
				MOV eax, edx
			.ENDIF
			MOV al, 1                           ; Number
			MOV ah, 0                           ; Minus
		.ENDIF
		inc esi                                 ; esi++
		dec ecx                                 ; ecx--
	.ENDW
	MOV edx, OFFSET OperatorStackBase
	MOV edx, [edx]
	.WHILE (edi > edx)                           ; ֱ��ջ��
		MOV al, [edi]
		POP ebx
		.IF (al == Plus)
			ADD [esp], ebx
		.ELSE
			SUB [esp], ebx
		.ENDIF
		DEC edi
	.ENDW
	MOV eax, [esp]
	CALL WriteInt
	INVOKE ExitProcess, 0
main ENDP
END main
