INCLUDE Irvine32.inc
INCLUDE macros.inc

BufferSize = 300
ArraySize = 100

.data
Buffer 			BYTE 	BufferSize DUP(?)
Infile  		BYTE 	"D:\private\File\�γ����\΢��ԭ����ϵͳ\Experiment\MASM-Labs\Sort\Input3.txt", 0
FileHandle  	DD 		?
StdOutHandle 	DD 		?
ErrorMessage 	BYTE 	"error", 0
BytesRead 		DD 		?
BytesWritten 	DD 		?
Array 			DD 		ArraySize DUP(?)
Number 			DD 		?
Space 			DB 		" ", 0
Minus 			DB		"-", 0

.code
main PROC
	PUSH eax
	INVOKE CreateFile,							; ��infile�ļ�
		ADDR Infile,
		GENERIC_READ,							; ��ģʽ
		DO_NOT_SHARE,							; �����Ź���
		NULL,
		OPEN_EXISTING,							; �������ļ�
		FILE_ATTRIBUTE_NORMAL,
		0
	MOV FileHandle, eax							; �����ļ����
	cmp eax, INVALID_HANDLE_VALUE				; �ж��ļ�����Ƿ�Ϸ�
	JZ Error									; ��ת����
	INVOKE ReadFile,							; ���ļ�
		fileHandle,
		OFFSET Buffer,
		BufferSize,
		ADDR BytesRead,							; ʵ�ʶ��ֽ���
		0
	MOV ecx, BytesRead							; ecx <- �ֽ���
	MOV esi, OFFSET Buffer						; esi <- Buffer �׵�ַ
	MOV ebx, 0									; ebx <- 0
	MOV edx, 0									; edx <- 0 (Positive)
	MOV edi, OFFSET Number						; edi <- ȫ�ֱ�����ַ����������
	MOV [edi], edx								; Number <- edx(0)
	MOV edi, OFFSET Array						; ����λ��

GetChar:										; ѭ�������ַ�
	CMP BYTE PTR [esi], 20H						; ' '
	JNE Negative_Q								; ������ǿո��ж��Ƿ��Ǹ���
	CALL AssignToArray
	JMP LoopGetChar
Negative_Q:
	CMP BYTE PTR [esi], 2DH						; '-'
	JNE Count									; ������Ǹ��ţ�ֱ�Ӽ���
	MOV edx, 1									; edx <- 1 (Negative)
	JMP LoopGetChar
Count:											; ebx <- ebx * 10 + [esi] - ��0��
	PUSH edx									; ��������λ
	MUL ebx										; eax(10) *= ebx
	MOV ebx, eax								; ebx <- eax
	MOVZX eax, BYTE PTR [esi]					; eax <- [esi]
	ADD ebx, eax								; ebx += [esi]
	SUB ebx, 30H								; ebx -= '0'
	MOV eax, 10									; eax <- 10
	POP edx
LoopGetChar:
	INC esi										; ѭ������
	LOOP GetChar
	CALL AssignToArray

	MOV ecx, OFFSET Number
	MOV ecx, [ecx]
	SUB ecx, 1									; i = Number - 1
	MOV esi, OFFSET Array						; esi <- �����ַ
Loop_I:
	PUSH ecx									; �������ѭ��
	PUSH esi
Loop_J:											; j = esi
	MOV edi, [esi + 4]							; edi <- [esi + 4]
	CMP [esi], edi
	JS Ordered									; [esi] < [esi + 4] ����
	CALL Swap									; [esi] >= [esi + 4]
Ordered:
	ADD esi, TYPE Array							; j++
	LOOP Loop_J
	POP esi										; j = 0
	POP ecx
	LOOP Loop_I

	MOV esi, OFFSET Array						; esi <- �����ַ
	MOV ecx, OFFSET Number
	MOV ecx, [ecx]
Loop_Print:
	MOV eax, [esi]								; eax <- [esi]
	ADD eax, 0
	JNS Print									; S = 0 (Positive)
	PUSH eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE		; ��ȡ��׼������
    MOV StdOutHandle, eax
    PUSHAD
    INVOKE WriteConsole,                    	; �����̨�����-��
        StdOutHandle,
        ADDR Minus,
        1,
        OFFSET BytesWritten,
        0
	POPAD
	POP eax
	NEG eax										; eax = -eax (Neg -> Pos)
Print:
	CALL WriteDec
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE		; ��ȡ��׼������
    MOV StdOutHandle, eax
    PUSHAD
    INVOKE WriteConsole,                    	; �����̨����ո�
        StdOutHandle,
        ADDR Space,
        1,
        OFFSET BytesWritten,
        0
	POPAD
	ADD esi, TYPE Array							; i++
	LOOP Loop_Print
	INVOKE ExitProcess, 0
main ENDP

;--------------------------------------------------------
AssignToArray proc
; ����edxΪ��־λ����ebxΪ��ֵ�����ݴ�������Array
; @Receives: edx = sign (1: negative), ebx = unsigned number, edi = OFFSET Array
; @Returns: none
;--------------------------------------------------------
	CMP edx, 1
	JNE Assign
	NEG ebx										; ����ȡ��
Assign:
	MOV [edi], ebx								; *edi <- ebx
	ADD edi, TYPE Array							; edi++
	MOV ebx, OFFSET Number
	MOV edx, 1
	ADD [ebx], edx								; *ebx++
	MOV ebx, 0									; ebx <- 0
	MOV edx, 0									; edx <- 0 (Positive)
	RET
AssignToArray ENDP

;--------------------------------------------------------
Swap proc
; ����[esi]��[esi + 4]
; @Receives: [esi], [esi + 4]
; @Returns: none
;--------------------------------------------------------
	MOV eax, [esi]
	MOV ebx, [esi + 4]
	MOV [esi], ebx
	MOV [esi + 4], eax
	RET
Swap ENDP

Error:
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE		; ��ȡ��׼������
    MOV StdOutHandle, eax
    PUSHAD
    INVOKE WriteConsole,                        ; ��ӡ������Ϣ
		StdOutHandle,
		Offset ErrorMessage,
		SIZEOF ErrorMessage,
		offset BytesWritten,
		0
	POPAD
	POP eax
	INVOKE ExitProcess, 0
END main
