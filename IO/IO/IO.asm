; input < Keyboard > Input1.txt
; Uppercase < Input1.txt > WriteToOutput1.txt

INCLUDE Irvine32.inc
INCLUDE macros.inc

BufferSize = 200

.data
Buffer 			BYTE 	BufferSize DUP(?)
Infile  		BYTE 	"D:\private\File\�γ����\΢��ԭ����ϵͳ\Experiment\MASM-Labs\IO\Input1.txt", 0
Outfile 		BYTE 	"D:\private\File\�γ����\΢��ԭ����ϵͳ\Experiment\MASM-Labs\IO\Output1.txt", 0
StdInHandle 	HANDLE 	?
FileHandle  	DD 		?
BytesRead   	DWORD 	?
ErrorMessage	BYTE 	"Error! ", 0
BytesActual 	DD 		?
StdOutHandle 	DD 		?
BytesWritten 	DD 		?

.code
main PROC
ReadFromKeyboard:
	INVOKE GetStdHandle, STD_INPUT_HANDLE 		; ��ȡ��׼������
	MOV	StdInHandle,eax
	INVOKE ReadConsole,                         ; �ӿ���̨����
		StdInHandle,
		ADDR Buffer,
	  	BufferSize,
		ADDR BytesRead,
		0
WriteToInput:
    PUSH eax
	INVOKE CreateFile,                          ; ��infile�ļ�
		ADDR Infile,
		GENERIC_READ OR GENERIC_WRITE,          ; ��/дģʽ
		FILE_SHARE_READ OR FILE_SHARE_WRITE,	; ���Ź���
		NULL,
	  	CREATE_ALWAYS,                          ; ����
		FILE_ATTRIBUTE_NORMAL,
		0
	MOV FileHandle, eax                         ; �����ļ����
    CMP eax, INVALID_HANDLE_VALUE				; �Ƚ��ļ�����Ƿ�Ϸ�
	JZ Error								    ; ��ת����
	INVOKE WriteFile,							; д�ļ�
		FileHandle,
        OFFSET Buffer,
        BufferSize,
		ADDR BytesActual,						; ʵ��д�ֽ���
        0
ReadFromInput:
    PUSH eax
	INVOKE CreateFile,                          ; �ٴδ�infile�ļ�
		ADDR Infile,
		GENERIC_READ OR GENERIC_WRITE,          ; ��/дģʽ
		FILE_SHARE_READ OR FILE_SHARE_WRITE,	; ���Ź���
		NULL,
	  	OPEN_EXISTING,                          ; �������ļ�
		FILE_ATTRIBUTE_NORMAL,
		0
	MOV FileHandle, eax                         ; �����ļ����
    CMP eax, INVALID_HANDLE_VALUE				; �Ƚ��ļ�����Ƿ�Ϸ�
	JZ Error								    ; ��ת����
	INVOKE ReadFile,							; ���ļ�
		FileHandle,
		OFFSET Buffer,
		BufferSize,
		ADDR BytesActual,
		0
	MOV ecx, BytesActual						; ecx <- �ֽ���
	MOV esi, OFFSET Buffer						; esi <- �׵�ַ
Uppercase:
	MOV bl, [esi]								; ѭ����ȡbuffer
	CMP bl, 60H
	JB WriteToOutput
	sub bl, 20H									; lower case -> -32 -> uppercase
	MOV [esi], bl								; д��Buffer
WriteToOutput:
	ADD esi, TYPE Buffer						; ѭ������
	LOOP Uppercase								; ѭ������
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE		; ��ȡ��׼������
    MOV StdOutHandle, eax
    PUSHAD										; ����洢��ֵ
    INVOKE WriteConsole,					    ; ���Buffer������̨
		StdOutHandle,
		ADDR Buffer,
		BytesActual,
		offset BytesWritten,
		0
	POPAD
	MOV edx, OFFSET Outfile
	INVOKE CreateFile,							; ��Outfile�ļ�
	  edx,
	  GENERIC_WRITE,            				; дģʽ
	  DO_NOT_SHARE,
	  NULL,
	  CREATE_ALWAYS,							; ����
	  FILE_ATTRIBUTE_NORMAL,
	  0
	MOV FileHandle, eax
	INVOKE WriteFile,							; ���ļ�
		FileHandle,
		OFFSET Buffer,
		BufferSize,
		ADDR BytesActual,
		0
	JMP Finish
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
Finish:
	POP eax
	INVOKE ExitProcess, 0
main ENDP
END main