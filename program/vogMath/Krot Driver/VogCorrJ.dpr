library VogCorrJ;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  View-Project Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the DELPHIMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using DELPHIMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$Define NoDebug}
uses
  SysUtils,
  Classes,
  Windows,
  IniFiles,
  KrotApi;

Const

  MAX_SENSORS_COUNT  = 128;
  MAX_RECS_IN_BLOCK  = 200;

  MAX_OPENED_TRACES = 3;

  MAX_TRACE_NAME_LENGTH = 1024;

  DRIVER_DATA_SECTION = 'DriverData';
  TRACE_SECTION = 'Trace';

  VOG_MAT_FILE_KEY  = 'VogMat';
  VOG_NAV_FILE_KEY  = 'VogNav';

  CORR_PRIMARY_DIR_KEY  = 'CorrPrimary';

  SWAP1_KEY = 'Swap1';
  SWAP2_KEY = 'Swap2';
  SWAP3_KEY = 'Swap3';
  SWAP4_KEY = 'Swap4';

  NORMAL_SENSORS_ORDER_KEY = 'NormalSensorsOrder';
{  DIAMETER_KEY   = 'Diameter';
  PIG_LENGTH_KEY = 'PigLength';
  ODOM_START_KEY = 'OdoStart';}
  VOG_ODOM_KOEFF_KEY = 'VogOdomKoeff';

  X0_KEY = 'X0';
  Y0_KEY = 'Y0';

  CorrRecsInBlock  = 200;
  CorrSensorsCount32 = 32;
  CorrSensorsCount128 = 128;
  CorrDataSize128 = CorrRecsInBlock * CorrSensorsCount128;
{  CorrAllSensorsCount = 128;}

  CorrMemCount = 64;
  CorrAddDelta = $80;

  CorrPrimaryFilesMask = 'cr*.104';
  VogMatFilesMask = '*.mat';
  VogNavFilesMask = '*.out';
  VogMatIndexName = 'tt.idx';
  CorrIndexFileName = 'cr.idx';


  CorrDummyValues = [0, 1, $EE];

  Version32Id = $F7;

  VogMatSensorsCount = 6;
{  XAxis = 1;
  YAxis = 2;
  ZAxis = 3;
  VogSensorsCount = 3 ;
  AccelSensorsCount = 3;
  VogMatRecsInBlock  = 1000;}

  ArcSign  = $F8;
  NewArcSignSet = [$FB,$FC,$FD];
  MaxArcBuffSize = 30000;

  START_FIELD_SIZE = 9;
  MAX_FIELD_SIZE = 16;
  MAX_CHAR_CODE = $FF;
  MAX_WORD = $FFFF;

  MAX_CHAINS_COUNT = 12000;
  NONE_CODE_VALUE = MAX_CHAINS_COUNT;
  CLEANUP_CODE = NONE_CODE_VALUE - 1;
  MAX_POSSIBLE_CODE = NONE_CODE_VALUE - 2;


  ExtSensorsCount = 6;
  ExtSensorsNames: Array [1 .. ExtSensorsCount] of PChar = ('VogX', 'VogY', 'VogZ', 'AccelX', 'AccelY', 'AccelZ');
Type

  DWord = Integer;
  TTraceHandleIndex = 1 .. MAX_OPENED_TRACES;

  TCorrFormatVersion = (CF32, CF128, CFUnknown);
  TCorrSensors32  = array [1 .. CorrSensorsCount32] of byte;
  TCorrSensors128 = array [1 .. CorrSensorsCount128] of byte;

  TVogMatFormatVersion = (VF7, VF8, VFUnknown);

PInformUser = ^TInformUser;
TInformUser = Function (PercentDone: SmallInt): Integer; stdcall;
{$Align off}
//------------------
  TCorrBlockHeader = Record
    Signature: Byte;
    TopSens  : Byte;
    Reserved : Array [1..4] of char;

    BaseTime   : DWord;
    BaseDist   : DWord;

//
  End;

  TCorrRec32 = Record
    DistOffset : SmallInt;
    Sensors    : TCorrSensors32;
  End;

  TCorrBlock32 = Record
    BlockHeader: TCorrBlockHeader;
    Recs       : Array [1 .. CorrRecsInBlock] of TCorrRec32;
    Dummy      : Array [1..2] of char;
  End;

  TCorrPrimaryFile32 = File of TCorrBlock32;

  TCorrRec128 = Record
     DistOffset : Word;
     CorrSensors128: TCorrSensors128;
  End;


  PCorrBlock128 = ^TCorrBlock128;
  TCorrBlock128 = Record
    BlockHeader: TCorrBlockHeader;
    Case Boolean of
      False: (DistOffsets: Array [1..CorrRecsInBlock] of Word;
              Data: Array [0 .. CorrDataSize128 - 1] of byte);
      True : (Data4Arc: Array [0 .. CorrRecsInBlock * SizeOF (Word) + CorrDataSize128 - 1] of byte)
  End;

  TCorrPrimaryFile128 = File of Word;

  TCommonBlock = Record
    BaseTime    : DWord;
    BaseDist    : DWord;
    RealLength  : DWord;
    BaseOrient  : Integer;
    SensorsCount: Integer;
    RecsInBlock : Integer;
    DistOffsets : Array [ 1 .. MAX_RECS_IN_BLOCK ] of SmallInt;
    SensorsData : Array [0 .. MAX_SENSORS_COUNT * MAX_RECS_IN_BLOCK - 1] of Byte;
  End;

  TArcBlockHeader128 = Record
    Case Boolean of
      False: (
        Signature    : Byte;
        TopSens      : Byte;
        ArcDataSize  : Word;
        ArcDataCount : Word;
  //        Reserved : Array [1..2] of char;

        BaseTime   : DWord;
        BaseDist   : DWord);

      True:
        (HeaderBuff: Array [0..6] of Word);
   End;

  TArcBlock128 = Record
    BlockHeader: TArcBlockHeader128;
    ArcData: Array [0 .. MaxArcBuffSize-1] of Word;
  End;

  TChain = Record
    LastChar   : Char;
    RightCode  : Word;
    Case Boolean of
      False:
        (PrefixCode : Word);
      True:
        (SuffixCode : Word);
  End;

TChainsTable = Array [0 .. MAX_CHAINS_COUNT] of TChain;

  TCorrIndexRec = Record
    Dist    :  DWord;
    Time    :  DWord;
    TopSens :  Byte;
    FileNum :  Word;
    Offset  :  DWord;
    Reserved: Array [1..8] of char;
  End;

  TCorrIndexFile = File of TCorrIndexRec;
{
  TVogSensorsF7 = Array [1 .. VogSensorsCount]   of SmallInt;
  TVogSensorsF8 = Array [1 .. VogSensorsCount]   of Single;
  TAccelSensors  = Array [1 .. AccelSensorsCount] of SmallInt;

  TTemperature = Record
    Case Boolean of
      False:
       (TX: SmallInt;
        TY: SmallInt;
        TZ: SmallInt);
      True:
       (TemperSens: Array [XAxis .. ZAxis] of SmallInt);
  End;

  TRecF7 = Record
    TimeOffset:   Word;
    DistOffset:   Word;
    OdomNum   :   Byte;
    VogSensors:   TVogSensorsF7;
    AccelSensors: TAccelSensors;
  End;

  TRecF8 = Record
    TimeOffset:   Word;
    DistOffset:   Word;
    OdomNum   :   Byte;
    VogSensors:   TVogSensorsF8;
    AccelSensors: TAccelSensors;
  End;

  TVogMatBlockF7 = Record
    Signature  : Byte;
    Reserved   : Array [1 .. 5] of Char;
    Temperature: TTemperature;
    BaseTime   : DWord;
    BaseDist   : DWord;
    Recs       : Array [1 .. VogMatRecsInBlock] of TRecF7;
  End;

  TVogMatBlockF8 = Record
    Signature  : Byte;
    Reserved   : Array [1 .. 5] of Char;
    Temperature: TTemperature;
    BaseTime   : DWord;
    BaseDist   : DWord;
    Recs       : Array [1 .. VogMatRecsInBlock] of TRecF8;
  End;

  TVogMatFileF7 = File of TVogMatBlockF7;
  TVogMatFileF8 = File of TVogMatBlockF8;

  TVogMatIndexRec = Record
    Dist    : DWord;
    Time    : DWord;
    FileNum : Word;
    BlockNum: Word;
    Reserved: Array [1..8] of char;
  End;

  TVogMatIndexFile = File of TVogMatIndexRec;}

  TVogMatSensors    = Array [1 .. VogMatSensorsCount]   of Single;
  TVogMatRec = Record
     Time:  Single;
     Dist:  Integer;
     Sensors:  TVogMatSensors;
   End;

  TVogMatFile = File of TVogMatRec;

  TVogNavRec = Record
    Time: Integer;
    Dist: Integer;
    X   : Integer;
    Y   : Integer;
    Z   : Integer;
    Psi: Single;
    Teta: Single;
    Gamma: Single;
  End;

  TVogCompareRec = Record
    Dist: Integer;
    X   : Integer;
    Y   : Integer;
    Z   : Integer;
  End;

  TVogNavFile = File of TVogNavRec;
