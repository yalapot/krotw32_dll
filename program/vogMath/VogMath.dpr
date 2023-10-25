library VogMath;
uses
  SysUtils,
  Classes,
  Math,
  IniFIles,
  KrotApi;

{$Define NoDebug}

Const

  TURN_GOR     =         0;
  TURN_VER     =         1;
  COUNT_BEGIN  =         2;
  COUNT_END    =         4;         
  TURN_3D      =         8;

  MATCH_MODE_SHIFT  = 1; // преобразование сдвига
  MATCH_MODE_SCALE  = 2;  // преобразование раст€жени€/сжати€
  MATCH_MODE_ROTATE = 4;  // преобразование поворота

  MATCH_MODE_SIMPLE_ROTATE = 8; // поворот одного прогона



  MaxInt = 2147483647;


  TRACE_SECTION = 'Trace';

  IS_PROFILE_KEY = 'IsProfil';
  PROFILE_PIG_LENGTH_KEY = 'ProfilPigLength';
  ODOM_SHIFT_KEY = 'OdoAngle';
  {$Align off}
Type
  PTurnData = ^TTurnData;
  TTurnData = Record
    Radius: Integer;
    Angle : Single ;
  End;
                                    
  PAddData = ^TAddData;
  TAddData = Record
    Diameter : Integer;
    PigLength: Integer
  End;

  PInitData = ^TInitData;
  TInitData = Record
    isProfil: Integer;
    ProfilPigLength: Integer;
    OdoAngle: Integer
  End;



  TCoordSystems = (EP90, WGS84, PK42);

  TEllipseParamNames = (Ra, alfa);
  TEllipseParams = Array [TCoordSystems, TEllipseParamNames] of Double;

  TGeodeticConvertTypes = (PK42toEP90, EP90toWGS84);
  TGeodeticConvertParamNames = (m, omx, omy, omz, dx, dy, dz);
  TGeodeticConvertParams = Array [TGeodeticConvertTypes, TGeodeticConvertParamNames] of Double;

  PGeoRec = ^TGeoRec;
  TGeoRec = Record
    B: Double;
    L: Double;
    H: Double;
  End;              

{$Align on}
Const
  EP : TEllipseParams = ((6378136, 1/298.25784), (6378137, 1 / 298.257223563), (6378245, 1 / 298.3));
  GCP: TGeodeticConvertParams = ((0, 0, -0.35, -0.66, 25, -141, -80), (-0.12E-6, 0, 0 , -0.16 , -1.1, -0.3, -0.9));
  ro = 206264.8062;

Var
ErrorMsg: PChar; // строка с описанием специфической дл€ данной dll ошибки

StartNode, EndNode: TNodeGroup; // сделаны глобальными, поскольку не уверен в корректности
StartMasterNode, EndMasterNode, // передачи указател€ на переменную, наход€щуюс€ в стеке
StartSlaveNode , EndSlaveNode: TNodeGroup; // (см. использование этих переменных ниже)

ShiftX, ShiftY, ShiftZ: Integer;
ScaleOdom, ScaleAzim: Extended;
AngleAzim: Real;
YDelta: Integer;

RotAngleG: Double;
HandleSlaveG: TKrtTraceHandle;
StartSlaveG, LengthSlaveG: Integer;
ControlSizeG: Integer;
FirstGNMInvoke: Boolean;
MatchModeG: Integer;
MemXG,MemZG, XG, YG, ZG: Integer;

VXMaster, VZMaster,
VXSlave , VZSlave: Extended;

LMaster, LSlave: Extended;
{$IFDEF Debug}
  FLog: TextFile;
{$ENDIF}

IsProfile: Boolean;
ProfilePigLength: Integer;
OdomShift: Double; // расположение оси одометров относительно 0-й ласты
//-----------------------------------------------------------------------------------
{
                 ѕрава€ система координат, прин€та€ в навигации

                                     Y   (высота)

                                  Ќ   ^
                                  ќ   |
                                  –   |
                                  ћ   |
                                  ј   |
                                  Ћ   |
                                  №   |
                                      +----------------------> X      (—евер)
                                     /
                                    /
                                   /
                                  /     плоскость горизонта (азимут)
                                 /
                                / Z
                              |_

                          ( ¬осток )


¬се вычислени€ (преобразовани€ координат и т.п.) выполн€ютс€ в данной системе координат
}

