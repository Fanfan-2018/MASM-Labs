; Input < Keyborad -> N, 0 < N < 10
; 1 .. N^2 -> 2*2 Array
; Output < lower triangle of Array

INCLUDE Irvine32.inc ; ����Kip Irvine���ڵĿ�
INCLUDE macros.inc   ; ����Macros��

BufferSize = 300

.data
ReadBuffer      DB  3 DUP(?)
Buffer          DB  BufferSize DUP(?)
StdInHandle     DD  ?
BytesRead       DD  ?
StdOutHandle    DD  ?
BytesWritten    DD  ?
Space           DB  " ", 0
Return          DB  0AH, 0
.code
main PROC
	INVOKE GetStdHandle, STD_INPUT_HANDLE   ; ��ȡ��׼������
	MOV	StdInHandle,eax
	INVOKE ReadConsole,                     ; �ӿ���̨����
        StdInHandle,
        ADDR ReadBuffer,
        01H,
        ADDR BytesRead,
        0
	MOV	ecx, OFFSET ReadBuffer				; ecx <- ��������
	MOVZX ecx, BYTE PTR [ecx]				; ��MOVZX��֤����
	SUB ecx, 30H							; ���ѭ������
	MOV eax, ecx
	MUL ecx                                 ; �Գ�
	MOV ecx, eax
	MOV esi, OFFSET Buffer					; ƫ�Ƶ�ַ
	MOV ebx, 01H							; ����
SaveToArray:								; ����n^2������
	MOV [esi], ebx
	ADD esi, TYPE Buffer					; esi����
	INC ebx
	LOOP SaveToArray
	MOV	ecx, OFFSET ReadBuffer				; ecx <- ��������
	MOVZX ecx, BYTE PTR [ecx]
	SUB ecx, 30H
	MOV ebx, ecx							; ebx <- ecx
	MOV esi, OFFSET Buffer					; esi <- Buffer�ĵ�ַ
Column:
	MOV edx, ecx							; edx <- ���ѭ����
	PUSH ecx								; ѹջ���ѭ����ecx
	MOV ecx, ebx							; �ڲ�ѭ������ <- ebx
Row:
	CMP ecx, edx
	JB Skip									; �ڲ�ѭ�� > ���ѭ��
	MOVZX eax, BYTE PTR [esi]
	call WriteDec
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE	; ��ȡ��׼������
    MOV StdOutHandle, eax
    PUSHAD
    INVOKE WriteConsole,                    ; �����̨����ո�
        StdOutHandle,
        ADDR Space,
        1,
        OFFSET BytesWritten,
        0
	POPAD
Skip:
	ADD esi, TYPE Buffer					; esi����
	LOOP Row
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE	; ��ȡ��׼������
    MOV StdOutHandle, eax
    PUSHAD
    INVOKE WriteConsole,                    ; �����̨����س�
        StdOutHandle,
        ADDR Return,
        1,
        OFFSET BytesWritten,
        0
	POPAD
	POP ecx									; ��ջ���ѭ����ecx
	LOOP Column
	INVOKE ExitProcess, 0
main ENDP
END main