//------------------------------------------------------------------------------

  TOpenedTraces = Record // информация об открытых прогонах


    TraceIni: TIniFile;
    TraceHandle      : TKrtTraceHandle; // TraceHandle прогона
{    TraceName   : Array [0..MAX_TRACE_NAME_LENGTH] of char; // имя файла описания прогона}
    TraceLength : Integer;  // Длина трассы в мм
    TraceTime   : Integer;  // Общее время записи в мс
    Diameter     : Integer;  // диаметр трубы (см.)
    PigLength    : Integer;  // длина снаряда (см.)

    CommonBlock  : TCommonBlock;
    ArcBlock128  : TArcBlock128;
    CorrBlock128 : TCorrBlock128;
    CorrBlock32  : TCorrBlock32;

    CorrFormatVersion: TCorrFormatVersion;
    CorrFilesOpened : Boolean;
    CorrIndexOpened : Boolean;
    CorrPrimaryFile32 : TCorrPrimaryFile32;
    CorrPrimaryFile128: TCorrPrimaryFile128;
    CorrIndexFile: TCorrIndexFile;
    CorrIndexRecs   : Integer;
    CorrCurrFileNum : Integer;
    CorrCurrRecNum  : Integer;
    CorrDistDiff    : Integer;
    CorrFileList    : TStringList;
    CorrMemSensors: Array [1 .. MAX_SENSORS_COUNT, 1 .. CorrMemCount] of byte;
    CorrSummes, CorrMiddles : Array [1 .. MAX_SENSORS_COUNT] of Integer;
    CorrMiddleIndex: Integer;

    VogFileAccessMode: (UsualMode, FileMapMode);

{    VogMatFormatVersion: TVogMatFormatVersion;
    VogMatFileF7: TVogMatFileF7;
    VogMatFileF8: TVogMatFileF8;
    VogMatBlockF7: TVogMatBlockF7;
    VogMatBlockF8: TVogMatBlockF8;

    VogMatIndexFile: TVogMatIndexFile;
    VogMatRecs: Integer;                  }
    VogMatTraceHandle: Integer;
    VogMatTraceMap: Pointer;
    VogMatFileOpened: Boolean;
    VogMatRecsCount: DWord;
{    VogMatIndexOpened: Boolean;}
    VogMatFileList: TStringList;
{   VogMatCurrFileNum: Integer;
    VogMatCurrRecNum : Integer;}
    VogMatCurrDist   : DWord;

    VogNavFilesOpened  : Boolean;
    VogNavTraceHandle   : Integer;
    VogNavTraceMap: Pointer;
    VogNavTraceRecs   : Integer;
    VogMatTraceRecs   : Integer;
    VogNavReadStep    : Integer;  // дискретность чтения записей первичного Vog-файла
    VogMatReadStep    : Integer;
    VogNavCurrFilePos : Integer;
    VogMatCurrFilePos : Integer;
    VogNavCurrFPointer: Pointer;
    VogMatCurrFPointer: Pointer;
    VogNavEndPointer  : Pointer;
    VogMatEndPointer  : POinter;
    VogNavLastDist    : Integer;
    VogMatLastDist    : Integer;
    LastSensType   : Integer;
    LastSensIndex  : Integer;

    OdomStart   : Integer;
    VogOdomKoeff: Double;

    VogMatPresent: Boolean;
    VogNavPresent: Boolean;
    CorrPresent  : Boolean;
    RowDataSupported: Boolean;

    GKX0: Integer;
    GKY0: Integer;
    CurrD: Integer;

    Swap1,Swap2,Swap3,Swap4: Integer;
    SwapSensors: Boolean;

    ScrBuff: Pointer;{Array [0 .. 100000 * 128] of byte}
    MemStartDist: Integer;
    CurrThickDist: Integer;
    MemLength: Integer;
    PThick: Pointer;
    LastThick: Byte;
    ThickStep: Integer;
  End;

{$Align on}

  TSensSource = (CorrSource, VogSource);

Var
  ErrorMsg: PChar;

  Chains: TChainsTable;


  OpenedTraces:  Array [1..MAX_OPENED_TRACES] of TOpenedTraces;
  LastTraceHandleIndex: TTraceHandleIndex;  // Нехорошо, зато позволяет
                                  // избежать многократных вызовов GetTraceHandleIndex
                                  // в GetNextNode*.

{$IFDEF Debug}
  FLog: TextFile;
{$ENDIF}

Function GetThickValue (TraceHandleIndex: Integer; DOffset: Integer): Integer;
Var
{i: Integer;
ThickSum: Integer;}
P: Pointer;
  Begin
    With OpenedTraces[TraceHandleIndex] do
      Begin
        DWord(P) := DWord (PThick) + DOffset * SizeOF (Byte);
        IF DOffset < MemLength
          Then
            Result := Byte(P^)
          Else
            Result := LastThick;

        LastThick := Result;
    {        ThickSum := 0;
        For i := 0 to CommonBlock.SensorsCount-1 do
          Begin
            DWord(P) := DWord(SP) + i * L + DOffset;
            ThickSum := ThickSum + Byte(P^);
          End;

        Result := Round (ThickSum / CommonBlock.SensorsCount);}
      End;
  End;

Function VogNavFindRecNumber (TraceHandleIndex: TTraceHandleIndex; Dist: Integer): Integer;
Var
M: Integer;
Left, Right, Middle: Integer;
VogNavRec: TVogNavRec;
MV: Integer;
BytesRead: Integer;
P: Pointer;

  Function GetDistByRecN (TraceHandleIndex: TTraceHandleIndex; RecN: Integer): Integer;
    Begin
      With OpenedTraces[TraceHandleIndex] do
        Begin
          IF VogFileAccessMode = UsualMode
            Then
              Begin
                SetFilePointer (VogNavTraceHandle, SizeOF (TVogNavRec) * RecN, Nil, FILE_BEGIN);
                ReadFile       (VogNavTraceHandle, VogNavRec, SizeOf (TVogNavRec), BytesRead, Nil);
              End
            Else
              Begin
                P := VogNavTraceMap;
                DWord(P) := DWord(P) + SizeOF (TVogNavRec) * RecN;
                VogNavRec := TVogNavRec (P^);
              End;
        End;

      Result := VogNavRec.Dist;
    End;

  Begin
    Left := 0;
    Right := OpenedTraces[TraceHandleIndex].VogNavTraceRecs-1;
    Middle := -1;

    Repeat
        M := Left+(Right - Left) div 2;
        IF Middle = M // не изменилось после предыдущей итерации
          Then
            Begin
              Inc (Middle); // обеспечение сходимости слева
              Inc (Left);   // Inc (Left) <=> Left := Right в данном случае
            End
          Else
             Middle := M;

        MV := GetDistByRecN (TraceHandleIndex, Middle);
        IF Dist<MV
          Then
            Right := Middle
          Else
            IF Dist>MV Then
                 Left  := Middle;
    Until (Dist = MV) or (Left=Right);
    Result := Middle;
  End;

//-----------------------------------------------------------------------------

Function VogMatFindRecNumber (TraceHandleIndex: TTraceHandleIndex; Dist: Integer): Integer;
Var
M: Integer;
Left, Right, Middle: Integer;
VogMatRec: TVogMatRec;
MV: Integer;
P: Pointer;

  Function GetDistByRecN (TraceHandleIndex: TTraceHandleIndex; RecN: Integer): Integer;
    Begin
      With OpenedTraces[TraceHandleIndex] do
        Begin
          P := VogMatTraceMap;
          DWord(P) := DWord(P) + SizeOF (TVogMatRec) * RecN;
          VogMatRec := TVogMatRec (P^);
        End;

      Result := VogMatRec.Dist;
    End;

  Begin
    Left := 0;
    Right := OpenedTraces[TraceHandleIndex].VogMatTraceRecs-1;
    Middle := -1;

    Repeat
        M := Left+(Right - Left) div 2;
        IF Middle = M // не изменилось после предыдущей итерации
          Then
            Begin
              Inc (Middle); // обеспечение сходимости слева
              Inc (Left);   // Inc (Left) <=> Left := Right в данном случае
            End
          Else
             Middle := M;

        MV := GetDistByRecN (TraceHandleIndex, Middle);
        IF Dist<MV
          Then
            Right := Middle
          Else
            IF Dist>MV Then
                 Left  := Middle;
    Until (Dist = MV) or (Left=Right);
    Result := Middle;
  End;

Function Sign (Value: Real): Integer;
  Begin
    If Value >= 0
      Then
        Result := 1
      Else
        Result := -1;
  End;
(*
Function GetOrient (TraceHandleIndex,Dist: Integer): Integer;
Const
     G = 9.80665;
     R_G = 180/pi;
     kwx2 = -1.0045;  { масштабные коэффициенты }
     kwx3 =  1.0021;
     G_S = 127 / 360; { коэффициент перевода градус - датчик }

Var
N: Integer;
P: Pointer;
VMR: TVogMatRec;
VNR: TVogNavRec;
wx2, wx3: Single;
Gr: Double;
  function ArcTg2(sA, cA:real) : real;
  { для диапазона 0...2pi  при отсчете по часовой стрелке}
    begin
    if cA = 0
      then
        if sA < 0
          then
            ArcTg2 := 1.5 * pi
          else
            ArcTg2 := 0.5 * pi
       else
         if cA < 0
           then
             ArcTg2 :=  pi + ArcTan(sA / cA)
           else
             if sA < 0
               then
                 ArcTg2 :=2 * pi + ArcTan(sA / cA)
               else
                 ArcTg2 := ArcTan(sA / cA);
    end;
  Begin
    N := VogNavFindRecNumber (TraceHandleIndex, Dist);
    P := OpenedTraces[TraceHandleIndex].VogNavTraceMap;
    DWord(P) := DWord(P) + SizeOF (TVogNavRec) * N;
    VNR := TVogNavRec (P^);


    IF VNR.Gamma < 0
      Then
        Result := Abs(Round (( Round (Vnr.Gamma / pi * 180) mod 360) * G_S))
      Else
        Result := 127 - Round(( Round (Vnr.Gamma / pi * 180) mod 360) * G_S);

    N := VogMatFindRecNumber (TraceHandleIndex, Dist);
    P := OpenedTraces[TraceHandleIndex].VogMatTraceMap;
    DWord(P) := DWord(P) + SizeOF (TVogMatRec) * N;
    VMR := TVogMatRec (P^);

    wx2 := Vmr.Sensors[5];
    wx3 := Vmr.Sensors[6];

    wx2 := -kwx2 * wx2;
    wx3 := kwx3 * wx3;

    If wx2=0 then wx2:=0.00001 * Sign (wx2);
    Gr := R_G * arctg2( wx3 , wx2);
{    If Gr>=0
      Then
        Begin
          If wx3<0
            Then
              gr := gr + 180;
        End
          Else
            If wx3>=0
              Then
                gr := 180 + gr
              Else
                gr := 360 + gr;}

     Result := Round(Gr * G_S);
  End;                          *)
// -------------------------------------------------------------------------
Function krtCloseTrace (TraceHandle: TKrtTraceHandle): Integer; stdcall ; forward;
// -------------------------------------------------------------------------
Function GetVogMatFormatVersion (FName: String): TVogMatFormatVersion;
Var
b: Byte;
F: File of byte;
  Begin
    AssignFile (F, FName);
    Reset (F);
    Read (F,b);

    Case B of
      $F7: Result := VF7;
      $F8: Result := VF8;
    Else
      Result := VFUnKnown;
    End;
    CloseFile (F);
  End;

// -------------------------------------------------------------------------
Function GetCorrFormatVersion (FilePath: String): TCorrFormatVersion;
Var
f: File of byte;
b: Byte;
  Begin
    AssignFile (f, FilePath);
    Reset (f);

    Read (f, b);
    CloseFile (f);
    IF b = Version32Id
      Then
        Result := CF32
      Else
        IF b > Version32Id
          Then
            Result := CF128
          Else
            Result := CFUnknown;
  End;
//-----------------------------------------------------------------------------

Procedure Convert32toCommon (TraceHandleIndex: TTraceHandleIndex; Block32: TCorrBlock32);
Var
i,j: Integer;
LD: Integer;
DummyCount: Integer;
DummyFlag: Boolean;
{MarkSensN: Integer;
TempSensors: Array [1 .. 32] of byte;}
  Begin
    With OpenedTraces[TraceHandleIndex] do
      Begin
        CommonBlock.SensorsCount := CorrSensorsCount128;
        CommonBlock.RecsInBlock  := CorrRecsInBlock;
        CommonBlock.BaseDist     := Block32.BlockHeader.BaseDist;
        CommonBlock.BaseTime     := Block32.BlockHeader.BaseTime;

{        IF VogNavPresent
          Then
            CommonBlock.BaseOrient   := GetOrient (TraceHandleIndex, CommonBlock.BaseDist)
          Else}

        CommonBlock.BaseOrient   := Block32.BlockHeader.TopSens;
        LD := 0;
        For i := 1 to CommonBlock.RecsInBlock do
          Begin
{            MarkSensN := 1;
            For j := CorrSensorsCount32 downto 1 do
              If Block32.Recs[i].Sensors[j] = 0
                Then
                  Begin
                    MarkSensN := j;
                    Break;
                  End;

            IF MarkSensN > 1
              Then
                Begin
                  Move (Block32.Recs[i].Sensors[MarkSensN], TempSensors[1], 32 - MarkSensN + 1);
                  Move (Block32.Recs[i].Sensors[1], TempSensors[32 - MarkSensN + 2], MarkSensN - 1);

                  Move (TempSensors, Block32.Recs[i].Sensors, 32);
                End; }

            CommonBlock.DistOffsets[i] := Block32.Recs[i].DistOffset;
            LD := LD + CommonBlock.DistOffsets[i];

            DummyCount := 0;
            For j := 1 to CorrSensorsCount32 do
              IF Block32.Recs[i].Sensors[j] in CorrDummyValues
                Then
                  Inc (DummyCount);
            DummyFlag := DummyCount >= 16;

            For j := 1 to CorrSensorsCount32 do
              Begin
                If (i = 1) or not DummyFlag
                  Then
                    Begin
                      CommonBlock.SensorsData[ (j - 1) * 4 * MAX_RECS_IN_BLOCK + LD] := Block32.Recs[i].Sensors[j];
                      CommonBlock.SensorsData[((j - 1) * 4 + 1) * MAX_RECS_IN_BLOCK + LD] := Block32.Recs[i].Sensors[j];
                      CommonBlock.SensorsData[((j - 1) * 4 + 2) * MAX_RECS_IN_BLOCK + LD] := Block32.Recs[i].Sensors[j];
                      CommonBlock.SensorsData[((j - 1) * 4 + 3) * MAX_RECS_IN_BLOCK + LD] := Block32.Recs[i].Sensors[j];
                    End
                  Else
                    Begin
                      CommonBlock.SensorsData[((j - 1) * 4) * MAX_RECS_IN_BLOCK + LD] := CommonBlock.SensorsData[((j - 1) * 4) * MAX_RECS_IN_BLOCK + LD - 1];
                      CommonBlock.SensorsData[((j - 1) * 4 + 1) * MAX_RECS_IN_BLOCK + LD] := CommonBlock.SensorsData[((j - 1) * 4 + 1) * MAX_RECS_IN_BLOCK + LD - 1];
                      CommonBlock.SensorsData[((j - 1) * 4 + 2) * MAX_RECS_IN_BLOCK + LD] := CommonBlock.SensorsData[((j - 1) * 4 + 2) * MAX_RECS_IN_BLOCK + LD - 1];
                      CommonBlock.SensorsData[((j - 1) * 4 + 3) * MAX_RECS_IN_BLOCK + LD] := CommonBlock.SensorsData[((j - 1) * 4 + 3) * MAX_RECS_IN_BLOCK + LD - 1];
                    End
              End;
          End;

        CommonBlock.RealLength := LD + 1;
      End;

  End;

//-----------------------------------------------------------------------------
Procedure SwapSectors (TraceHandleIndex: Integer; n1,n2: Integer);
Var
  b: Byte;
  i,j: Integer;
  Begin
    With OpenedTraces [TraceHandleIndex] do
      For i := 1 to MAX_RECS_IN_BLOCK do
        Begin
          For j := 1 to 32 do
            Begin
              b := CommonBlock.SensorsData[ (j - 1 + (n1 - 1)* 32) * MAX_RECS_IN_BLOCK + i - 1];
              CommonBlock.SensorsData[ (j - 1 + (n1 - 1)* 32) * MAX_RECS_IN_BLOCK + i - 1] := CommonBlock.SensorsData[ (j - 1 + (n2 - 1)* 32) * MAX_RECS_IN_BLOCK + i - 1];
              CommonBlock.SensorsData[ (j - 1 + (n2 - 1)* 32) * MAX_RECS_IN_BLOCK + i - 1] := b;
            End;
        End;
  End;
(*
Procedure Convert128toCommon (TraceHandleIndex: TTraceHandleIndex; Block128: TCorrBlock128);
Var
i,j,k: Integer;
MemLD, LD: Integer;
DummyCount: Integer;
DummyFlag: Boolean;
tb: Byte;
  Begin
    With OpenedTraces[TraceHandleIndex] do
      Begin
        CommonBlock.SensorsCount := CorrSensorsCount128;
        CommonBlock.RecsInBlock  := CorrRecsInBlock;
        CommonBlock.BaseDist     := Block128.BlockHeader.BaseDist;
        CommonBlock.BaseTime     := Block128.BlockHeader.BaseTime;
        CommonBlock.BaseOrient   := Block128.BlockHeader.TopSens;

        LD := 0;
        For i := 1 to CommonBlock.RecsInBlock do
          Begin
            CommonBlock.DistOffsets[i] := Block128.DistOffsets[i];

            MemLD := LD;
            LD := LD + CommonBlock.DistOffsets[i];

            IF Block128.BlockHeader.Signature = ArcSign
              Then
                Begin
                  DummyCount := 0;
                  For j := 1 to CorrSensorsCount128 do
                    Begin
                      IF Block128.Data[(j - 1) * CorrRecsInBlock + (i - 1)] in CorrDummyValues
                        Then
                          Inc (DummyCount);
                    End;
                  DummyFlag := DummyCount > 32;
                End
              Else
                For k := 1 to CommonBlock.DistOffsets[i]-1 do
                  For j := 1 to CorrSensorsCount128 do
                    Begin
                      CommonBlock.SensorsData[(j - 1) * MAX_RECS_IN_BLOCK + MemLD + k] := CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + MemLD + (k - 1)];
                    End;

            IF (Block128.BlockHeader.Signature = ArcSign)
              Then
                Begin
                  For j := 1 to CorrSensorsCount128 do
                    Begin
                      IF (i = 1) or not DummyFlag
                        Then
                          CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + LD] := Block128.Data[(j - 1) * CorrRecsInBlock + (i - 1)]
                        Else
                          CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + LD] := CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + LD - 1];

                      IF SwapSensors and ((j mod 4) = 0) and not DummyFlag
                        Then
                          Begin
                            tb := CommonBlock.SensorsData[ (j - 4) * MAX_RECS_IN_BLOCK + LD];
                            CommonBlock.SensorsData[ (j - 4) * MAX_RECS_IN_BLOCK + LD] := CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + LD];
                            CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + LD] := tb;

                              tb := CommonBlock.SensorsData[ (j - 3) * MAX_RECS_IN_BLOCK + LD];
                            CommonBlock.SensorsData[ (j - 3) * MAX_RECS_IN_BLOCK + LD] := CommonBlock.SensorsData[ (j - 2) * MAX_RECS_IN_BLOCK + LD];
                            CommonBlock.SensorsData[ (j - 2) * MAX_RECS_IN_BLOCK + LD] := tb;
                          End;
                    End;
                End;