//-----------------------------------------------------------------------------------
// сервисные функции
//

Function Sign (Value: Extended): Integer;
  Begin
    IF Value >0
      Then
        Result := 1
      Else
        IF Value = 0
          Then
            Result := 0
          Else
            Result := -1;
  End;

Function GetAzimAngle (Z,X: Extended): Real;
// вход: координаты вектора (в плоскости горизонта) (0,0)-(Z,X)
// выход: угол в радианах [0..2*PI), отсчитываемый от положительного направлени€
 //        оси Z против часовой стрелки
Type
  TQuadrant = (First, Second, Third, Fourth);
Var
  Q: TQuadrant;
  a: Extended;

Function GetQuadrant (Z,X: Extended): TQuadrant;
  Begin
    IF (Z>=0) and (X>=0) Then
      Begin
        Result := First;
        Exit;
      End;

    IF (Z<0) and (X>=0) Then
      Begin
        Result := Second;
        Exit;
      End;

    IF (Z<0) and (X<0) Then
      Begin
        Result := Third;
        Exit;
      End;

    Result := Fourth;
End;
Begin


  a := ArcCos (Z / Sqrt(Sqr(Z) + Sqr(X)));
  Q := GetQuadrant(Z,X);

  Case Q of
    First,Second:;
    Third, Fourth:  a := 2 * Pi - a;
  End;
  Result := a;

End;

Function GeodeticConvert (Source, Dest: TCoordSystems; r: TGeoRec) : TGeoRec;

Var
  B, L, H: Double;
  dB, dL, dH: Double;
  GCT: TGeodeticConvertTypes;
  e2_S, e2_D, e2, de2: Double;
  MR, NR: Double;
  da, a: Double;
  Function GetGeodeticConvertType (Source, Dest: TCoordSystems): TGeodeticConvertTypes;
    Begin
      IF (Source = PK42) and (Dest = EP90)
        Then
          Result := PK42toEP90
        Else
          Result := EP90toWGS84
    End;

  Begin
    B := r.B;
    L := r.L;
    H := r.H;

    e2_S := 2 * EP[Source, alfa] - IntPower (EP[Source, alfa], 2);
    e2_D := 2 * EP[Dest  , alfa] - IntPower (EP[Dest  , alfa], 2);
    e2  := 0.5 * (e2_S + e2_D);
    de2 := e2_D - e2_S;

    a  := 0.5 * (EP[Source, Ra] + EP[Dest, Ra]);
    da := EP[Dest, Ra] - EP[Source, Ra];

    MR := (a * (1 - e2)) / Sqrt (IntPower (1 - e2 * IntPower (sin(B),2), 3 ));
    NR := a / Sqrt (1 - e2 * IntPower (sin(B),2));

    GCT := GetGeodeticConvertType (Source, Dest);
    dB := ro / (MR + H) *
            ( {[} NR / a * e2 * sin (B) * cos (B) * da
          + (IntPower (NR / a, 2) + 1) * NR * sin (B) * cos (B) * de2 * 0.5
          - (GCP[GCT, dx] * cos (L) + GCP[GCT, dy] * sin (L)) * sin (B)
          + GCP[GCT, dz] * cos (B) {]} )
          - GCP[GCT, omx] * sin (L) * (1 + e2 * cos (2 * B))
          + GCP[GCT, omy] * cos (L) * (1 + e2 * cos (2 * B))
          - ro * GCP[GCT, m] * e2 * sin (B) * cos (B);
    dL := ro / ((NR + H) * cos (B)) * (-GCP[GCT, dx] * sin (L) + GCP[GCT, dy] * cos(L))
          + tan (B) * (1 - e2) * (GCP[GCT, omx] * cos (L) + GCP[GCT, omy] * sin (L)) - GCP[GCT, omz];

    dH := - a / NR * da
          + NR * IntPower (sin (B), 2) * de2 * 0.5
          + (GCP[GCT, dx] * cos (L) + GCP[GCT, dy] * sin (L)) * cos (B)
          + GCP[GCT, dz] * sin (B)
          - NR * e2 * sin (B) * cos (B) * (GCP[GCT, omx] / ro * sin (L) - GCP[GCT, omy] / ro * cos (L))
          + (IntPower (a,2) / NR + H) * GCP[GCT, m];

    dB := dB / ro;
    dL := dL / ro;
    Result.B := (2 * B + dB) * 0.5;
    Result.L := (2 * L + dL) * 0.5;
    Result.H := H + dH;
  End;

Function GK2PK42 (x, y: Double): TGeoRec;
Var
{  X,Y: Double;}
  dl, B0, dB, Beta, z0: Double;
  n: Integer;


  Begin
    n := Trunc (y * (1e-6));
    Beta := x / 6367558.4968;
    B0 := Beta + sin (2 * Beta) * (0.00252588685
                                 - 0.00001491860 * IntPower (sin (Beta), 2)
                                 + 0.00000011904 * IntPower (sin (Beta), 4));

    z0 := (y - (10 * n + 5) * 1E5) / 6378245 * cos (b0);
    dB := -IntPower (z0, 2) * sin (2 * B0) *
          (  0.251684631
           - 0.003369263 * IntPower (sin (B0), 2)
           + 0.000011276 * IntPower (sin (B0), 4)
           - IntPower (z0, 2) *
              (  0.10500614 -
               - 0.04559916 * IntPower (sin (B0), 2)
               + 0.00228901 * IntPower (sin (B0), 4)
               + 0.00002978 * IntPower (sin (B0), 6)
               - IntPower (z0, 2) *
                  (  0.042858
                   - 0.025318 * IntPower (sin (B0), 2)
                   + 0.014346 * IntPower (sin (B0), 4)
                   - 0.001264 * IntPower (sin (B0), 6)
                   - IntPower (z0, 2) *
                      (  0.01672
                       - 0.00630 * IntPower (sin (B0), 2)
                       + 0.01188 * IntPower (sin (B0), 4)
                       - 0.00328 * IntPower (sin (B0), 6) ))));


    dl := z0 * (  1
               - 0.0033467108 * IntPower (sin (B0), 2)
               - 0.0000056002 * IntPower (sin (B0), 4)
               - 0.0000000187 * IntPower (sin (B0), 6)
               - IntPower (z0, 2) *
                  (  0.16778075
                   + 0.16273586 * IntPower (sin (B0), 2)
                   - 0.00052490 * IntPower (sin (B0), 4)
                   - 0.00000846 * IntPower (sin (B0), 6)
                   - IntPower (z0, 2) *
                      (  0.0420025
                       + 0.1487407 * IntPower (sin (B0), 2)
                       + 0.0059420 * IntPower (sin (B0), 4)
                       - 0.0000150 * IntPower (sin (B0), 6)
                       - IntPower (z0, 2) *
                          (  0.01225
                           + 0.09477 * IntPower (sin (B0), 2)
                           + 0.03282 * IntPower (sin (B0), 4)
                           - 0.00034 * IntPower (sin (B0), 6)
                           - IntPower (z0, 2) *
                              (  0.0038
                               + 0.0524 * IntPower (sin (B0), 2)
                               + 0.0482 * IntPower (sin (B0), 4)
                               + 0.0032 * IntPower (sin (B0), 6) )))));

    TGeoRec(Result).B := b0 + dB;
    TGeoRec(Result).L := 6 * (n-0.5) / 57.29577951 + dl;
    TGeoRec(Result).H := 0;
  End;

//-----------------------------------------------------------------------------------
// внешние функции

Function krotError32 (OutStr: PChar): Integer; stdcall; external 'krotw32.dll' name 'krotError' ;
Function krotGetFirstNodeGroup (Handle   : TKrtTraceHandle;
                                NodeGroup: PNodeGroup;
                                    Start: Integer;
                                SensGroup: Integer;
                                   Length: Integer;
                              ControlSize: Integer): Integer; stdcall ;external 'krotw32.dll';