{            For j := 1 to CorrSensorsCount128 do
              IF (Block128.BlockHeader.Signature = ArcSign) or (i = 1)
                Then
                  CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + LD] := Block128.Data[(j - 1) * CorrRecsInBlock + (i - 1)]
                Else
                  CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + LD] := CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + (LD - 1)] +
                                                                                    Block128.Data[(j - 1) * CorrRecsInBlock + (i - 1)];
            For j := 1 to CorrSensorsCount128 do
              Begin
                CommonBlock.SensorsData[ (j - 1) * MAX_RECS_IN_BLOCK + LD] := Block128.Data[(j - 1) * CorrRecsInBlock + (i - 1)];
              End;}

          End;

        IF (Swap1 <> 0) and (Swap2 <> 0)
          Then
            Begin
              SwapSectors (TraceHandleIndex, Swap1, Swap2);
            End;

        IF (Swap3 <> 0) and (Swap4 <> 0)
          Then
            Begin
              SwapSectors (TraceHandleIndex, Swap3, Swap4);
            End;
        CommonBlock.RealLength := LD + 1;
      End;
  End;    *)
//-----------------------------------------------------------------------------
Procedure InitTables;
Var
i: Integer;
  Begin
    For i := 0 to MAX_CHAR_CODE do
      Begin
        Chains[i].LastChar   := Char(i);
        Chains[i].PrefixCode := NONE_CODE_VALUE;
        Chains[i].SuffixCode := NONE_CODE_VALUE;
        Chains[i].RightCode  := NONE_CODE_VALUE;
      End;
  End;

// -------------------------------------------------------------------------

Function GetChainStr (Code: Word): ShortString;
  Begin
    Result := Chains[Code].LastChar;
    While Code > MAX_CHAR_CODE do
      Begin
         Code := Chains[Code].PrefixCode;
         Result := Chains[Code].LastChar + Result;
      End;
  End;

// -------------------------------------------------------------------------
Procedure DecodeBlock128 (Var ArcBlock: TArcBlock128; Var CorrBlock: TCorrBlock128);
Var
CurrCode, Code, OldCode: Word;
InBuffIdx, OutBuffIdx: Word;

OldChainStr,ChainStr: ShortString;

CorrBlockBuff: Array [0 .. SizeOF (TCorrBlock128)- 1] of byte absolute CorrBlock;
ArcBlockBuff : Array [0 .. SizeOF (TArcBlock128) - 1] of byte absolute ArcBlock;

CodeLength: Byte;
BitN: Byte;
MaxCodeValue: Word;
ArcDataCount: Word;
NB: Byte;
  Procedure WriteStr (Str: ShortString);
    Var
    i: Integer;
    Begin
      For i := 1 to Length (Str) do
        Begin
          CorrBlock.Data4Arc[OutBuffIdx] := Byte(Str[i]);
          Inc (OutBuffIdx);
        End;

    End;
  Function PopValue: Word;

    Begin
      IF (MAX_FIELD_SIZE - BitN) >= CodeLength
        Then
          Begin
            Result := Word(ArcBlock.ArcData [InBuffIdx] shl BitN) shr (MAX_FIELD_SIZE - CodeLength);
            BitN := BitN + CodeLength;
            If BitN = MAX_FIELD_SIZE
              Then
                Begin
                  Inc (InBuffIdx);
                  BitN := 0;
                End;
          End
        Else
          Begin
            NB := CodeLength-(MAX_FIELD_SIZE-BitN);
            Result := Word (ArcBlock.ArcData [InBuffIdx] shl BitN) shr (BitN - NB);
            Inc (InBuffIdx);
            Result := Result or (ArcBlock.ArcData [InBuffIdx] shr (MAX_FIELD_SIZE - NB));
            BitN := NB;
          End;
      Dec (ArcDataCount);
    End;


  Begin
    InBuffIdx := 0;
    OutBuffIdx := 0;
   IF ArcBlock.BlockHeader.Signature = ArcSign
     Then
       ArcDataCount := ArcBlock.BlockHeader.ArcDataSize
     Else
       ArcDataCount := ArcBlock.BlockHeader.ArcDataCount;

    BitN := 0;

    While ArcDataCount > 0 do
      Begin
        InitTables;
        CurrCode := MAX_CHAR_CODE;

        IF ArcBlock.BlockHeader.Signature = ArcSign
          Then
            CodeLength := MAX_FIELD_SIZE
          Else
            CodeLength := START_FIELD_SIZE;

        MaxCodeValue := MAX_WORD shr (16 - CodeLength);

        Code := PopValue;
        OldCode := Code;

        ChainStr := GetChainStr (Code);
        WriteStr (ChainStr);

//        Dec (ArcDataCount);

        While ArcDataCount > 0 do
          Begin
{            Inc (InBuffIdx);}
            Code := PopValue;{ArcBlock.ArcData [InBuffIdx];}
//            Dec (ArcLength);

            IF Code = MaxCodeValue
              Then
                Begin
                  Inc (CodeLength);
                  MaxCodeValue := MAX_WORD shr (16 - CodeLength);
                  Continue;

                End;

            IF Code = CLEANUP_CODE
              Then
                Break;

            IF Code <= CurrCode // цепочка с таким кодом уже есть в таблице
              Then
                Begin
                  ChainStr := GetChainStr (Code);
                  WriteStr (ChainStr);

                  Inc (CurrCode);
                  Chains[CurrCode].LastChar := ChainStr[1];
                  Chains[CurrCode].PrefixCode := OldCode;

                  OldCode := Code;
                End
              Else
                Begin
                  Inc (CurrCode);

                  Chains[CurrCode].PrefixCode := OldCode;
                  OldChainStr := GetChainStr (OldCode);
                  Chains[CurrCode].LastChar := OldChainStr[1];

                  ChainStr := GetChainStr (Code);
                  WriteStr(ChainStr);
                  OldCode := Code;
                End;

          End;

    End;
  End;

//-----------------------------------------------------------------------------
Procedure ReadArcBlock (HandleIndex: TTraceHandleIndex);
var
i: integer;
  Begin
    With OpenedTraces[HandleIndex] do
      Begin
        For i := 0 to 6 do
          Read(CorrPrimaryFile128, ArcBlock128.BlockHeader.HeaderBuff[i]);

        For i := 0 to ArcBlock128.BlockHeader.ArcDataSize-1 do
          Read (CorrPrimaryFile128, ArcBlock128.ArcData[i]);

        With CorrBlock128.BlockHeader do
          Begin
            Signature := ArcBlock128.BlockHeader.Signature;
            TopSens := ArcBlock128.BlockHeader.TopSens;
            Reserved := '####';
            BaseTime := ArcBlock128.BlockHeader.BaseTime;
            BaseDist := ArcBlock128.BlockHeader.BaseDist;
{$IFDEF Debug}
            WriteLN (FLog, BaseTime, BaseDist);
{$ENDIF}
          End;
      End;
  End;
//-----------------------------------------------------------------------------
Procedure InitTraces;
Var
  i: Integer;
  Begin
    For i := 1 to MAX_OPENED_TRACES do OpenedTraces[i].TraceHandle := -1;
  End;
//-----------------------------------------------------------------------------
Function RegisterNewTrace( TraceHandle: TKrtTraceHandle): Integer;
Var
i  : Integer;
  Begin
    Result := 0 ;
    For i := 1 to MAX_OPENED_TRACES do
        If OpenedTraces[i].TraceHandle = -1
          Then
            Begin
               OpenedTraces[i].TraceHandle := TraceHandle;
               Result := i;
               Break;
            End;
  End;

//-------------------------------------------------------------------------------
Function GetTraceHandleIndex (TraceHandle: TKrtTraceHandle): Integer;
Var
i: Integer;
  Begin
    Result := -1;
    For i := 1 to MAX_OPENED_TRACES do
      Begin
         IF OpenedTraces[i].TraceHandle = TraceHandle
           Then
             Begin
               Result := i;
               Break;
             End;
      End;
  End;

//-------------------------------------------------------------------------------
Function DrvError: PChar; stdcall ;
Begin
  Result := ErrorMsg;
End;

//-----------------------------------------------------------------------------
Procedure CorrFindEntry (TraceHandleIndex: TTraceHandleIndex; Dist: Integer{; CorrEntryKind: TCorrEntryKind});
Var
{CorrIndexRec: TCorrIndexRec;}
CorrIndexRec: TCorrIndexRec;
i: Integer;
SD: Integer;

Left, Right, Middle: Integer;
MV: Integer;
  Begin
    With OpenedTraces[TraceHandleIndex] do
      Begin
        Left := 0;
        Right := CorrIndexRecs-1;

        Repeat
          Middle := Left+(Right - Left) div 2;