Function krotGetNextNodeGroup (Handle: TKrtTraceHandle; NodeGroup: PNodeGroup): Integer; stdcall ; external 'krotw32.dll';
//-----------------------------------------------------------------------------------------------------
// —л€пано по необходимости
Function krtGetAddData (Handle: TKrtTraceHandle; AddData: PAddData): Integer; stdcall ; external 'vogcorrj.dll';
//-----------------------------------------------------------------------------------------------------
// экспортируемые функции

Function krotError (OutStr: PChar): Integer; stdcall
  Begin
    If ErrorMsg<>''         // ошибка внутри данной DLL
      Then
        Begin
          StrCopy (ErrorMsg, OutStr);
          Result := StrLen (ErrorMsg);
        End
      Else
        Result := krotError32 (OutStr);

  End;

//**************************************************************************
Function GetWGS84Coordinates (X,Y,Z: Integer; WGS: PGeoRec): Integer ; stdcall;
Var
  GR: TGeoRec;
  Begin
    Gr := GK2PK42 (Y, X);

    Gr.H := 0;
    Gr := GeodeticConvert (PK42, EP90, gr);
    Gr.H := 0;
    Gr := GeodeticConvert (PK42, EP90, gr);

    Gr.H := 0;
    Gr := GeodeticConvert (EP90, WGS84, gr);
    Gr.H := 0;
    Gr := GeodeticConvert (EP90, WGS84, gr);


    WGS^.B := Gr.B;
    WGS^.L := Gr.L;
    WGS^.H := Z;

    Result := KRT_OK;
  End;
//**************************************************************************
Function GetCurveData (Handle    : TkrtTraceHandle;
                       CalcType  : Integer;
                       TurnKind  : Integer;
                       Start     : Integer;
                       Length    : Integer;
                       Diameter  : Integer;
                       PigLength : Integer;
                       TurnInf   : PTurnData): Integer ; stdcall;

Var
StartD, EndD: Integer ;
RDouble: Double;
DistBefore, DistAfter: Integer;
Begin
{$IFDEF Debug}
  AssignFile (FLog, 'D:\VogMath.log');
  Append (FLog);
{$ENDIF}
  IsProfile := CalcType = 1;

   ErrorMsg := '';
   IF Length>=0
     Then
       Begin
         StartD := Start;
         EndD   := Start+Length;
       End
     Else
       Begin
         StartD := Start+Length;
         EndD   := Start;
       End;

   IF IsProfile
     Then
        DistBefore := 0
     Else
       IF (TurnKind and COUNT_BEGIN) <> 0
         Then
           DistBefore := PigLength
         Else
           DistBefore := 0;

   IF IsProfile
     Then
        DistAfter := 0
     Else
       IF (TurnKind and COUNT_END) <> 0
         Then
           DistAfter := PigLength
         Else
           DistAfter := 0;

   IF krotGetFirstNodeGroup (Handle, @StartNode, StartD - DistBefore , KRT_SENS_VOG, Abs(Length), 100)<>KRT_OK
     Then
       Begin
         Result := KRT_ERR;
         Exit;
       End;

   IF krotGetFirstNodeGroup (Handle, @EndNode, EndD + DistAfter, KRT_SENS_VOG, Abs(Length), 100)<>KRT_OK
     Then
       Begin
         Result := KRT_ERR;
         Exit;
       End;


   IF (TurnKind and TURN_3D) = 0
     Then
       Begin
         IF TurnKind and TURN_VER = TURN_GOR
           Then
             TurnInf^.Angle  := EndNode.AccelX - StartNode.AccelX // горизонтальный поворот
           Else
             TurnInf^.Angle := {Abs (} EndNode.AccelY-StartNode.AccelY{) * Sign (EndNode.VOGY - StartNode.VOGY)};
        End
      Else
        Begin
          TurnInf^.Angle := ArcTan (Sqrt ( Sqr(Tan(EndNode.AccelX - StartNode.AccelX)) +
                                           Sqr(Tan(EndNode.AccelY-StartNode.AccelY))));
        End;
{$IFDEF Debug}
   WriteLN (FLog, 'TurnKind = ', TurnKind, ' , Start = ',StartD, ' , End = ',EndD,
                  ', Angle = ', TurnInf^.Angle);
{$ENDIF}

   IF TurnInf^.Angle = 0
     Then
       TurnInf^.Angle := 0.0001;

   TurnInf^.Radius := 0;

   IF IsProfile
     Then
       Length := Length - ProfilePigLength;

   RDouble := Length / Abs(TurnInf^.Angle) - ({AddData.} Diameter/2)*Abs(sin (StartNode.AccelZ+OdomShift));
   IF RDouble < MaxInt
     Then
       TurnInf^.Radius := Round(RDouble)
     Else
       TurnInf^.Radius := MaxInt;
{$IFDEF Debug}
  CloseFile (FLog);
{$ENDIF}

  Result := KRT_OK;
End;

//******************************************************************************
Function InitMatching (RotAngle : Double;

                       HandleMaster: TkrtTraceHandle;
                       StartMaster : Integer;
                       LengthMaster: Integer;

                       HandleSlave : TkrtTraceHandle;
                       StartSlave  : Integer;
                       LengthSlave : Integer;

                       ControlSize : Integer;
                       MatchMode   : Integer): Integer ; stdcall ;

Var
Xnew,Znew,X,Z: Integer;

Begin
  ErrorMsg := '';
  IF HandleSlave=-1
    Then
      Begin
        FirstGNMInvoke := True;
        RotAngleG    := -RotAngle;
        HandleSlaveG := HandleMaster;
        StartSlaveG  := StartMaster;
        LengthSlaveG := LengthMaster;
        ControlSizeG := ControlSize;

        MatchModeG   := MATCH_MODE_SIMPLE_ROTATE;
      End
    Else
      Begin
        IF LengthMaster<0
          Then
            Begin
              LengthMaster := Abs (LengthMaster);
              StartMaster  := StartMaster - LengthMaster;
            End;

        IF krotGetFirstNodeGroup (HandleMaster, @StartMasterNode, StartMaster , KRT_SENS_VOG, LengthMaster, ControlSize)<>KRT_OK
          Then
            Begin
              Result := KRT_ERR;
              Exit;
            End;


        IF krotGetFirstNodeGroup (HandleMaster, @EndMasterNode, StartMaster+LengthMaster , KRT_SENS_VOG, LengthMaster, ControlSize)<>KRT_OK
          Then
            Begin
              Result := KRT_ERR;
              Exit;
            End;

        IF LengthSlave<0
          Then
            Begin
              LengthSlave := Abs (LengthSlave);
              StartSlave  := StartSlave - LengthSlave;
            End;

        IF krotGetFirstNodeGroup (HandleSlave, @StartSlaveNode, StartSlave , KRT_SENS_VOG, LengthSlave, ControlSize)<>KRT_OK
          Then
            Begin
              Result := KRT_ERR;
              Exit;
            End;

        IF krotGetFirstNodeGroup (HandleSlave, @EndSlaveNode, StartSlave+LengthSlave , KRT_SENS_VOG, LengthSlave, ControlSize)<>KRT_OK
          Then
            Begin
              Result := KRT_ERR;
              Exit;
            End;

      // чтобы избежать использовани€ функции типа "GetFirstMatching"
         FirstGNMInvoke := True;
         HandleSlaveG := HandleSlave;
         StartSlaveG  := StartSlave;
         LengthSlaveG := LengthSlave;
         ControlSizeG := ControlSize;
         MatchModeG   := MatchMode;

         IF (MatchMode and MATCH_MODE_SHIFT)<>0
           Then
             begin
               ShiftY := StartMasterNode.VOGY - StartSlaveNode.VOGY;
               If RotAngle = 0
                 Then
                   Begin
                     ShiftX := StartMasterNode.VOGX - StartSlaveNode.VOGX;
                     ShiftZ := StartMasterNode.VOGZ - StartSlaveNode.VOGZ;
                   End
                 Else
                   Begin
                     Z := StartMasterNode.VOGZ-MemZG;
                     X := StartMasterNode.VOGX-MemXG; // переходим к системе координат с центром в (ZG,XG);

                     Znew := Round( Z*Cos(RotAngleG) + X*Sin(RotAngleG));
                     Xnew := Round(-Z*Sin(RotAngleG) + X*Cos(RotAngleG));

                     ShiftX := (XNew+MemXG) - StartSlaveNode.VOGX;
                     ShiftZ := (ZNew+MemZG) - StartSlaveNode.VOGZ;
                   End
             end
           Else
             begin
               ShiftX := 0;
               ShiftY := 0;
               ShiftZ := 0;
             end;

         IF ((MatchMode and (MATCH_MODE_SCALE or MATCH_MODE_ROTATE)) <> 0)
           Then
             begin
               VXMaster := EndMasterNode.VOGX - StartMasterNode.VOGX;
      //         VYMaster := EndMasterNode.VOGY - StartMasterNode.VOGY;
               VZMaster := EndMasterNode.VOGZ - StartMasterNode.VOGZ;

               VXSlave := EndSlaveNode.VOGX - StartSlaveNode.VOGX;
      //         VYSlave := EndSlaveNode.VOGY - StartSlaveNode.VOGY;
               VZSlave := EndSlaveNode.VOGZ - StartSlaveNode.VOGZ;

               YDelta    := EndMasterNode.VOGY - EndSlaveNode.VOGY - ShiftY;
                            // полагаем, что величина расхождени€ по Y
                            // мен€етс€ линейно в зависимости от пути/времени
             end;

         IF (MatchMode and MATCH_MODE_SCALE)<>0
           Then
             begin
               LMaster := VXMaster * VXMaster + VZMaster * VZMaster;
               LSlave  := VXSlave * VXSlave + VZSlave * VZSlave ;

               ScaleOdom := LengthMaster / LengthSlave;
               ScaleAzim := Sqrt (LMaster / LSlave);
             end
               Else
             Begin
               ScaleOdom := 1;
               ScaleAzim := 1;
             End;

         IF (MatchMode and MATCH_MODE_ROTATE)<>0
           Then
             begin
               AngleAzim := GetAzimAngle (Round(VZSlave), Round(VXSlave)) - GetAzimAngle (Round(VZMaster),Round(VXMaster));
                            // в случае поворота по часовой стрелке Slave->Master
                            // угол должен быть положительным, в противном случае - отрицательным

               AngleAzim := AngleAzim - RotAngle;
             end
           Else
             Begin
               AngleAzim := 0;
               YDelta := 0;
             end;
     End;
   Result := KRT_OK;