{          MV := 0; // чтобы не было warning компилятора}
          Seek (CorrIndexFile, Middle);
          Read (CorrIndexFile, CorrIndexRec);
          MV := CorrIndexRec.Dist;

          IF MV > Dist
            Then
              Right := Middle
            Else
              Left  := Middle;

        Until {(Dist = MV) or} (Right - Left <=1 );

{        IF Dist >= MV + CorrRecsInBlock
          Then
            Left := Right;}


        Seek (CorrIndexFile, Left);
        Read (CorrIndexFile, CorrIndexRec);

        IF Dist >= CorrIndexRec.Dist + CorrRecsInBlock
          Then
            Begin
              Seek (CorrIndexFile, Right);
              Read (CorrIndexFile, CorrIndexRec);
            End;

        Case CorrFormatVersion of
          CF32:
            Begin
              Assign (CorrPrimaryFile32, CorrFileList.Strings[CorrIndexRec.FileNum]);
              Reset  (CorrPrimaryFile32);
              Seek (CorrPrimaryFile32, CorrIndexRec.Offset);
              Read (CorrPrimaryFile32, CorrBlock32);

              CorrCurrFileNum   := CorrIndexRec.FileNum;
{              Convert32toCommon (TraceHandleIndex, CorrBlock32)}
            End;
          CF128:
            Begin
              Assign (CorrPrimaryFile128, CorrFileList.Strings[CorrIndexRec.FileNum]);
              Reset  (CorrPrimaryFile128);
              Seek (CorrPrimaryFile128, CorrIndexRec.Offset);
              ReadArcBlock (TraceHandleIndex);
              DecodeBlock128 (ArcBlock128, CorrBlock128);

              CorrCurrFileNum   := CorrIndexRec.FileNum;
{              Convert128toCommon (TraceHandleIndex, CorrBlock128);}
            End;
          End;

        Case CorrFormatVersion of
          CF32 : SD := CorrBlock32.BlockHeader.BaseDist;
          CF128: SD := CorrBlock128.BlockHeader.BaseDist;
        End;


        For i := 1 to CorrRecsInBlock do
          Begin
            Case CorrFormatVersion of
              CF32 : SD := SD + CorrBlock32.Recs[i].DistOffset;
              CF128: SD := SD + CorrBlock128.DistOffsets[i];
            End;

            IF SD >= Dist
              Then
                Begin
                  CorrDistDiff := SD-Dist;
                  CurrD := SD;
                  IF CorrDistDiff > 0
                    Then
                      Begin
                        CorrCurrRecNum := i - 1;
                        If CorrCurrRecNum = 0
                          Then
                            CorrCurrRecNum := 1;
                      End
                    Else
                      CorrCurrRecNum := i;

                  BreaK;
                End;
          End; // For i
      End;
  End;

//-----------------------------------------------------------------------------
Function DrvRegister (DataFile: PChar;
                      TrcFile : PChar;
                ErrMsgPointer : Pointer;
                   InformUser : TInformUser): Integer; stdcall;

Const
DUMMY_HANDLE = 65535;
Var
i: SmallInt;
TraceHandleIndex: Integer;
IndexFileName: String;
BlocksCount: DWord;
EndOfFile: Boolean;
ROut: TCorrIndexRec;
CorrPrimaryDir: String;
Found: Integer;
SearchRec: TSearchRec;
VogNavName, VogMatName: String;
OldProgress, Progress: Integer;
Begin
  TraceHandleIndex := RegisterNewTrace (DUMMY_HANDLE);
  IF TraceHandleIndex = 0
    Then
      Begin
        ErrorMsg := 'Закройте хотя бы один из открытых прогонов';
        Pointer(ErrMsgPointer^) := ErrorMsg;

        Result := KRT_ERR;
        Exit;
      End;

  With OpenedTraces[TraceHandleIndex] do
    Begin
      CorrPresent     := False;
      CorrFilesOpened := False;
      CorrIndexOpened := False;
      VogNavPresent      := False;
      VogMatPresent      := False;
      VogMatFileOpened   := False;
      VogNavFilesOpened  := False;

      CorrPrimaryDir := ExtractFilePath (DataFile);

      CorrFileList := TStringList.Create;
      CorrFileList.Sorted := True;

      Found := FindFirst (CorrPrimaryDir + CorrPrimaryFilesMask, faAnyFile, SearchRec);
      If Found = 0
        Then
          CorrPresent := True;

      While Found = 0 do
        Begin
          CorrFileList.Add(CorrPrimaryDir + SearchRec.Name);
          Found := FindNext(SearchRec);
        End;
      SysUtils.FindClose (SearchRec);

      Found := FindFirst (CorrPrimaryDir + VogNavFilesMask, faAnyFile, SearchRec);
      If Found = 0
        Then
          Begin
            VogNavPresent := True;
            VogNavName := SearchRec.Name;
          End;

      SysUtils.FindClose (SearchRec);

      Found := FindFirst (CorrPrimaryDir + VogMatFilesMask, faAnyFile, SearchRec);
      If Found = 0
        Then
          Begin
            VogMatPresent := True;
            VogMatName := SearchRec.Name;
          End;

      SysUtils.FindClose (SearchRec);

      IF Not (CorrPresent or VogNavPresent)
        Then
          Begin
            krtCloseTrace (DUMMY_HANDLE);
            ErrorMsg := 'Не найдены первичные файлы';
            Pointer(ErrMsgPointer^) := ErrorMsg;

            Result := KRT_ERR;
            Exit;
          End;

      IF CorrPresent
        Then
          Begin
            CorrFormatVersion := GetCorrFormatVersion (CorrFileList.Strings[0]);

            IndexFileName := ExtractFilePath (DataFile) + CorrIndexFileName;
            AssignFile (CorrIndexFile, IndexFileName);
            ReWrite (CorrIndexFile);
            CorrIndexOpened := True;

            IF CorrFormatVersion = CFUnknown
              Then
                Begin
                  krtCloseTrace (DUMMY_HANDLE);

                  ErrorMsg := 'Неправильный формат первичных файлов';
                  Pointer(ErrMsgPointer^) := ErrorMsg;

                  Result := KRT_ERR;
                  Exit;
                End;

            Progress := 0;
            OldProgress := Progress;

            For i := 1 to CorrFileList.Count do
               Begin
                 Case CorrFormatVersion of
                   CF32:
                     Begin
                       AssignFile (CorrPrimaryFile32, CorrFileList.Strings[i-1]);
                       Reset (CorrPrimaryFile32);
                     End;

                   CF128:
                     Begin
                       AssignFile (CorrPrimaryFile128, CorrFileList.Strings[i-1]);
                       Reset (CorrPrimaryFile128);
                     End;
                 End;

                 CorrFilesOpened := True;
                 EndOFFile := True;

                 Case CorrFormatVersion of
                   CF32 : EndOfFile := EOF (CorrPrimaryFile32);
                   CF128: EndOfFile := EOF (CorrPrimaryFile128);
                 End;

                 BlocksCount := 0;
                 While Not EndOfFile do
                   Begin
                     Case CorrFormatVersion of
                       CF32 :
                         Begin
                           Read (CorrPrimaryFile32, CorrBlock32);
                           IF CorrBlock32.BlockHeader.Signature = Version32Id
                             Then
                               Begin
                                 ROut.Offset  := BlocksCount;
                                 ROut.Dist    := CorrBlock32.BlockHeader.BaseDist;
                                 ROut.Time    := CorrBlock32.BlockHeader.BaseTime;
                                 ROut.TopSens := CorrBlock32.BlockHeader.TopSens;
                                 Inc (BlocksCount);
                               End
                             Else
                               Begin
                                 krtCloseTrace (DUMMY_HANDLE);
                                 ErrorMsg := 'Bad block in one of files';
                                 Pointer(ErrMsgPointer^) := ErrorMsg;

                                 Result := KRT_ERR;
                                 Exit;
                               End;
                         End;
                       CF128:
                         Begin
                           ROut.Offset   := FilePos (CorrPrimaryFile128);
                           ReadArcBlock (TraceHandleIndex);
                           IF ArcBlock128.BlockHeader.Signature > Version32Id
                             Then
                               Begin
                                 ROut.Dist := ArcBlock128.BlockHeader.BaseDist;
                                 ROut.Time := ArcBlock128.BlockHeader.BaseTime;
                                 ROut.TopSens := ArcBlock128.BlockHeader.TopSens;
                               End
                             Else
                               Begin
                                 krtCloseTrace (DUMMY_HANDLE);
                                 ErrorMsg := 'Bad block in one of files';
                                 Pointer(ErrMsgPointer^) := ErrorMsg;

                                 Result := KRT_ERR;
                                 Exit;
                               End;
                         End;
                     End;


                     ROut.FileNum  := i - 1;
                     Rout.Reserved := '########';
                     Write (CorrIndexFile, ROut);


                     Case CorrFormatVersion of
                       CF32 : EndOfFile := eof (CorrPrimaryFile32);
                       CF128: EndOfFile := eof (CorrPrimaryFile128);
                     End;
                   End;

                   Case CorrFormatVersion of
                     CF32 : CloseFile (CorrPrimaryFile32);
                     CF128: CloseFile (CorrPrimaryFile128);
                   End;

                   Progress := Round (i / CorrFileList.Count * 100);
                   If Progress > OldProgress
                     Then
                       Begin
                         InformUser (Progress);
                         OldProgress := Progress;
                       End;
                 End;
             CloseFile (CorrIndexFile);

          End;
    TraceIni := TIniFile.Create(TrcFile);

    IF CorrPresent
      Then
        IF CorrPrimaryDir = ExtractFilePath(TrcFile)
          Then
            TraceIni.WriteString(DRIVER_DATA_SECTION, CORR_PRIMARY_DIR_KEY, '')
           Else
            TraceIni.WriteString(DRIVER_DATA_SECTION, CORR_PRIMARY_DIR_KEY, CorrPrimaryDir);

    IF VogNavPresent
      Then
        IF ExtractFilePath(VogNavName) = ExtractFilePath(TrcFile)
          Then
            TraceIni.WriteString(DRIVER_DATA_SECTION, VOG_NAV_FILE_KEY, '')
          Else
            TraceIni.WriteString(DRIVER_DATA_SECTION, VOG_NAV_FILE_KEY, VogNavName);

    IF VogMatPresent
      Then
        IF ExtractFilePath(VogMatName) = ExtractFilePath(TrcFile)
          Then
            TraceIni.WriteString(DRIVER_DATA_SECTION, VOG_MAT_FILE_KEY, '')
          Else
            TraceIni.WriteString(DRIVER_DATA_SECTION, VOG_MAT_FILE_KEY, VogMatName);

  End; // With OpenedTraces

  Result := KRT_OK;
End;

Procedure SwapByte (Var b1,b2: Byte);
Var
t: Byte;
  Begin
    t := b1;
    b1 := b2;
    b2 := t;
  End;

Procedure SwapInt (Var i1,i2: Integer);
Var
t: Integer;
  Begin
    t := i1;
    i1 := i2;
    i2 := t;
  End;

  //-----------------------------------------------------------------------------
Function DrvFillData (TraceHandle: TKrtTraceHandle;
                       Group : Integer;
                       Start : Integer;
                      Length : Integer;
                      Screen : Pointer;
                      RowData: Pointer
                      ): Integer; stdcall ;
Var
i,L: Integer;
TraceHandleIndex: Integer;
P, SP: Pointer;
D: Integer;
SensPos: Integer;
OverFlow: Boolean;
SensVal: Byte;
PrevCount: Integer;

{DummyFlag: Boolean;
DummyCount: Integer;}
EndOFFile: Boolean;
ThickSum: Integer;
TP: Pointer;
SensCount: Integer;
DummyFlag: Boolean;
//MinThick, MaxThick: Byte;
  Begin

    TraceHandleIndex := GetTraceHandleIndex (TraceHandle);
    If  TraceHandleIndex<0
      Then
        Begin
          ErrorMsg := 'Не найден прогон с таким дескриптором';
          Result := KRT_ERR;
          Exit;
        End
      Else
       With OpenedTraces[TraceHandleIndex] do
        Begin
          IF not CorrFilesOpened
            Then
              CorrFilesOpened := True;

          L := Length {div DIST_DISCRETE};

          IF PThick <> Nil
            Then
              FreeMem (PThick);

          GetMem (PThick, Length * SizeOF (Byte));

          IF (Start-CorrMemCount)>=0
            Then
              PrevCount := CorrMemCount
            Else
              PrevCount := CorrMemCount - Start;

          CorrFindEntry (TraceHandleIndex, Start - PrevCount);

          D := Start;
          CurrD := Start - PrevCount;
          CorrMiddleIndex := 1;
          OverFlow := False;

          Case CorrFormatVersion of
            CF32 : SensCount := CorrSensorsCount32;
            CF128: SensCount := CorrSensorsCount128;
          End;

          For i := 1 to SensCount {CommonBlock.SensorsCount} do
            Begin
              CorrSummes [i] := 0;
            End;

{          MinThick := 255;
          MaxThick := 0;}

          While D<= Start + L - 1 do
            Begin
              Case CorrFormatVersion of
                CF32 : DummyFlag := CorrBlock32.Recs[CorrCurrRecNum].Sensors[16] in CorrDummyValues;
                CF128: DummyFlag := CorrBlock128.Data[CorrCurrRecNum - 1] in CorrDummyValues;
              End;

              IF (CorrFormatVersion = CF128) and SwapSensors
                Then
                  For i := 1 to SensCount do
                    IF (i mod 4) = 0
                      Then
                        Begin
                          SwapByte (CorrBlock128.Data[(i - 4) * CorrRecsInBlock + CorrCurrRecNum - 1],
                                    CorrBlock128.Data[(i - 1) * CorrRecsInBlock + CorrCurrRecNum - 1]);

                          SwapByte (CorrBlock128.Data[(i - 3) * CorrRecsInBlock + CorrCurrRecNum - 1],
                                    CorrBlock128.Data[(i - 2) * CorrRecsInBlock + CorrCurrRecNum - 1]);
                        End;


              For i := 1 to SensCount do
                Begin
                  IF OverFlow
                     Then
                       Begin
                         CorrSummes[i] := CorrSummes [i] - CorrMemSensors [i, 1];
                         Move (CorrMemSensors [i, 2], CorrMemSensors [i, 1], (CorrMemCount-1) * SizeOF (Byte));
                       End;

                  Case CorrFormatVersion of
                    CF32 : CorrMemSensors [i, CorrMiddleIndex] := CorrBlock32.Recs[CorrCurrRecNum].Sensors[i];
                    CF128: CorrMemSensors [i, CorrMiddleIndex] := CorrBlock128.Data[(i - 1) * CorrRecsInBlock + CorrCurrRecNum - 1];
                  End;

                  IF not DummyFlag  or (CorrMiddleIndex = 1)
                    Then
                      Case CorrFormatVersion of
                        CF32 : CorrMemSensors [i, CorrMiddleIndex] := CorrBlock32.Recs[CorrCurrRecNum].Sensors[i];
                        CF128: CorrMemSensors [i, CorrMiddleIndex] := CorrBlock128.Data[(i - 1) * CorrRecsInBlock + CorrCurrRecNum - 1];
                       End
                    Else
                      Begin
                        CorrMemSensors [i, CorrMiddleIndex] := CorrMemSensors [i, CorrMiddleIndex-1];
                        Case CorrFormatVersion of
                          CF32 : CorrBlock32.Recs[CorrCurrRecNum].Sensors[i] := CorrMemSensors [i, CorrMiddleIndex - 1];
                          CF128: CorrBlock128.Data[(i - 1) * CorrRecsInBlock + CorrCurrRecNum - 1] := CorrMemSensors [i, CorrMiddleIndex - 1];
                         End;


    {                   CorrBlock32.Recs[CorrCurrRecNum].Sensors[i] := CorrMemSensors [i, CorrMiddleIndex-1];}
                      End;

                  CorrSummes[i] := CorrSummes [i] + CorrMemSensors [i, CorrMiddleIndex];
                  CorrMiddles[i] := CorrSummes [i] div CorrMiddleIndex;
                End;

                  IF PrevCount = 0
                    Then
                      Begin
                        ThickSum := 0;
                        For i := 1 to SensCount do
                          Begin
                            Case CorrFormatVersion of
                              CF32 : DWord (P) := DWord (Screen) + (i-1) * 4 * L + (D-Start);
                              CF128: DWord (P) := DWord (Screen) + (i-1) * L + (D-Start);
                            End;


                            IF RowDataSupported and (RowData <> Nil)
                              Then
                                DWord (SP) := DWord (RowData) + ((i-1) * Length + (D-Start)) * SizeOF (Integer);

  {                          IF CorrDistDiff > 0
                              Then
                                Begin
                                  SensVal := 0;
                                  Byte(P^):= SensVal;
                                  IF RowDataSupported and (RowData <> Nil)
                                    Then
                                      Integer (SP^) := SensVal;
                                  ThickSum := ThickSum + SensVal;
                                End
                              Else }
  (*                              Begin *)
                             Case CorrFormatVersion of
                               CF32 : SensPos := i + CorrBlock32.BlockHeader.TopSens;
                               CF128: SensPos := i + CorrBlock128.BlockHeader.TopSens;
                             End;


                             IF SensPos > SensCount
                               Then
                                 SensPos := SensPos - SensCount;

                             Case CorrFormatVersion of
                               CF32 : SensVal := CorrBlock32.Recs[CorrCurrRecNum].Sensors[SensPos] - CorrMiddles [SensPos] + CorrAddDelta;
                               CF128: SensVal := CorrBlock128.Data[(SensPos - 1) * CorrRecsInBlock + CorrCurrRecNum - 1] - CorrMiddles [SensPos] + CorrAddDelta;
                             End;

  {                             IF SensVal > 199
                               Then
                                 SensVal := 199;}

                             Byte(P^):= SensVal;
                             IF CorrFormatVersion = CF32
                               Then
                                 Begin
                                   Inc (DWord(P), L);
                                   Byte(P^):= SensVal;
                                   Inc (DWord(P), L);
                                   Byte(P^):= SensVal;
                                   Inc (DWord(P), L);
                                   Byte(P^):= SensVal;
                                 End;


                             IF RowDataSupported and (RowData <> Nil)
                               Then
                                 Case CorrFormatVersion of
                                   CF32 : Integer (SP^) := CorrBlock32.Recs[CorrCurrRecNum].Sensors[SensPos];
                                   CF128: Integer (SP^) := CorrBlock128.Data[(SensPos - 1) * CorrRecsInBlock + CorrCurrRecNum - 1];
                                 End;

                             ThickSum := ThickSum + CorrMiddles [SensPos];
  (*                              End; *)
                         End; // For i
                      DWord (TP) := DWord (PThick) + (D - Start) * SizeOF (Byte);
                      Byte(TP^) := Round(ThickSum / SensCount);

                    End; // PrevCount = 0



              IF CorrDistDiff=0
                Then
                  Begin
                    IF not OverFlow
                      Then
                        Begin
                          Inc (CorrMiddleIndex);
                          If CorrMiddleIndex > CorrMemCount
                            Then
                              Begin
                                CorrMiddleIndex := CorrMemCount;
                                OverFlow := True;
                              End;
                        End;

                    Inc (CorrCurrRecNum);
                    IF CorrCurrRecNum > CorrRecsInBlock
                      Then
                        Begin
                          CorrCurrRecNum := 1;

                          EndOFFile := False;
                          Case CorrFormatVersion of
                            CF32:
                              Begin
                                EndOfFile := EOF (CorrPrimaryFile32);
                              End;
                            CF128:
                              Begin
                                EndOfFile := EOF (CorrPrimaryFile128);
                              End;
                          End;

                          If EndOfFile
                            Then
                              Begin
                                Inc (CorrCurrFileNum);

                                IF CorrCurrFileNum <= CorrFileList.Count-1
                                  Then
                                    Case CorrFormatVersion of
                                      CF32:
                                        Begin
                                          CloseFile (CorrPrimaryFile32);
                                          Assign (CorrPrimaryFile32, CorrFileList.Strings[CorrCurrFileNum]);
                                          Reset (CorrPrimaryFile32);
                                        End;
                                      CF128:
                                        Begin
                                          CloseFile (CorrPrimaryFile128);
                                          Assign (CorrPrimaryFile128, CorrFileList.Strings[CorrCurrFileNum]);
                                          Reset (CorrPrimaryFile128);
                                        End;
                                    End;
                              End;

                          IF CorrCurrFileNum <= CorrFileList.Count-1
                            Then
                              Case CorrFormatVersion of
                                CF32:
                                  Begin
                                    Read (CorrPrimaryFile32, CorrBlock32);
//                                    Convert32toCommon (TraceHandleIndex, CorrBlock32);
                                  End;
                                CF128:
                                  Begin
                                    ReadArcBlock (TraceHandleIndex);
                                    DecodeBlock128 (ArcBlock128, CorrBlock128);
{                                    Convert128toCommon (TraceHandleIndex, CorrBlock128);}
                                  End;
                              End;

                          Case CorrFormatVersion of
                            CF32:
                              Begin
                                CorrDistDiff := CorrBlock32.BlockHeader.BaseDist - CurrD;
                              End;
                            CF128:
                              Begin
                                CorrDistDiff := CorrBlock128.BlockHeader.BaseDist - CurrD;
                              End;
                          End;


//                          CurrD := CommonBlock.BaseDist-1;
                      End;

{                Case CorrFormatVersion of
                  CF32 : CorrDistDiff := CorrBlock32.Recs[CorrCurrRecNum].DistOffset - 1;
                  CF128: CorrDistDiff := CorrBlock128.DistOffsets[CorrCurrRecNum] - 1;
                End;

                IF CorrDistDiff<0
                  Then
                    CorrDistDiff := 0;}
              End;
              IF PrevCount = 0
                Then
                  Inc (D)
                Else
                  Dec (PrevCount);

              IF CorrDistDiff>0
                Then
                  Dec (CorrDistDiff);

              Inc (CurrD);
            End; // While;
          End; // With;
          Result := KRT_OK;
  End;
//-------------------------------------------------------------------------------
Procedure GetTraceMainParams (TraceHandleIndex: TKrtTraceHandle);
Var
N: Integer;
Rec: TVogNavRec;
BytesRead: Integer;
D,T: Integer;
i: Integer;
  Begin
{    TraceHandleIndex := GetTraceHandleIndex (TraceHandle);}

    With OpenedTraces[TraceHandleIndex] do
      Begin
        IF VogMatPresent
          Then
            Begin
              GetFileSize (VogMatTraceHandle, @N);
              N := GetFileSize (VogMatTraceHandle, Nil);
              VogMatTraceRecs   := N div SizeOF (TVogMatRec);
              DWord(VogMatEndPointer) := DWord (VogMatTraceMap) + VogMatTraceRecs * SizeOF (TVogMatRec);
            End;

        IF VogNavPresent
          Then
            Begin
              GetFileSize (VogNavTraceHandle, @N);
              N := GetFileSize (VogNavTraceHandle, Nil);
              VogNavTraceRecs   := N div SizeOF (TVogNavRec);

              DWord(VogNavEndPointer) := DWord(VogNavTraceMap) + VogNavTraceRecs * SizeOF (TVogNavRec);

              SetFilePointer (VogNavTraceHandle, -SizeOF (TVogNavRec), Nil, FILE_END);
              ReadFile (VogNavTraceHandle, Rec, SizeOf (TVogNavRec), BytesRead, Nil);

              TraceLength := Round (Rec.Dist / VogOdomKoeff) * DIST_DISCRETE ;
              TraceTime   := Rec.Time * TIME_DISCRETE;
            End
          Else
            Begin
              Case CorrFormatVersion of
                CF32:
                  Begin
                    AssignFile (CorrPrimaryFile32, CorrFileList.Strings[CorrFileList.Count-1]);
                    Reset (CorrPrimaryFile32);
                    N:=FileSize (CorrPrimaryFile32);
                    Seek (CorrPrimaryFile32, N-1);
                    Read (CorrPrimaryFile32, CorrBlock32);
{                    Convert32toCommon (TraceHandleIndex, CorrBlock32);}

                    CloseFile (CorrPrimaryFile32);
                  End;
               CF128:
                 Begin
                   AssignFile (CorrPrimaryFile128, CorrFileList.Strings[CorrFileList.Count-1]);
                   Reset (CorrPrimaryFile128);

                   While not EOF (CorrPrimaryFile128) do
                     ReadArcBlock (TraceHandleIndex);

                   DecodeBlock128 (ArcBlock128, CorrBlock128);
{                   Convert128toCommon (TraceHandleIndex, CorrBlock128);}

                   CloseFile (CorrPrimaryFile128);
                 End;
              End; // Case CorrFormatVersion


          Case CorrFormatVersion of
            CF32 :
              Begin
                D := CorrBlock32.BlockHeader.BaseDist;
                T := CorrBlock32.BlockHeader.BaseTime;
                For i := 1 to CorrRecsInBlock do
                  D := D + CorrBlock32.Recs[i].DistOffset;
              End;

            CF128:
              Begin
                D := CorrBlock128.BlockHeader.BaseDist;
                T := CorrBlock128.BlockHeader.BaseTime;
                For i := 1 to CorrRecsInBlock do
                  D := D + CorrBlock128.DistOffsets[i];
              End;
          End;


          TraceLength := D * DIST_DISCRETE;
          TraceTime   := T * TIME_DISCRETE;

            End;
    End; // With
  End;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

Function DrvGetFirstNode (TraceHandle: TKrtTraceHandle;
                            Node: PNode;
                           Start: Integer;
                        SensType: Integer;
                       SensIndex: Integer;
                         Length : Integer ;
                     ControlSize: Integer): Integer ; stdcall ;

Var
RecsDiff: Integer;
N: Integer;
{VogRec: TVogRec;}
TraceHandleIndex: Integer;
{BytesRead: Integer;}
SensSource: TSensSource;
VogMatRec: TVogMatRec;

T,D: Integer;
  Begin
{$IFDEF Debug}
    ReadLN (FLog, D, T);
    Node^.Val := T * DIST_DISCRETE;
    Node^.pos := D * DIST_DISCRETE;

    Result := KRT_OK;
    Exit;
{$ENDIF}
    TraceHandleIndex := GetTraceHandleIndex (TraceHandle);
    IF TraceHandleIndex<1
      Then
        Begin
          ErrorMsg := 'Не найден прогон с таким дескриптором';
          Result := KRT_ERR;
          Exit;
        End;

    LastTraceHandleIndex := TraceHandleIndex;

    Case SensType of
      KRT_SENS_TIMER,
      KRT_SENS_ODO,
      KRT_SENS_ORIENT,
      KRT_SENS_THICK: SensSource := CorrSource;
      KRT_SENS_EXT:
                    Case SensIndex of
                      0..5: SensSource := VogSource;
                      Else
                         Begin
                           ErrorMsg := 'Неизвестный индекс датчика';
                           Result := KRT_ERR;
                           Exit;
                         End;
                    End;
        Else
      Begin
        ErrorMsg := 'Неизвестный тип датчика';
        Result := KRT_ERR;
        Exit;
      End;
    End;


    With OpenedTraces[TraceHandleIndex] do
      Begin
        LastSensType  := SensType;
        LastSensIndex := SensIndex;

        Start := Start div DIST_DISCRETE;
        Length := Length div DIST_DISCRETE;
        Case SensSource of
          CorrSource:
            Begin
              IF SensType = KRT_SENS_THICK
                Then
                  Begin
                    IF Length = 0
                      Then
                        Length := 1;

                    IF ControlSize = 0
                      Then
                        ControlSize := 1;

                    IF ScrBuff <> Nil
                      Then
                        FreeMem (ScrBuff);

                    ThickStep := Round (Length / ControlSize);
                    GetMem (ScrBuff, Length * CorrSensorsCount128{CommonBlock.SensorsCount});
                    DrvFillData (TraceHandle, 0, Start , Length, ScrBuff, Nil);
                    Node.Val := GetThickValue (TraceHandleIndex, 0);
                    MemStartDist := Start;
                    CurrThickDist := MemStartDist;
                    MemLength := Length;
                    Node.Pos := Start * DIST_DISCRETE;
                  End
                Else
                  Begin
//                    Start  := Start  div DIST_DISCRETE;
                    CorrFindEntry (TraceHandleIndex, Start);


                    Case SensType of
                      KRT_SENS_TIMER:
                          Case CorrFormatVersion of
                            CF32:
                              Begin
                                Node^.Val := CorrBlock32.BlockHeader.BaseTime * TIME_DISCRETE;
                                Node^.pos := CorrBlock32.BlockHeader.BaseDist * DIST_DISCRETE;
                              End;
                            CF128:
                              Begin
                                Node^.Val := CorrBlock128.BlockHeader.BaseTime * TIME_DISCRETE;
                                Node^.pos := CorrBlock128.BlockHeader.BaseDist * DIST_DISCRETE;
                                IF Node^.pos + 4000> TraceLength
                                  Then
                                    Node^.pos := TraceLength;
                              End;
                          End;
                      KRT_SENS_ODO:
                          Case CorrFormatVersion of
                            CF32:
                              Begin
                                Node^.Val := CorrBlock32.BlockHeader.BaseDist * TIME_DISCRETE;
                                Node^.pos := CorrBlock32.BlockHeader.BaseDist * DIST_DISCRETE;
                              End;
                            CF128:
                              Begin
                                Node^.Val := CorrBlock128.BlockHeader.BaseDist * DIST_DISCRETE;
                                Node^.pos := CorrBlock128.BlockHeader.BaseDist * DIST_DISCRETE;
                              End;
                          End;
                      KRT_SENS_ORIENT:
                          Case CorrFormatVersion of
                            CF32:
                              Begin
                                Node^.Val := CorrBlock32.BlockHeader.TopSens;
                                Node^.pos := CorrBlock32.BlockHeader.BaseDist * DIST_DISCRETE;
                              End;
                            CF128:
                              Begin
                                Node^.Val := CorrBlock128.BlockHeader.TopSens;
                                Node^.pos := CorrBlock128.BlockHeader.BaseDist * DIST_DISCRETE;
                              End;
                          End;
                     end;
                  End;
            End;

      VogSource:
        Begin

//          Start := Start div DIST_DISCRETE;
          N := VogMatFindRecNumber (TraceHandleIndex, Start);
          RecsDiff := VogMatFindRecNumber (TraceHandleIndex, Start + Length) - N;
          IF ControlSize > 0
            Then
              VogMatReadStep := 1 + Trunc(RecsDiff / (ControlSize * 100))
            Else
              VogMatReadStep := 1;

          VogMatCurrFPointer := VogMatTraceMap;
          DWord(VogMatCurrFPointer) := DWord(VogMatCurrFPointer) + SizeOF (TVogMatRec) * N;
          VogMatRec := TVogMatRec (VogMatCurrFPointer^);

          VogMatLastDist := VogMatRec.Dist;

          Case SensType of
            KRT_SENS_EXT:
              Begin
                Case SensIndex of
                  0..2: Node^.Val := Round(VogMatRec.Sensors[SensIndex + 1] * 10);
                  3..5: Node^.Val := Round(VogMatRec.Sensors[SensIndex + 1] * 100);
                End; // Case SensIndex

                Node^.pos := VogMatLastDist * DIST_DISCRETE;
              End;
          End; // Case SensType
        End; // VogSource
      End;
    End; // With OpenedTraces[TraceHandleIndex]
    Result := KRT_OK;
  End;

//-----------------------------------------------------------------------------
Function DrvGetNextNode (TraceHandle: TKrtTraceHandle; Node: PNode): Integer; stdcall ;
Var
TraceHandleIndex: Integer;
VogMatRec: TVogMatRec;
SensSource: TSensSource;
EndOfFile: Boolean;
T,D: DWord;
O: Byte;
  begin
{    TraceHandleIndex := GetTraceHandleIndex (TraceHandle);
    IF TraceHandleIndex<1
      Then
        Begin
          ErrorMsg := 'Не найден прогон с таким дескриптором';
          Result := KRT_ERR;
          Exit;
        End;}

    TraceHandleIndex := LastTraceHandleIndex;

    Case OpenedTraces[TraceHandleIndex].LastSensType of
      KRT_SENS_TIMER,
      KRT_SENS_ODO,
      KRT_SENS_ORIENT,
      KRT_SENS_THICK: SensSource := CorrSource;

      KRT_SENS_EXT:
                    Case OpenedTraces[TraceHandleIndex].LastSensIndex of
                      0..5: SensSource := VogSource;
                      Else
                         Begin
                           ErrorMsg := 'Неизвестный индекс датчика';
                           Result := KRT_ERR;
                           Exit;
                         End;
                    End;
        Else
      Begin
        ErrorMsg := 'Неизвестный тип датчика';
        Result := KRT_ERR;
        Exit;
      End;
    End;

    Case SensSource of
      CorrSource:
        Begin
          With OpenedTraces[TraceHandleIndex] do
            Begin
              IF LastSensType = KRT_SENS_THICK
                Then
                  Begin
                    Inc (CurrThickDist, ThickStep);
                    Node.Val := GetThickValue (TraceHandleIndex, CurrThickDist - MemStartDist);
                    Node.Pos := CurrThickDist * DIST_DISCRETE;
                  End
                Else
                  Begin
                  { Inc (CorrCurrBlockNum);}
                    EndOFFile := False;
                    Case CorrFormatVersion of
                      CF32:
                        EndOfFile := EOF (CorrPrimaryFile32);
                      CF128:
                        EndOfFile := EOF (CorrPrimaryFile128);
                    End;

                    IF EndOfFile
                      Then
                        Begin
                          Inc (CorrCurrFileNum);
                          IF CorrCurrFileNum <= CorrFileList.Count-1
                            Then
                              Case CorrFormatVersion of
                                CF32:
                                  Begin
                                    CloseFile (CorrPrimaryFile32);
                                    Assign (CorrPrimaryFile32, CorrFileList.Strings[CorrCurrFileNum]);
                                    Reset (CorrPrimaryFile32);
                                  End;
                                CF128:
                                  Begin
                                    CloseFile (CorrPrimaryFile128);
                                    Assign (CorrPrimaryFile128, CorrFileList.Strings[CorrCurrFileNum]);
                                    Reset (CorrPrimaryFile128);
                                  End;
                              End;
                        End;

                    IF CorrCurrFileNum <= CorrFileList.Count - 1
                      Then
                        Case CorrFormatVersion of
                          CF32:
                            Begin
                              Read (CorrPrimaryFile32, CorrBlock32);
                              T := CorrBlock32.BlockHeader.BaseTime * TIME_DISCRETE;
                              D := CorrBlock32.BlockHeader.BaseDist * DIST_DISCRETE;
                              O := CorrBlock32.BlockHeader.TopSens;
      //                      Convert32toCommon (TraceHandleIndex, CorrBlock32);
                            End;
                          CF128:
                            Begin
                              ReadArcBlock (TraceHandleIndex);
                              T := ArcBlock128.BlockHeader.BaseTime * TIME_DISCRETE;
                              D := ArcBlock128.BlockHeader.BaseDist * DIST_DISCRETE;
                              O := ArcBlock128.BlockHeader.TopSens;
      //                      DecodeBlock128 (ArcBlock128, CorrBlock128);
      //                      Convert128toCommon (TraceHandleIndex, CorrBlock128);
                            End;
                        End
                      Else
                        Begin
                          NOde^.Val := 0;
                          Node^.Pos := TraceLength + 1;

                          ErrorMsg := 'Конец файла';
                          Result := KRT_ERR;
                          Exit;
                        End;
      //              CorrCurrOrient := CorrCurrBlock.TopSens;

                    Case LastSensType of
                      KRT_SENS_TIMER:
                        Begin
                          Node^.Val := T;
                          Node^.Pos := D;
                        End;
                      KRT_SENS_ODO:
                        Begin
                          Node^.Val := D;
                          Node^.Pos := D;
                        End;
                      KRT_SENS_ORIENT:
                        Begin
                          Node^.Val := O;
                          Node^.Pos := D;
                        End;

                    End;
               End;
           End;           // with
      End;

      VogSource:

        With OpenedTraces[TraceHandleIndex] do
          Begin
            Repeat
              Inc (DWord(VogMatCurrFPointer), SizeOF (TVogMatRec) * VogMatReadStep);

              IF DWord(VogMatCurrFPointer) >= DWord(VogMatEndPointer)
                Then
                  Begin
                    ErrorMsg := 'Достигнут конец трассы';
                    Result := KRT_ERR;
                    Exit;
                  End;

              VogMatRec := TVogMatRec (VogMatCurrFPointer^);

            Until (VogMatRec.Dist <> VogMatLastDist);

            VogMatLastDist := VogMatRec.Dist;

            Case LastSensType of
              KRT_SENS_EXT:
                Begin
                  Case LastSensIndex of
                    0..2: Node^.Val := Round(VogMatRec.Sensors[LastSensIndex + 1] * 10);
                    3..5: Node^.Val := Round(VogMatRec.Sensors[LastSensIndex + 1] * 100);
                  End; // Case SensIndex
              End;
          End; // Case SensType

{            Node^.Pos := Round (VogMatRec.Dist / VogOdomKoeff ) * DIST_DISCRETE;}
            Node^.Pos := VogMatRec.Dist * DIST_DISCRETE;
          End;
       End;
    Result := KRT_OK;
  End;

//-----------------------------------------------------------------------------
Function DrvGetFirstNodeGroup (TraceHandle: TKrtTraceHandle;
                            NodeGroup: PNodeGroup;
                                Start: Integer;
                            SensGroup: Integer;
                               Length: Integer;
                          ControlSize: Integer): Integer ; stdcall ;
Var
N: Integer;
VogNavRec: TVogNavRec;
RecsDiff: Integer;
TraceHandleIndex: Integer;
BytesRead: Integer;
  Begin
    TraceHandleIndex := GetTraceHandleIndex (TraceHandle);
    IF TraceHandleIndex<1
      Then
        Begin
          ErrorMsg := 'Не найден прогон с таким дескриптором';
          Result := KRT_ERR;
          Exit;
        End;

    LastTraceHandleIndex := TraceHandleIndex;


    With OpenedTraces[TraceHandleIndex] do
      Begin

        Start  := Round ((Start  * VogOdomKoeff ) / DIST_DISCRETE);
        Length := Round ((Length  * VogOdomKoeff ) / DIST_DISCRETE);

        N := VogNavFindRecNumber (TraceHandleIndex, Start);
        RecsDiff := VogNavFindRecNumber (TraceHandleIndex, Start + Length) - N;

        IF VogFileAccessMode = UsualMode
          Then
            Begin
              SetFilePointer (VogNavTraceHandle, SizeOF (TVogNavRec) * N, Nil, FILE_BEGIN);
              ReadFile       (VogNavTraceHandle, VogNavRec, SizeOf (TVogNavRec), BytesRead, Nil);
            End
          Else
            Begin
              VogNavCurrFPointer := VogNavTraceMap;
              DWord(VogNavCurrFPointer) := DWord(VogNavCurrFPointer) + SizeOF (TVogNavRec) * N;
              VogNavRec := TVogNavRec (VogNavCurrFPointer^);
            End;

        VogNavCurrFilePos := N;
        VogNavReadStep := 1 + Trunc(RecsDiff / (ControlSize * 10));

        VogNavLastDist := VogNavRec.Dist;


        With NodeGroup^ do
          Begin
             VogPos := Round (VogNavRec.Dist / VogOdomKoeff ) * DIST_DISCRETE;

             VogX := ( VogNavRec.X + GKX0 ) * DIST_DISCRETE;
             VogY := VogNavRec.Y * DIST_DISCRETE;
             VogZ := ( VogNavRec.Z + GKY0 ) * DIST_DISCRETE;

             AccelX := VogNavRec.Psi  ;
             AccelY := VogNavRec.Teta ;
             AccelZ := VogNavRec.Gamma;
          End;
      End;
    Result := KRT_OK;
  End;

//-----------------------------------------------------------------------------
Function DrvGetNextNodeGroup (TraceHandle: TKrtTraceHandle; NodeGroup: PNodeGroup): Integer; stdcall ;
Var
VogNavRec: TVogNavRec;
NewPos: Integer;
TraceHandleIndex: Integer;
BytesRead: Integer;
  begin
{    TraceHandleIndex := GetTraceHandleIndex (TraceHandle);
    IF TraceHandleIndex<1
      Then
        Begin
          ErrorMsg := 'Не найден прогон с таким дескриптором';
          Result := KRT_ERR;
          Exit;
        End;}

    TraceHandleIndex := LastTraceHandleIndex;
    With OpenedTraces[TraceHandleIndex] do
    With NodeGroup^ do
      Begin
        Repeat
          IF VogNavReadStep > 1
            Then
              Begin
                IF VogNavCurrFilePos = VogNavTraceRecs - 1
                  Then
                    Begin
                      ErrorMsg := 'Достигнут конец трассы';
                      Result := KRT_ERR;
                      Exit;
                    End;

                NewPos := VogNavCurrFilePos + (VogNavReadStep-1);
                IF NewPos>VogNavTraceRecs - 1
                  Then
                    NewPos :=VogNavTraceRecs - 1;

                 VogNavCurrFilePos := NewPos;

                 IF VogFileAccessMode = UsualMode
                   Then
                     Begin
                       SetFilePointer (VogNavTraceHandle, SizeOF (TVogNavRec) * NewPos, Nil, FILE_BEGIN);
                       ReadFile  (VogNavTraceHandle, VogNavRec, SizeOf (TVogNavRec), BytesRead, Nil);
                     End
                   Else
                     Begin
                       DWord(VogNavCurrFPointer) := DWord(VogNavTraceMap) + SizeOF (TVogNavRec) * NewPos;
                       VogNavRec := TVogNavRec (VogNavCurrFPointer^);
                     End;
               End
            Else
              Begin
                IF VogFileAccessMode = UsualMode
                  Then
                    ReadFile  (VogNavTraceHandle, VogNavRec, SizeOf (TVogNavRec), BytesRead, Nil)
                  Else
                    Begin
                      IF VogNavCurrFPointer = VogNavEndPointer
                        Then
                          Begin
                            ErrorMsg := 'Достигнут конец трассы';
                            Result := KRT_ERR;
                            Exit;
                          End;
                      Inc (DWord(VogNavCurrFPointer), SizeOF (TVogNavRec));
                      VogNavRec := TVogNavRec (VogNavCurrFPointer^);
                    End;
              End;

        Until (VogNavRec.Dist > VogNavLastDist);

        VogNavLastDist := VogNavRec.Dist;
        VogPos := Round (VogNavRec.Dist / VogOdomKoeff ) * DIST_DISCRETE;

        VogX := ( VogNavRec.X + GKX0 ) * DIST_DISCRETE;
        VogY := VogNavRec.Y * DIST_DISCRETE;
        VogZ := ( VogNavRec.Z + GKY0 ) * DIST_DISCRETE;

        AccelX := VogNavRec.Psi;
        AccelY := VogNavRec.Teta;
        AccelZ := VogNavRec.Gamma;
      End; // With

      Result := KRT_OK
  End;

//////////////////////////////////////////////////////////////////////////
// Функции экспортируемые драйвером
//////////////////////////////////////////////////////////////////////////

Function  krtDriverInfo (Drv: PDrvInfo): Integer; stdcall;
  Begin
    With Drv^ do
      Begin
        ApiVer := KRT_APIVER;
        krtDrvRegister := @DrvRegister;
      End;

    Result := KRT_OK;
  End;
//-----------------------------------------------------------------------------
Function krtCloseTrace (TraceHandle: TKrtTraceHandle): Integer; stdcall ;
Var
TraceHandleIndex: Integer;
  Begin
    TraceHandleIndex := GetTraceHandleIndex (TraceHandle);

    IF TraceHandleIndex < 0
      Then
        Begin
         ErrorMsg := 'Не могу найти прогон с таким дескриптором';
         Result := KRT_ERR;
        End
      Else
        With OpenedTraces[TraceHandleIndex] do
          Begin
            TraceHandle := -1;
{I-} // некрасиво, конечно, зато не надо заводить кучу флагов

            IF VogMatPresent
              Then
                Begin
                  CloseHandle   (VogMatTraceHandle);
                  UnMapViewOfFile(VogMatTraceMap);
                End;

            IF VogNavPresent
              Then
                Begin
                  CloseHandle (VogNavTraceHandle);
                  UnMapViewOfFile(VogNavTraceMap);
                End;

            IF CorrPresent and CorrFilesOpened
              Then
                Begin
                  IF CorrIndexOpened
                    Then
                      CloseFile (CorrIndexFile);

                  IF CorrFilesOpened
                    Then
                      Case CorrFormatVersion of
                        CF32 :
                          CloseFile (CorrPrimaryFile32);
                        CF128:
                          CloseFile (CorrPrimaryFile128);
                      End;
                End;
{I+}
            Result := KRT_OK;
          End;
  End;
//-----------------------------------------------------------------------------
Function krtOpenTrace  (TraceFile: PChar; TraceHandle: TKrtTraceHandle; inf: PTraceInfo; Draft: Integer): Integer; stdcall ;
Var
TraceHandleIndex: Integer;
s: String;
VogMat, VogNav: PChar;
Found: Integer;
SearchRec : TSearchRec ;
MapHandle: Integer;
CorrPrimaryDir: String;
ExtP: ^TExtSens;
i: Integer;
ErrorCode: Dword;
ECStr: String;
ECPChar: PChar;
ErrStr: String;
  Begin
    IF StrLen(TraceFile)>MAX_TRACE_NAME_LENGTH
      Then
        Begin
          ErrorMsg := 'Слишком длинное имя файла описания прогона';
          Result := KRT_ERR;
          Exit;
        End;

    IF Draft<>0
      Then
        Begin
          With inf^ do
            Begin
              krtDrvError := @DrvError;
              krtDrvFillData     := @DrvFillData;

              krtDrvGetFirstNode := @DrvGetFirstNode;
              krtDrvGetNextNode  := @DrvGetNextNode;

              krtDrvGetFirstNodeGroup := @DrvGetFirstNodeGroup;
              krtDrvGetNextNodeGroup  := @DrvGetNextNodeGroup;
            End;
         
          TraceHandleIndex := RegisterNewTrace(TraceHandle);
          IF TraceHandleIndex = 0
            Then
              Begin
                ErrorMsg := 'Слишком много открытых прогонов';
                Result := KRT_ERR;
                Exit;
              End;

          With OpenedTraces[TraceHandleIndex] do
            Begin
              FileMode := 0;

              VogMatPresent := False;
              VogMatFileOpened      := False;

              VogNavPresent         := False;
              VogNavFilesOpened     := False;

              CorrPresent     := False;
              CorrFilesOpened := False;
              CorrIndexOpened := False;

              TraceIni := TIniFile.Create(TraceFile);

              s := TraceIni.ReadString (DRIVER_DATA_SECTION, VOG_NAV_FILE_KEY, '');
              IF Length(s)>MAX_TRACE_NAME_LENGTH
                Then
                  Begin
                    ErrorMsg := 'Слишком длинное имя навигационного VOG-файла';
                    krtCloseTrace (TraceHandle);
                    Result := KRT_ERR;
                    Exit;
                  End;

              VogNavPresent := FileExists(S);

              If VogNavPresent
                Then
                  Begin
                    VogNav := StrNew(PChar(s));

                    VogNavTraceHandle := CreateFile (
                       VogNav,
                       GENERIC_READ,
                       FILE_SHARE_READ,
                       Nil,
                       OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL + FILE_FLAG_SEQUENTIAL_SCAN,
                       0
                       );

                    StrDispose (VogNav);

                    IF VogNavTraceHandle = INVALID_HANDLE_VALUE
                      Then
                        Begin
                          ErrorMsg := 'Не могу открыть первичный VOG-файл';
                          krtCloseTrace (TraceHandle);
                          Result := KRT_ERR;
                          Exit;
                        End;

                    MapHandle := CreateFileMapping (
                        VogNavTraceHandle,
                        Nil,
                        PAGE_READONLY,
                        0,
                        0,
                        Nil);

                    IF MapHandle = INVALID_HANDLE_VALUE
                      Then
                        Begin
                          ErrorCode := GetLastError;
                          ErrStr := 'Не могу вызвать CreateFileMapping' + #13 + 'для первичного VOG-файла'+ #13 +
                                      'Код ошибки: ' + IntToStr(ErrorCode);
                          ErrorMsg := StrAlloc (100);
                          StrPCopy(ErrorMsg, ErrStr);
                          StrDispose (ErrorMsg);

                          krtCloseTrace (TraceHandle);
                          Result := KRT_ERR;
                          Exit;
                        End;

                    VogNavTraceMap := MapViewOfFile (MapHandle,
                                                         FILE_MAP_READ,
                                                         0,
                                                         0,
                                                         0);

                    IF VogNavTraceMap = Nil
                      Then
                        Begin
//                          ErrorCode := GetLastError;
                          ErrStr  := 'Не могу вызвать MapViewOfFile'+#13+ 'для первичного VOG-файла' +
                                      'Код ошибки: ';

                          ErrorMsg := StrAlloc (100);
                          StrPCopy(ErrorMsg, ErrStr);
                          StrDispose (ErrorMsg);

                          krtCloseTrace (TraceHandle);
                          Result := KRT_ERR;
                          Exit;
                        End;

                    VogNavFilesOpened  := True;

                    VogFileAccessMode := FileMapMode;

{                    PigLength := TraceIni.ReadInteger (TRACE_SECTION, PIG_LENGTH_KEY, 0);}

                    s := TraceIni.ReadString  (DRIVER_DATA_SECTION, VOG_ODOM_KOEFF_KEY, '');
                     IF s = ''
                       Then
                         VogOdomKoeff := 1
                       Else
                         Begin
                           Try
                             VogOdomKoeff := StrToFloat (S);
                           Except
                             On EConvertError do
                               Begin
                                 ErrorMsg := 'Неправильно задан коэффициент одометра';
                                 Result := KRT_ERR;
                                 Exit;
                               End;
                            End;
                         End;

                    s := TraceIni.ReadString  (DRIVER_DATA_SECTION, Y0_KEY, '');
                    IF s = ''
                      Then
                        Begin
                          GKY0 := 0;
                      {   ErrorMsg := 'Не задан ключ ' + Y0_KEY + ' в секции ' + DRIVER_DATA_SECTION;
                          Result := KRT_ERR;
                          Exit;}
                        End
                      Else
                        Try
                          GKY0 := StrToInt (S);
                        Except
                          On EConvertError do
                            Begin
                              ErrorMsg := 'Неправильно задан ключ ' + Y0_KEY + ' в секции ' + DRIVER_DATA_SECTION;
                              Result := KRT_ERR;
                              Exit;
                            End;
                         End;

                    s := TraceIni.ReadString  (DRIVER_DATA_SECTION, X0_KEY, '');
                    IF s = ''
                      Then
                        Begin
                          GKX0 := 0;
{                         ErrorMsg := 'Не задан ключ ' + X0_KEY + ' в секции ' + DRIVER_DATA_SECTION;
                          Result := KRT_ERR;
                          Exit;}
                        End
                      Else
                        Try
                          GKX0 := StrToInt (S);
                        Except
                          On EConvertError do
                            Begin
                              ErrorMsg := 'Неправильно задан ключ ' + X0_KEY + ' в секции ' + DRIVER_DATA_SECTION;
                              Result := KRT_ERR;
                              Exit;
                            End;
                         End;
                  End; // VogNavPresent

              s := TraceIni.ReadString (DRIVER_DATA_SECTION, VOG_MAT_FILE_KEY, '');
              IF Length(s) > MAX_TRACE_NAME_LENGTH
                Then
                  Begin
                    ErrorMsg := 'Слишком длинное имя Mat-файла';
                    krtCloseTrace (TraceHandle);
                    Result := KRT_ERR;
                    Exit;
                  End;

              VogMatPresent := FileExists(S);

              IF  VogMatPresent
                Then
                  Begin
                    VogMat := StrNew(PChar(s));

                    VogMatTraceHandle := CreateFile (
                       VogMat,
                       GENERIC_READ,
                       FILE_SHARE_READ,
                       Nil,
                       OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL + FILE_FLAG_SEQUENTIAL_SCAN,
                       0
                       );

                    StrDispose (VogMat);

                    IF VogMatTraceHandle = INVALID_HANDLE_VALUE
                      Then
                        Begin
                          ErrorMsg := 'Не могу открыть первичный VOG-файл';
                          krtCloseTrace (TraceHandle);
                          Result := KRT_ERR;
                          Exit;
                        End;

                    MapHandle := CreateFileMapping (
                        VogMatTraceHandle,
                        Nil,
                        PAGE_READONLY,
                        0,
                        0,
                        Nil);

                    IF MapHandle = INVALID_HANDLE_VALUE
                      Then
                        Begin
                          ErrorCode := GetLastError;
                          ErrStr := 'Не могу вызвать CreateFileMapping' + #13 + 'для первичного mat-файла'+ #13 +
                                      'Код ошибки: ' + IntToStr(ErrorCode);
                          ErrorMsg := StrAlloc (100);
                          StrPCopy(ErrorMsg, ErrStr);
                          StrDispose (ErrorMsg);

                          krtCloseTrace (TraceHandle);
                          Result := KRT_ERR;
                          Exit;
                        End;

                    VogMatTraceMap := MapViewOfFile (MapHandle,
                                                         FILE_MAP_READ,
                                                         0,
                                                         0,
                                                         0);

                    IF VogMatTraceMap = Nil
                      Then
                        Begin
                          ErrorCode := GetLastError;
                          ErrStr := 'Не могу вызвать MapViewOfFile' + #13 + 'для первичного mat-файла'+ #13 +
                                      'Код ошибки: ' + IntToStr(ErrorCode);
                          ErrorMsg := StrAlloc (100);
                          StrPCopy(ErrorMsg, ErrStr);
                          StrDispose (ErrorMsg);

                          krtCloseTrace (TraceHandle);
                          Result := KRT_ERR;
                          Exit;
                        End;

                    VogMatFileOpened  := True;
                  End;

              CorrPrimaryDir := TraceIni.ReadString (DRIVER_DATA_SECTION, CORR_PRIMARY_DIR_KEY, '');

              IF Length(CorrPrimaryDir) > MAX_TRACE_NAME_LENGTH-1
                Then
                  Begin
                    ErrorMsg := 'Слишком длинное имя директории' + #13 + 'c первичными файлами';
                    krtCloseTrace (TraceHandle);
                    Result := KRT_ERR;
                    Exit;
                  End;

             IF CorrPrimaryDir=''
                Then
                  CorrPrimaryDir := ExtractFilePath(TraceFile);

              IF Copy (CorrPrimaryDir,Length(CorrPrimaryDir),1)<>'\'
                Then
                  CorrPrimaryDir := CorrPrimaryDir + '\';

              Found := FindFirst (CorrPrimaryDir + CorrPrimaryFilesMask, faAnyFile, SearchRec);
              SysUtils.FindClose (SearchRec);
              If Found = 0
                Then
                  CorrPresent := True
                Else
                  IF not VogNavPresent
                    Then
                      Begin
                        ErrorMsg := 'Не найдены первичные файлы';
                        Result   := KRT_ERR;
                        krtCloseTrace (TraceHandle);
                        Exit;
                      End;
      //----
              IF CorrPresent
                Then
                  Begin
                    s := TraceIni.ReadString  (DRIVER_DATA_SECTION, SWAP1_KEY, '');
                    IF s = ''
                      Then
                        Begin
                          Swap1 := 0;
                        End
                      Else
                        Try
                          Swap1 := StrToInt (S);
                        Except
                          On EConvertError do
                            Begin
                              ErrorMsg := 'Неправильно задан ключ ' + SWAP1_KEY + ' в секции ' + DRIVER_DATA_SECTION;
                              Result := KRT_ERR;
                              Exit;
                            End;
                         End;

                    s := TraceIni.ReadString  (DRIVER_DATA_SECTION, SWAP2_KEY, '');
                    IF s = ''
                      Then
                        Begin
                          Swap2 := 0;
                        End
                      Else
                        Try
                          Swap2 := StrToInt (S);
                        Except
                          On EConvertError do
                            Begin
                              ErrorMsg := 'Неправильно задан ключ ' + SWAP2_KEY + ' в секции ' + DRIVER_DATA_SECTION;
                              Result := KRT_ERR;
                              Exit;
                            End;
                         End;

                    s := TraceIni.ReadString  (DRIVER_DATA_SECTION, SWAP3_KEY, '');
                    IF s = ''
                      Then
                        Begin
                          Swap3 := 0;
                        End
                      Else
                        Try
                          Swap3 := StrToInt (S);
                        Except
                          On EConvertError do
                            Begin
                              ErrorMsg := 'Неправильно задан ключ ' + SWAP3_KEY + ' в секции ' + DRIVER_DATA_SECTION;
                              Result := KRT_ERR;
                              Exit;
                            End;
                         End;

                    s := TraceIni.ReadString  (DRIVER_DATA_SECTION, SWAP4_KEY, '');
                    IF s = ''
                      Then
                        Begin
                          Swap4 := 0;
                        End
                      Else
                        Try
                          Swap4 := StrToInt (S);
                        Except
                          On EConvertError do
                            Begin
                              ErrorMsg := 'Неправильно задан ключ ' + SWAP4_KEY + ' в секции ' + DRIVER_DATA_SECTION;
                              Result := KRT_ERR;
                              Exit;
                            End;
                         End;


                    SwapSensors := TraceIni.ReadInteger  (DRIVER_DATA_SECTION, NORMAL_SENSORS_ORDER_KEY, 0) = 0;

                    FileMode := 0;
                    IF Not FileExists (CorrPrimaryDir + CorrIndexFileName)
                      Then
                        Begin
                          ErrorMsg := 'Не найден индексный файл коррозионного прогона';
                          krtCloseTrace (TraceHandle);
                          Result := KRT_ERR;
                          Exit;
                        End;

                    CorrFileList := TStringList.Create;
                    CorrFileList.Sorted := True;

                    Found := FindFirst (CorrPrimaryDir + CorrPrimaryFilesMask, faAnyFile, SearchRec);
                    While Found = 0 do
                      Begin
                        CorrFileList.Add(CorrPrimaryDir + SearchRec.Name);
                        Found := FindNext(SearchRec);
                      End;
                    SysUtils.FindClose (SearchRec);

                    CorrCurrFileNum  := 0;

                    CorrFormatVersion := GetCorrFormatVersion (CorrFileList.Strings[0]);
                    IF CorrFormatVersion = CFUnknown
                      Then
                        Begin
                          ErrorMsg := 'Неправильная версия формата коррозионных файлов';
                          Result := KRT_ERR;
                          Exit;
                        End;

                    AssignFile (CorrIndexFile, CorrPrimaryDir + CorrIndexFileName);
                    Reset (CorrIndexFile);
                    CorrIndexRecs := FileSize (CorrIndexFile);

                    {CorrFilesOpened := True;}
                  End;


              With Inf^ do
                Begin
                  IF VogMatPresent
                    Then
                      ExtSensors := ExtSensorsCount
                    Else
                      ExtSensors := 0;

                  IF CorrPresent
                    Then
                      SensGroups := 1
                    Else
                      SensGroups := 0;
                End;
           End; // With OpenedTraces
{$IFDEF Debug}
        AssignFile (FLog, 'd:\Speed.txt');
        Reset (FLog);
{$ENDIF}
        Result := KRT_OK;
        Exit;
      End;  // Draft <> 0


    TraceHandleIndex := GetTraceHandleIndex (TraceHandle);
    With OpenedTraces[TraceHandleIndex] do
      Begin
{        StrCopy (@TraceName, TraceFile);}

    With Inf^ do
      Begin
        AskMetod := SENS_ASK_DIST;  // опрос по дистанции
        StepSize := 10;             // с дискретой 10 мм

        If CorrPresent
          Then
            Begin
              TSensGroup(Group^).SensNum  := CorrSensorsCount128;
              TSensGroup(Group^).SensType := SENS_TYPE_FERR;
              TSensGroup(Group^).MinValue := 0;
              TSensGroup(Group^).MaxValue := 255;

              TSensGroup(Group^).IsRow := 1;
              TSensGroup(Group^).MaxRowVal := $FF;
              TSensGroup(Group^).MinRowVal := 0;
              RowDataSupported := True;
            End;

        IF VogNavPresent
          Then
            VOG := 1                   // поддерживает запросы по ВОГ
          Else
            Vog := 0;


        IF VogMatPresent
          Then
            Begin
              ExtP := Inf^.ExtSens;

              For i := 1 to ExtSensorsCount do
                Begin
                  IF i <= 3
                    Then
                      Begin
                        TExtSens(ExtP^).MinValue := -900;
                        TExtSens(ExtP^).MaxValue := +900;
                      End
                    Else
                      Begin
                        TExtSens(ExtP^).MinValue := -700;
                        TExtSens(ExtP^).MaxValue := +700;
                      End;

                  StrCopy (TExtSens(ExtP^).Name, ExtSensorsNames[i]);

                  Inc (ExtP);
                End;
            End;

        WallThickNum := 1;
        WallThickMin := 0;
        WallThickMax := 255;

        SpeedMin := 0;
        SpeedMax := 100;

        OdoNum  := 1;               // количество одометров
        OdoStep := DIST_DISCRETE;

        TimerNum   := 1;
        TimerStep  := TIME_DISCRETE;

        OrientNum := 1;
        OrientStep := 200 * DIST_DISCRETE;

        PressNum  := 0;
        ShakeNum  := 0;
        TempNum   := 0;
        AngleNum  := 0;

        GetTraceMainParams (TraceHandleIndex);
        Length := OpenedTraces[TraceHandleIndex].TraceLength;
        Time   := OpenedTraces[TraceHandleIndex].TraceTime;
      End;
    Result := KRT_OK;

      End;
  End;

//-----------------------------------------------------------------------------

  // список экспорта
Exports
    krtDriverInfo,
    krtOpenTrace,
    krtCloseTrace;

begin
  InitTraces;
end.