End;

//**************************************************************************
Function GetNextMatching (Node: PNodeGroup): Integer; stdcall ;
Var
Xnew,Znew,X,Z: Integer;
  Begin
    IF MatchModeG=MATCH_MODE_SIMPLE_ROTATE
      Then
        Begin
          IF FirstGNMInvoke
            Then
              Begin
                IF krotGetFirstNodeGroup (HandleSlaveG, Node, StartSlaveG , KRT_SENS_VOG, LengthSlaveG, ControlSizeG)<>KRT_OK
                  Then
                    Begin
                      Result := KRT_ERR;
                      Exit;
                    End
                  Else
                    Begin
                      XG := Node^.VOGX;
                      YG := Node^.VOGY;
                      ZG := Node^.VOGZ;

                      MemXG := XG;
                      MemZG := ZG;

                      FirstGNMInvoke := False;
                    End;
              End
            Else
              Begin
                IF krotGetNextNodeGroup (HandleSlaveG, Node)<>KRT_OK
                  Then
                    Begin
                      Result := KRT_ERR;
                      Exit;
                    End
                  Else
                    Begin

                      Z := Node^.VOGZ-ZG;
                      X := Node^.VOGX-XG; // переходим к системе координат с центром в (ZG,XG);


                      Znew := Round( Z*Cos(RotAngleG) + X*Sin(RotAngleG));
                      Xnew := Round(-Z*Sin(RotAngleG) + X*Cos(RotAngleG));

                      Node^.VOGZ := Znew+ZG;
                      Node^.VOGX := Xnew+XG;
                    End;
              End;

        End
          Else
        Begin
          IF FirstGNMInvoke
            Then
              Begin
                IF krotGetFirstNodeGroup (HandleSlaveG, Node, StartSlaveG , KRT_SENS_VOG, LengthSlaveG, ControlSizeG)<>KRT_OK
                  Then
                    Begin
                      Result := KRT_ERR;
                      Exit;
                    End
                  Else
                    Begin
                      XG := Node^.VOGX+ShiftX; // координаты совмещенного начала участка
                      YG := Node^.VOGY+ShiftY;
                      ZG := Node^.VOGZ+ShiftZ;
                      FirstGNMInvoke := False;
                    End;
              End
            Else
              Begin
                IF krotGetNextNodeGroup (HandleSlaveG, Node)<>KRT_OK
                  Then
                    Begin
                      Result := KRT_ERR;
                      Exit;
                    End
               End;


            IF (MatchModeG and MATCH_MODE_SHIFT)<>0
              Then
                Begin
                  Node^.VOGX := Node^.VOGX + ShiftX;
                  Node^.VOGY := Node^.VOGY + ShiftY;
                  Node^.VOGZ := Node^.VOGZ + ShiftZ;
                End;

            IF (MatchModeG and MATCH_MODE_SCALE)<>0
              Then
                Begin
                  Node^.VOGX := Round (XG + (Node^.VOGX-XG) * ScaleAzim);
                  Node^.VOGZ := Round (ZG + (Node^.VOGZ-ZG) * ScaleAzim);
                End;

            IF (MatchModeG and MATCH_MODE_ROTATE)<>0
              Then
                Begin
                  Node^.VOGY := Round (Node^.VOGY + ((Node^.VOGPos - StartSlaveG) / LengthSlaveG) * YDelta);

                  Z := Node^.VOGZ-ZG;
                  X := Node^.VOGX-XG; // переходим к системе координат с центром в (ZG,XG);


                  Znew := Round( Z*Cos(AngleAzim) + X*Sin(AngleAzim));
                  Xnew := Round(-Z*Sin(AngleAzim) + X*Cos(AngleAzim));

                  Node^.VOGZ := Znew+ZG;
                  Node^.VOGX := Xnew+XG;
               End;
       End;
    Result := KRT_OK;
  End;

Function Init (InitData: PInitData): Integer; stdcall;
Var
s: String;
Trc: TIniFile;
  Begin
    IsProfile := InitData.isProfil <> 0;     // дл€ совместимости со старыми верси€ми " рота"
    OdomShift := InitData.OdoAngle / 180 * pi;
    IF IsProfile
      Then
        Begin
          ProfilePigLength := InitData.ProfilPigLength;
        End;
{
    Trc := TIniFile.Create(TrcPath);
    OdomShift := Trc.ReadFloat (TRACE_SECTION, ODOM_SHIFT_KEY, -60) / 180 * pi; // -pi/3 по умолчанию

    IsProfile := Trc.ReadInteger(TRACE_SECTION, IS_PROFILE_KEY, 0) = 1;
    IF IsProfile
      Then
        Begin
          ProfilePigLength := Trc.ReadInteger (TRACE_SECTION, PROFILE_PIG_LENGTH_KEY, 0);
        End;
}
    Result := KRT_OK;
  End;

//-------------------------------------------------------------------------------------
Exports
krotError,
GetWGS84Coordinates,
GetCurveData,
InitMatching,
GetNextMatching,
Init;


begin
{$IFDEF Debug}
  AssignFile (FLog, 'D:\VogMath.log');
  ReWrite (FLog);
  CloseFile (FLog);
{$ENDIF}
  IsProfile := False;     // дл€ совместимости со старыми верси€ми " рота"
  ProfilePigLength := 0;  //
  OdomShift := (-60) * pi / 180;
end.
