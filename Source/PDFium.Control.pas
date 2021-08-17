﻿unit PDFium.Control;

interface

uses
  Winapi.Messages, Winapi.Windows, System.Classes, System.Math, System.SysUtils, System.Variants, Vcl.Controls,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Forms, Vcl.Graphics, Vcl.StdCtrls, PDFiumCore, PDFiumLib
{$IFDEF ALPHASKINS}, acSBUtils, sCommonData{$ENDIF};

type
  TPDFZoomMode = (smActualSize, smFitHeight, smFitWidth, smPercent);

  TSelectionArray = TArray<TPDFRect>;
  TPDFControlRectArray = array of TRect;
  TPDFControlPDFRectArray = array of TPDFRect;

  TPDFControlScrollEvent = procedure(const ASender: TObject; const AScrollBar: TScrollBarKind) of object;

  TPageInfo = record
    Height: Single;
    Index: Integer;
    Rect: TRect;
    Rotation: TPDFPageRotation;
    Visible: Integer;
    Width: Single;
  end;

  { Page is not a public property in core class }
  TPDFPageHelper = class helper for PDFiumCore.TPDFPage
    function Page: FPDF_PAGE;
  end;

  TPDFiumControl = class(TScrollingWinControl)
  strict private
    FAllowTextSelection: Boolean;
    FChanged: Boolean;
    FFilename: string;
    FFormFieldFocused: Boolean;
    FFormOutputSelectedRects: TPDFRectArray;
    FHeight: Single;
    FMouseDownPoint: TPoint;
    FMousePressed: Boolean;
    FOnPaint: TNotifyEvent;
    FOnScroll: TPDFControlScrollEvent;
    FPageBorderColor: TColor;
    FPageCount: Integer;
    FPageIndex: Integer;
    FPageInfo: TArray<TPageInfo>;
    FPageMargin: Integer;
    FPDFDocument: TPDFDocument;
    FPrintJobTitle: string;
{$IFDEF ALPHASKINS}
    FScrollWnd: TacScrollWnd;
{$ENDIF}
    FSelectionActive: Boolean;
    FSelectionStartCharIndex: Integer;
    FSelectionStopCharIndex: Integer;
{$IFDEF ALPHASKINS}
    FSkinData: TsScrollWndData;
{$ENDIF}
    FWebLinksRects: array of TPDFControlPDFRectArray;
    FWidth: Single;
    FZoomMode: TPDFZoomMode;
    FZoomPercent: Single;
    function DeviceToPage(const X, Y: Integer): TPDFPoint;
    function GetCurrentPage: TPDFPage;
    function GetPageIndexAt(const APoint: TPoint): Integer;
    function GetSelectionLength: Integer;
    function GetSelectionRects: TPDFControlRectArray;
    function GetSelectionStart: Integer;
    function GetSelectionText: string;
    function GetWebLinkIndex(const X, Y: Integer): Integer;
    function InternPageToDevice(const APage: TPDFPage; const APageRect: TPDFRect; const ARect: TRect): TRect;
    function IsPageValid: Boolean;
    function IsWebLinkAt(const X, Y: Integer): Boolean; overload;
    function IsWebLinkAt(const X, Y: Integer; var AURL: string): Boolean; overload;
    function PageHeightZoomPercent: Single;
    function PageWidthZoomPercent: Single;
    function SelectWord(const ACharIndex: Integer): Boolean;
    function SetSelStopCharIndex(const X, Y: Integer): Boolean;
    procedure AdjustPageInfo;
    procedure AdjustZoom;
    procedure DoSizeChanged;
    procedure FormFieldFocus(ADocument: TPDFDocument; AValue: PWideChar; AValueLen: Integer; AFieldFocused: Boolean);
    procedure FormGetCurrentPage(ADocument: TPDFDocument; var APage: TPDFPage);
    procedure FormOutputSelectedRect(ADocument: TPDFDocument; APage: TPDFPage; const APageRect: TPDFRect);
    procedure GetPageWebLinks;
    procedure InvalidateRectDiffs(const AOldRects, ANewRects: TPDFControlRectArray);
    procedure OnLoad;
    procedure PageChanged;
    procedure PaintAlphaSelection(ADC: HDC; const APage: TPDFPage; const ARects: TPDFRectArray; const AIndex: Integer);
    procedure PaintPage(ADC: HDC; const APage: TPDFPage; const AIndex: Integer);
    procedure PaintPageBorder(ADC: HDC; const ARect: TRect);
    procedure PaintPageSelection(ADC: HDC; const APage: TPDFPage; const AIndex: Integer);
    procedure SetPageCount(const AValue: Integer);
    procedure SetPageNumber(const AValue: Integer);
    procedure SetScrollSize;
    procedure SetSelection(const AActive: Boolean; const AStartIndex, AStopIndex: Integer);
    procedure SetZoomMode(const AValue: TPDFZoomMode);
    procedure SetZoomPercent(const AValue: Single);
    procedure UpdatePageIndex;
    procedure WebLinkClick(const AURL: string);
    procedure WMEraseBkGnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var AMessage: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var AMessage: TWMHScroll); message WM_HSCROLL;
    procedure WMPaint(var AMessage: TWMPaint); message WM_PAINT;
    procedure WMVScroll(var AMessage: TWMVScroll); message WM_VSCROLL;
  protected
    function DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean; override;
    function GetPageNumber: Integer;
    function GetPageTop(const APageIndex: Integer): Integer;
    function PageToScreen(const AValue: Single): Integer; inline;
    function ZoomToScreen: Single;
//{$IFDEF ALPHASKINS}
    procedure Loaded; override;
//{$ENDIF}
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(AShift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer); override;
    procedure PaintWindow(ADC: HDC); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IsTextSelected: Boolean;
//{$IFDEF ALPHASKINS}
    procedure AfterConstruction; override;
//{$ENDIF}
    procedure ClearSelection;
    procedure CloseDocument;
    procedure CopyToClipboard;
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure GotoNextPage;
    procedure GotoPage(const AIndex: Integer);
    procedure GotoPreviousPage;
    procedure LoadFromFile(const AFilename: string);
    procedure LoadFromStream(const AStream: TStream);
    procedure Print;
    procedure RotatePageClockwise;
    procedure RotatePageCounterClockwise;
    procedure SelectAll;
    procedure SelectText(const ACharIndex: Integer; const ACount: Integer);
    procedure SetFocus; override;
    procedure ZoomToHeight;
    procedure ZoomToWidth;
    procedure Zoom(const APercent: Single);
{$IFDEF ALPHASKINS}
    procedure WndProc(var AMessage: TMessage); override;
{$ENDIF}
    property CurrentPage: TPDFPage read GetCurrentPage;
    property Filename: string read FFilename write FFilename;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnScroll: TPDFControlScrollEvent read FOnScroll write FOnScroll;
    property PageCount: Integer read FPageCount;
    property PageIndex: Integer read FPageIndex;
    property PageNumber: Integer read GetPageNumber write SetPageNumber;
    property SelectionLength: Integer read GetSelectionLength;
    property SelectionStart: Integer read GetSelectionStart;
    property SelectionText: string read GetSelectionText;
{$IFDEF ALPHASKINS}
    property SkinData: TsScrollWndData read FSkinData write FSkinData;
{$ENDIF}
  published
    property AllowTextSelection: Boolean read FAllowTextSelection write FAllowTextSelection default True;
    property Color;
    property PageBorderColor: TColor read FPageBorderColor write FPageBorderColor default clSilver;
    property PageMargin: Integer read FPageMargin write FPageMargin default 6;
    property PopupMenu;
    property PrintJobTitle: string read FPrintJobTitle write FPrintJobTitle;
    property ZoomMode: TPDFZoomMode read FZoomMode write SetZoomMode default smActualSize;
    property ZoomPercent: Single read FZoomPercent write SetZoomPercent;
  end;

  TPDFDocumentVclPrinter = class(TPDFDocumentPrinter)
  private
    FBeginDocCalled: Boolean;
    FPagePrinted: Boolean;
  protected
    function GetPrinterDC: HDC; override;
    function PrinterStartDoc(const AJobTitle: string): Boolean; override;
    procedure PrinterEndDoc; override;
    procedure PrinterEndPage; override;
    procedure PrinterStartPage; override;
  public
    class function PrintDocument(const ADocument: TPDFDocument; const AJobTitle: string;
      const AShowPrintDialog: Boolean = True; const AllowPageRange: Boolean = True;
      const AParentWnd: HWND = 0): Boolean; static;
  end;

implementation

uses
  Winapi.ShellAPI, System.Character, System.Types, System.UITypes, Vcl.Clipbrd, Vcl.Printers
{$IFDEF ALPHASKINS}, sConst, sMessages, sStyleSimply, sVCLUtils{$ENDIF};

const
  cDefaultScrollOffset = 50;

{ TPDFPage }

function TPDFPageHelper.Page: FPDF_PAGE;
begin
  with Self do
  Result := FPage;
end;

{ TPDFiumControl }

constructor TPDFiumControl.Create(AOwner: TComponent);
begin
{$IFDEF ALPHASKINS}
  FSkinData := TsScrollWndData.Create(Self, True);
  FSkinData.COC := COC_TsMemo;
{$ENDIF}

  inherited Create(AOwner);

  ControlStyle := ControlStyle + [csOpaque];
  FZoomMode := smActualSize;
  FZoomPercent := 100;
  FPageIndex := 0;
  FPageMargin := 6;
  FPrintJobTitle := 'Print PDF';
  FAllowTextSelection := True;

  FPDFDocument := TPDFDocument.Create;
  FPDFDocument.OnFormFieldFocus := FormFieldFocus;
  FPDFDocument.OnFormGetCurrentPage := FormGetCurrentPage;
  FPDFDocument.OnFormOutputSelectedRect := FormOutputSelectedRect;

  DoubleBuffered := True;
  ParentBackground := False;
  ParentColor := False;
  Color := clWhite;
  FPageBorderColor := clSilver;
  TabStop := True;
  Width := 200;
  Height := 250;
  VertScrollBar.Smooth := True;
  VertScrollBar.Tracking := True;
  HorzScrollBar.Smooth := True;
  HorzScrollBar.Tracking := True;
end;

procedure TPDFiumControl.CreateParams(var AParams: TCreateParams);
begin
  inherited CreateParams(AParams);

  with AParams.WindowClass do
  Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

destructor TPDFiumControl.Destroy;
begin
{$IFDEF ALPHASKINS}
  if Assigned(FScrollWnd) then
  begin
    FScrollWnd.Free;
    FScrollWnd := nil;
  end;

  if Assigned(FSkinData) then
  begin
    FSkinData.Free;
    FSkinData := nil;
  end;
{$ENDIF}

  FPDFDocument.Free;

  inherited;
end;

procedure TPDFiumControl.AfterConstruction;
begin
  inherited AfterConstruction;

{$IFDEF ALPHASKINS}
  if HandleAllocated then
    RefreshEditScrolls(SkinData, FScrollWnd);

  UpdateData(FSkinData);
{$ENDIF}
end;

procedure TPDFiumControl.Loaded;
begin
  inherited Loaded;

{$IFDEF ALPHASKINS}
  FSkinData.Loaded(False);
{$ENDIF}
end;

procedure TPDFiumControl.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

procedure TPDFiumControl.WMGetDlgCode(var AMessage: TWMGetDlgCode);
begin
  inherited;

  AMessage.Result := AMessage.Result or DLGC_WANTARROWS;
end;

function TPDFiumControl.IsPageValid: Boolean;
begin
  Result := FPDFDocument.Active and (PageIndex >= 0) and (PageIndex < PageCount);
end;

function TPDFiumControl.GetCurrentPage: TPDFPage;
begin
  if IsPageValid then
    Result := FPDFDocument.Pages[PageIndex]
  else
    Result := nil;
end;

function TPDFiumControl.DoMouseWheel(AShift: TShiftState; AWheelDelta: Integer; AMousePos: TPoint): Boolean;
begin
  FChanged := True;
  VertScrollBar.Position := VertScrollBar.Position - AWheelDelta;

  UpdatePageIndex;

  if Assigned(OnScroll) then
    OnScroll(Self, sbVertical);

  Result := True;
end;

procedure TPDFiumControl.WMHScroll(var AMessage: TWMHScroll);
begin
  FChanged := True;

  inherited;

  if Assigned(OnScroll) then
    OnScroll(Self, sbHorizontal);
end;

procedure TPDFiumControl.UpdatePageIndex;
var
  LIndex: Integer;
  LPageIndex: Integer;
  LTop: Integer;
begin
  LTop := Height div 3;
  LPageIndex := FPageCount - 1;
  { Can't use binary search. Page info rect is not always up to date - see AdjustPageInfo. }
  for LIndex := 0 to FPageCount - 1 do
  if FPageInfo[LIndex].Rect.Top >= LTop then
  begin
    LPageIndex := LIndex - 1;
    Break;
  end;
  FPageIndex := Max(LPageIndex, 0);
end;

procedure TPDFiumControl.WMVScroll(var AMessage: TWMVScroll);
begin
  FChanged := True;

  inherited;

  UpdatePageIndex;

  if Assigned(OnScroll) then
    OnScroll(Self, sbVertical);
end;

procedure TPDFiumControl.LoadFromFile(const AFilename: string);
begin
  FFilename := AFilename;
  FPDFDocument.LoadFromFile(AFilename);
  OnLoad;
end;

procedure TPDFiumControl.LoadFromStream(const AStream: TStream);
begin
  FPDFDocument.LoadFromStream(AStream);
  OnLoad;
end;

procedure TPDFiumControl.OnLoad;
begin
  SetPageCount(FPDFDocument.PageCount);
  FChanged := True;
  Invalidate;
end;

function TPDFiumControl.ZoomToScreen: Single;
begin
  Result := FZoomPercent / 100 * Screen.PixelsPerInch / 72;
end;

procedure TPDFiumControl.SetPageCount(const AValue: Integer);
var
  LIndex: Integer;
  LPage: TPDFPage;
begin
  FPageCount := AValue;
  FPageIndex := 0;
  FWidth := 0;
  FHeight := 0;

  if FPageCount > 0 then
  begin
    SetLength(FPageInfo, FPageCount);
    for LIndex := 0 to FPageCount - 1 do
    begin
      LPage := FPDFDocument.Pages[LIndex];
      with FPageInfo[LIndex] do
      begin
        Width := LPage.Width;
        Height := LPage.Height;
        Rotation := LPage.Rotation;
      end;
      if LPage.Width > FWidth then
        FWidth := LPage.Width;
      FHeight := FHeight + LPage.Height;
    end;
  end;

  HorzScrollBar.Position := 0;
  VertScrollBar.Position := 0;
  SetScrollSize;
end;

procedure TPDFiumControl.SetPageNumber(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  Dec(LValue);
  if (LValue >= 0) and (LValue < FPageCount) and (FPageIndex <> LValue) then
  begin
    FPageIndex := LValue;
    FChanged := True;
    VertScrollBar.Position := GetPageTop(FPageIndex);
    PageChanged;
  end;
end;

procedure TPDFiumControl.PageChanged;
begin
  FSelectionStartCharIndex := 0;
  FSelectionStopCharIndex := 0;
  FSelectionActive := False;
  GetPageWebLinks;
end;

procedure TPDFiumControl.SetScrollSize;
var
  LZoom: Single;
begin
  LZoom := FZoomPercent / 100 * Screen.PixelsPerInch / 72;
  HorzScrollBar.Range := Round(FWidth * LZoom) + FPageMargin * 2;
  VertScrollBar.Range := Round(FHeight * LZoom) + FPageMargin * (FPageCount + 1);
end;

procedure TPDFiumControl.SetZoomPercent(const AValue: Single);
var
  LValue: Single;
begin
  LValue := AValue;

  if LValue < 0.65 then
    LValue := 0.65
  else
  if LValue > 6400 then
    LValue := 6400;

  FZoomPercent := LValue;
  SetScrollSize;
  DoSizeChanged;
end;

procedure TPDFiumControl.Zoom(const APercent: Single);
begin
  FZoomMode := smPercent;
  SetZoomPercent(APercent);
end;

procedure TPDFiumControl.DoSizeChanged;
begin
  FChanged := True;
  Invalidate;
  if Assigned(OnResize) then
    OnResize(Self);
end;

procedure TPDFiumControl.SetZoomMode(const AValue: TPDFZoomMode);
begin
  FZoomMode := AValue;
  AdjustZoom;
end;

procedure TPDFiumControl.AdjustZoom;
begin
  case FZoomMode of
    smPercent:
      Exit;
    smActualSize:
      SetZoomPercent(100);
    smFitHeight:
      SetZoomPercent(PageHeightZoomPercent);
    smFitWidth:
      SetZoomPercent(PageWidthZoomPercent);
  end;
end;

procedure TPDFiumControl.ClearSelection;
begin
  SetSelection(False, 0, 0);
end;

procedure TPDFiumControl.SelectAll;
begin
  SelectText(0, -1);
end;

procedure TPDFiumControl.SelectText(const ACharIndex: Integer; const ACount: Integer);
begin
  if (ACount = 0) or not IsPageValid then
    ClearSelection
  else
  begin
    if ACount = -1 then
      SetSelection(True, 0, CurrentPage.GetCharCount - 1)
    else
      SetSelection(True, ACharIndex, Min(ACharIndex + ACount - 1, CurrentPage.GetCharCount - 1));
  end;
end;

procedure TPDFiumControl.CloseDocument;
begin
  FPDFDocument.Close;
  SetPageCount(0);
  FFormFieldFocused := False;
  Invalidate;
end;

procedure TPDFiumControl.CopyToClipboard;
begin
  Clipboard.AsText := GetSelectionText;
end;

function TPDFiumControl.GetPageNumber: Integer;
begin
  Result := FPageIndex + 1;
end;

function TPDFiumControl.GetPageTop(const APageIndex: Integer): Integer;
var
  LY: Double;
  LPageIndex: Integer;
begin
  LPageIndex := APageIndex;
  Result := LPageIndex * FPageMargin;
  LY := 0;
  while LPageIndex > 0 do
  begin
    Dec(LPageIndex);
    LY := LY + FPageInfo[LPageIndex].Height;
  end;
  Inc(Result, PageToScreen(LY));
end;

procedure TPDFiumControl.GotoPage(const AIndex: Integer);
begin
  if FPageIndex = AIndex then
    Exit;

  if (AIndex >= 0) and (AIndex < FPageCount) then
  begin
    FPageIndex := AIndex;
    FChanged := True;
    VertScrollBar.Position := GetPageTop(AIndex);
  end;
end;

procedure TPDFiumControl.AdjustPageInfo;
var
  LIndex: Integer;
  LTop: Double;
  LZoom: Double;
  LClient: TRect;
  LRect: TRect;
  LMargin: Integer;
begin
  for LIndex := 0 to FPageCount - 1 do
    FPageInfo[LIndex].Visible := 0;

  LClient := ClientRect;
  LTop := 0;
  LMargin := FPageMargin;
  LZoom := FZoomPercent / 100 * Screen.PixelsPerInch / 72;
  for LIndex := 0 to FPageCount - 1 do
  begin
    LRect.Top := Round(LTop * LZoom) + LMargin - VertScrollBar.Position;
    LRect.Left := FPageMargin + Round((FWidth - FPageInfo[LIndex].Width) / 2 * LZoom) - HorzScrollBar.Position;
    LRect.Width := Round(FPageInfo[LIndex].Width * LZoom);
    LRect.Height := Round(FPageInfo[LIndex].Height * LZoom);
    if LRect.Width < LClient.Width - 2 * FPageMargin then
      LRect.Offset((LClient.Width - LRect.Width) div 2 - LRect.Left, 0);

    FPageInfo[LIndex].Rect := LRect;

    if LRect.IntersectsWith(LClient) then
      FPageInfo[LIndex].Visible := 1;

    if LRect.Top > LClient.Bottom then
      Break;

    LTop := LTop + FPageInfo[LIndex].Height;
    Inc(LMargin, FPageMargin);
  end;
end;

function TPDFiumControl.GetSelectionText: string;
begin
  if FSelectionActive and IsPageValid then
    Result := CurrentPage.ReadText(SelectionStart, SelectionLength)
  else
    Result := '';
end;

function TPDFiumControl.GetSelectionLength: Integer;
begin
  if FSelectionActive and IsPageValid then
    Result := Abs(FSelectionStartCharIndex - FSelectionStopCharIndex) + 1
  else
    Result := 0;
end;

function TPDFiumControl.GetSelectionStart: Integer;
begin
  if FSelectionActive and IsPageValid then
    Result := Min(FSelectionStartCharIndex, FSelectionStopCharIndex)
  else
    Result := 0;
end;

function TPDFiumControl.GetSelectionRects: TPDFControlRectArray;
var
  LCount: Integer;
  LIndex: Integer;
  LPage: TPDFPage;
begin
  if FSelectionActive and HandleAllocated then
  begin
    LPage := CurrentPage;
    if Assigned(LPage) then
    begin
      LCount := CurrentPage.GetTextRectCount(SelectionStart, SelectionLength);
      SetLength(Result, LCount);
      for LIndex := 0 to LCount - 1 do
        Result[LIndex] := InternPageToDevice(LPage, LPage.GetTextRect(LIndex), FPageInfo[FPageIndex].Rect);
      Exit;
    end;
  end;

  Result := nil;
end;

procedure TPDFiumControl.InvalidateRectDiffs(const AOldRects, ANewRects: TPDFControlRectArray);

  function ContainsRect(const Rects: TPDFControlRectArray; const ARect: TRect): Boolean;
  var
    LIndex: Integer;
  begin
    Result := True;

    for LIndex := 0 to Length(Rects) - 1 do
    if EqualRect(Rects[LIndex], ARect) then
      Exit;

    Result := False;
  end;

var
  LIndex: Integer;
begin
  if HandleAllocated then
  begin
    for LIndex := 0 to Length(AOldRects) - 1 do
    if not ContainsRect(ANewRects, AOldRects[LIndex]) then
      InvalidateRect(Handle, @AOldRects[LIndex], True);

    for LIndex := 0 to Length(ANewRects) - 1 do
    if not ContainsRect(AOldRects, ANewRects[LIndex]) then
      InvalidateRect(Handle, @ANewRects[LIndex], True);
  end;
end;

procedure TPDFiumControl.SetSelection(const AActive: Boolean; const AStartIndex, AStopIndex: Integer);
var
  LOldRects, LNewRects: TPDFControlRectArray;
begin
  if (AActive <> FSelectionActive) or (AStartIndex <> FSelectionStartCharIndex) or (AStopIndex <> FSelectionStopCharIndex) then
  begin
    LOldRects := GetSelectionRects;

    FSelectionStartCharIndex := AStartIndex;
    FSelectionStopCharIndex := AStopIndex;
    FSelectionActive := AActive and (FSelectionStartCharIndex >= 0) and (FSelectionStopCharIndex >= 0);

    LNewRects := GetSelectionRects;

    InvalidateRectDiffs(LOldRects, LNewRects);
  end;
end;

function TPDFiumControl.SelectWord(const ACharIndex: Integer): Boolean;
var
  LChar: Char;
  LStartCharIndex, LStopCharIndex, LCharCount: Integer;
  LPage: TPDFPage;
  LCharIndex: Integer;
begin
  Result := False;

  LPage := CurrentPage;
  if Assigned(LPage) then
  begin
    ClearSelection;
    LCharCount := LPage.GetCharCount;
    LCharIndex := ACharIndex;
    if (LCharIndex >= 0) and (LCharIndex < LCharCount) then
    begin
      while (LCharIndex < LCharCount) and CurrentPage.ReadChar(LCharIndex).IsWhiteSpace do
        Inc(LCharIndex);

      if LCharIndex < LCharCount then
      begin
        LStartCharIndex := LCharIndex - 1;
        while LStartCharIndex >= 0 do
        begin
          LChar := CurrentPage.ReadChar(LStartCharIndex);
          if LChar.IsWhiteSpace then
            Break;

          Dec(LStartCharIndex);
        end;

        Inc(LStartCharIndex);

        LStopCharIndex := LCharIndex + 1;
        while LStopCharIndex < LCharCount do
        begin
          LChar := CurrentPage.ReadChar(LStopCharIndex);
          if LChar.IsWhiteSpace then
            Break;

          Inc(LStopCharIndex);
        end;

        Dec(LStopCharIndex);

        SetSelection(True, LStartCharIndex, LStopCharIndex);
        Result := True;
      end;
    end;
  end;
end;

procedure TPDFiumControl.MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  LPoint: TPDFPoint;
  LCharIndex: Integer;
begin
  inherited MouseDown(AButton, AShift, X, Y);

  if AButton = mbLeft then
  begin
    SetFocus;
    FMousePressed := True;
    FMouseDownPoint := Point(X, Y); // used to find out if the selection must be cleared or not
  end;

  if IsPageValid and AllowTextSelection and not FFormFieldFocused then
  begin
    if AButton = mbLeft then
    begin
      LPoint := DeviceToPage(X, Y);
      LCharIndex := CurrentPage.GetCharIndexAt(LPoint.X, LPoint.Y, MAXWORD, MAXWORD);

      if ssDouble in AShift then
      begin
        FMousePressed := False;
        SelectWord(LCharIndex);
      end
      else
        SetSelection(False, LCharIndex, LCharIndex);
    end;
  end;
end;

function TPDFiumControl.GetPageIndexAt(const APoint: TPoint): Integer;
var
  LIndex: Integer;
begin
  Result := FPageIndex;

  for LIndex := 0 to FPageCount - 1 do
  if FPageInfo[LIndex].Rect.Contains(APoint) then
    Exit(LIndex);
end;

procedure TPDFiumControl.MouseMove(AShift: TShiftState; X, Y: Integer);
var
  LPoint: TPDFPoint;
  LCursor: TCursor;
  LPageIndex: Integer;
begin
  inherited MouseMove(AShift, X, Y);

  LPageIndex := GetPageIndexAt(Point(X, Y));

  if LPageIndex <> FPageIndex then
  begin
    FPageIndex := LPageIndex;
    GetPageWebLinks;
  end;

  LCursor := Cursor;
  try
    if AllowTextSelection and not FFormFieldFocused then
    begin
      if FMousePressed then
      begin
        if SetSelStopCharIndex(X, Y) then
          if LCursor <> crIBeam then
          begin
            LCursor := crIBeam;
            Cursor := LCursor;
            SetCursor(Screen.Cursors[Cursor]); { Show the mouse cursor change immediately }
          end;
      end
      else
      if IsPageValid then
      begin
        LPoint := DeviceToPage(X, Y);
        if IsWebLinkAt(X, Y) then
          LCursor := crHandPoint
        else
        if CurrentPage.GetCharIndexAt(LPoint.X, LPoint.Y, 5, 5) >= 0 then
          LCursor := crIBeam
        else
        if Cursor <> crDefault then
          LCursor := crDefault;
      end;
    end;
  finally
    if LCursor <> Cursor then
      Cursor := LCursor;
  end;
end;

procedure TPDFiumControl.MouseUp(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  LURL: string;
begin
  inherited MouseUp(AButton, AShift, X, Y);

  if FMousePressed and (AButton = mbLeft) then
  begin
    FMousePressed := False;

    if AllowTextSelection and not FFormFieldFocused then
      SetSelStopCharIndex(X, Y);

    if not FSelectionActive and IsWebLinkAt(X, Y, LURL) then
      WebLinkClick(LURL);
  end;
end;

function TPDFiumControl.DeviceToPage(const X, Y: Integer): TPDFPoint;
var
  LPage: TPDFPage;
begin
  LPage := CurrentPage;
  if Assigned(LPage) then
  with FPageInfo[FPageIndex] do
    Result := LPage.DeviceToPage(Rect.Left, Rect.Top, Rect.Width, Rect.Height, X, Y, Rotation)
  else
    Result := TPDFPoint.Empty;
end;

procedure TPDFiumControl.GetPageWebLinks;
var
  LLinkIndex, LLinkCount: Integer;
  LRectIndex, LRectCount: Integer;
  LPage: TPDFPage;
begin
  LPage := CurrentPage;
  if Assigned(LPage) then
  begin
    LLinkCount := LPage.GetWebLinkCount;
    SetLength(FWebLinksRects, LLinkCount);
    for LLinkIndex := 0 to LLinkCount - 1 do
    begin
      LRectCount := LPage.GetWebLinkRectCount(LLinkIndex);
      SetLength(FWebLinksRects[LLinkIndex], LRectCount);
      for LRectIndex := 0 to LRectCount - 1 do
        FWebLinksRects[LLinkIndex][LRectIndex] := LPage.GetWebLinkRect(LLinkIndex, LRectIndex);
    end;
  end
  else
    FWebLinksRects := nil;
end;

function TPDFiumControl.GetWebLinkIndex(const X, Y: Integer): Integer;
var
  LRectIndex: Integer;
  LPoint: TPoint;
  LPage: TPDFPage;
begin
  LPoint := Point(X, Y);
  LPage := CurrentPage;
  if Assigned(LPage) then
  for Result := 0 to Length(FWebLinksRects) - 1 do
    for LRectIndex := 0 to Length(FWebLinksRects[Result]) - 1 do
    if PtInRect(InternPageToDevice(LPage, FWebLinksRects[Result][LRectIndex], FPageInfo[FPageIndex].Rect), LPoint) then
      Exit;
  Result := -1;
end;

function TPDFiumControl.IsWebLinkAt(const X, Y: Integer): Boolean;
begin
  Result := GetWebLinkIndex(X, Y) <> -1;
end;

{ Note! There is an issue with multiline URLs in PDF - PDFium.dll returns the url using a hyphen as a separator.
  The hyphen is a valid character in the url, so it can't just be removed. }
function TPDFiumControl.IsWebLinkAt(const X, Y: Integer; var AURL: string): Boolean;
var
  LIndex: Integer;
begin
  LIndex := GetWebLinkIndex(X, Y);
  Result := LIndex <> -1;
  if Result then
    AURL := CurrentPage.GetWebLinkURL(LIndex)
  else
    AURL := '';
end;

procedure TPDFiumControl.GotoNextPage;
begin
  GotoPage(FPageIndex + 1);
end;

procedure TPDFiumControl.WMPaint(var AMessage: TWMPaint);
begin
  ControlState := ControlState + [csCustomPaint];
  inherited;
  ControlState := ControlState - [csCustomPaint];
end;

function TPDFiumControl.PageHeightZoomPercent: Single;
var
  LScale: Single;
  LScale1, LScale2: Single;
begin
  if FPageIndex < 0 then
    Exit(100);

  LScale := 72 / Screen.PixelsPerInch;
  LScale1 := (ClientWidth - 2 * FPageMargin) * LScale / FPageInfo[FPageIndex].Width;
  LScale2 := (ClientHeight - 2 * FPageMargin) * LScale / FPageInfo[FPageIndex].Height;
  if LScale1 > LScale2 then
    LScale1 := LScale2;
  Result := 100 * LScale1;
end;

function TPDFiumControl.PageWidthZoomPercent: Single;
var
  LScale: Single;
begin
  if FPageIndex < 0 then
    Exit(100);

  LScale := 72 / Screen.PixelsPerInch;
  Result := 100 * (ClientWidth - 2 * FPageMargin) * LScale / FPageInfo[FPageIndex].Width;
end;

function TPDFiumControl.PageToScreen(const AValue: Single): Integer;
begin
  Result := Round(AValue * ZoomToScreen);
end;

function TPDFiumControl.SetSelStopCharIndex(const X, Y: Integer): Boolean;
var
  LPoint: TPDFPoint;
  LCharIndex: Integer;
  LActive: Boolean;
  LRect: TRect;
begin
  LPoint := DeviceToPage(X, Y);
  LCharIndex := CurrentPage.GetCharIndexAt(LPoint.X, LPoint.Y, MAXWORD, MAXWORD);
  Result := LCharIndex >= 0;
  if not Result then
    LCharIndex := FSelectionStopCharIndex;

  if FSelectionStartCharIndex <> LCharIndex then
    LActive := True
  else
  begin
    LRect := InternPageToDevice(CurrentPage, CurrentPage.GetCharBox(FSelectionStartCharIndex), FPageInfo[FPageIndex].Rect);
    LActive := PtInRect(LRect, FMouseDownPoint) xor PtInRect(LRect, Point(X, Y));
  end;

  SetSelection(LActive, FSelectionStartCharIndex, LCharIndex);
end;

procedure TPDFiumControl.SetFocus;
begin
  if CanFocus then
  begin
    Winapi.Windows.SetFocus(Handle);
    inherited;
  end;
end;

procedure TPDFiumControl.PaintWindow(ADC: HDC);
var
  LIndex: Integer;
  LPage: TPDFPage;
  LBrush: HBrush;
begin
  LBrush := CreateSolidBrush(Color);
  try
    FillRect(ADC, ClientRect, LBrush);

    if FPageCount = 0 then
      Exit;

    if FChanged or (FPageCount = 0) then
    begin
      AdjustPageInfo;
      FChanged := False;
    end;

    for LIndex := 0 to FPageCount - 1 do
    with FPageInfo[LIndex] do
    if Visible > 0 then
    begin
      LPage := FPDFDocument.Pages[LIndex];

      FillRect(ADC, Rect, LBrush);
      PaintPage(ADC, LPage, LIndex);

      { Selections are drawn only to selected page without rotation. }
      if (LIndex = FPageIndex) and (Rotation = prNormal) then
      begin
        if FSelectionActive then
          PaintPageSelection(ADC, LPage, LIndex);
        PaintAlphaSelection(ADC, LPage, FFormOutputSelectedRects, LIndex);
      end;
{$IFDEF ALPHASKINS}
      if IsLightStyleColor(Color) then
{$ENDIF}
        PaintPageBorder(ADC, Rect);
    end;

    if Assigned(FOnPaint) then
      FOnPaint(Self);
  finally
    DeleteObject(LBrush);
  end;
end;

procedure TPDFiumControl.PaintPage(ADC: HDC; const APage: TPDFPage; const AIndex: Integer);
var
  LRect: TRect;
  LPoint: TPoint;
begin
  with FPageInfo[AIndex] do
  if (Rect.Left <> 0) or (Rect.Top <> 0) then
  begin
    LRect := TRect.Create(0, 0, Rect.Width, Rect.Height);
    SetViewportOrgEx(ADC, Rect.Left, Rect.Top, @LPoint);
    APage.Draw(ADC, LRect.Left, LRect.Top, LRect.Width, LRect.Height, Rotation, []);
    SetViewportOrgEx(ADC, LPoint.X, LPoint.Y, nil);
  end
  else
    FPDF_RenderPage(ADC, APage.Handle, LRect.Left, LRect.Top, LRect.Width, LRect.Height, Ord(Rotation), 0);
end;

procedure TPDFiumControl.PaintPageSelection(ADC: HDC; const APage: TPDFPage; const AIndex: Integer);
var
  LCount: Integer;
  LIndex: Integer;
  LRects: TPDFRectArray;
begin
  LCount := APage.GetTextRectCount(SelectionStart, SelectionLength);
  if LCount > 0 then
  begin
    SetLength(LRects, LCount);
    for LIndex := 0 to LCount - 1 do
      LRects[LIndex] := APage.GetTextRect(LIndex);
    PaintAlphaSelection(ADC, APage, LRects, AIndex);
  end;
end;

function TPDFiumControl.InternPageToDevice(const APage: TPDFPage; const APageRect: TPDFRect; const ARect: TRect): TRect;
begin
  Result := APage.PageToDevice(ARect.Left, ARect.Top, ARect.Width, ARect.Height, APageRect, APage.Rotation);
end;

procedure TPDFiumControl.PaintAlphaSelection(ADC: HDC; const APage: TPDFPage; const ARects: TPDFRectArray; const AIndex: Integer);
var
  LCount: Integer;
  LIndex: Integer;
  LRect: TRect;
  LDC: HDC;
  LBitmap: TBitmap;
  LBlendFunc: TBlendFunction;
begin
  LCount := Length(ARects);
  if LCount > 0 then
  begin
    LBitmap := TBitmap.Create;
    try
      LBitmap.Canvas.Brush.Color := RGB(50, 142, 254);
      LBitmap.SetSize(100, 50);
      LBlendFunc.BlendOp := AC_SRC_OVER;
      LBlendFunc.BlendFlags := 0;
      LBlendFunc.SourceConstantAlpha := 127;
      LBlendFunc.AlphaFormat := 0;
      LDC := LBitmap.Canvas.Handle;
      for LIndex := 0 to LCount - 1 do
      begin
        LRect := InternPageToDevice(APage, ARects[LIndex], FPageInfo[AIndex].Rect);
        if RectVisible(ADC, LRect) then
          AlphaBlend(ADC, LRect.Left, LRect.Top, LRect.Width, LRect.Height, LDC, 0, 0, LBitmap.Width, LBitmap.Height,
            LBlendFunc);
      end;
    finally
      LBitmap.Free;
    end;
  end;
end;

procedure TPDFiumControl.PaintPageBorder(ADC: HDC; const ARect: TRect);
var
  LPen: HPen;
begin
  LPen := CreatePen(PS_SOLID, 1, FPageBorderColor);
  try
    SelectObject(ADC, LPen);
    MoveToEx(ADC, ARect.Left, ARect.Top, nil);
    LineTo(ADC, ARect.Left + ARect.Width - 1, ARect.Top);
    LineTo(ADC, ARect.Left + ARect.Width - 1, ARect.Top + ARect.Height - 1);
    LineTo(ADC, ARect.Left, ARect.Top + ARect.Height - 1);
    LineTo(ADC, ARect.Left, ARect.top);
  finally
    DeleteObject(LPen);
  end;
end;

procedure TPDFiumControl.GotoPreviousPage;
begin
  GotoPage(FPageIndex - 1);
end;

procedure TPDFiumControl.Print;
var
  LIndex: Integer;
  LPage: TPDFPage;
  LStream: TMemoryStream;
  LPDFDocument: TPDFDocument;
begin
  LPDFDocument := TPDFDocument.Create;
  LPDFDocument.OnFormFieldFocus := FormFieldFocus;
  LPDFDocument.OnFormGetCurrentPage := FormGetCurrentPage;
  LPDFDocument.OnFormOutputSelectedRect := FormOutputSelectedRect;
  try
    { Flatten pages. Needed for form field values. }
    Screen.Cursor := crHourGlass;
    LStream := TMemoryStream.Create;
    try
      FPDFDocument.SaveToStream(LStream); { Original }
      LStream.Position := 0;

      LPDFDocument.LoadFromStream(LStream);
      for LIndex := 0 to FPageCount - 1 do
      begin
        LPage := LPDFDocument.Pages[LIndex];
        FPDFPage_Flatten(LPage.Page, 1);
      end;
      LPDFDocument.SaveToStream(LStream);
      LStream.Position := 0;
      LPDFDocument.LoadFromStream(LStream);
    finally
      LStream.Free;
      Screen.Cursor := crDefault;
    end;

    TPDFDocumentVclPrinter.PrintDocument(LPDFDocument, PrintJobTitle);
  finally
    LPDFDocument.Free;
  end;
end;

procedure TPDFiumControl.Resize;
begin
  inherited;

  AdjustZoom;
  FChanged := True;
  Invalidate;
end;

function TPDFiumControl.IsTextSelected: Boolean;
begin
  Result := SelectionLength <> 0;
end;

procedure TPDFiumControl.RotatePageClockwise;
var
  LPage: TPDFPage;
begin
  if FPageIndex = -1 then
    Exit;

  LPage := FPDFDocument.Pages[FPageIndex];

  with FPageInfo[FPageIndex] do
  begin
    Inc(Rotation);
    if Ord(Rotation) > Ord(pr90CounterClockwide) then
      Rotation := prNormal;
    if Rotation in [prNormal, pr180] then
    begin
      Height := LPage.Height;
      Width := LPage.Width;
    end
    else
    begin
      Height := LPage.Width;
      Width := LPage.Height;
    end;
  end;

  DoSizeChanged;
end;

procedure TPDFiumControl.RotatePageCounterClockwise;
var
  LPage: TPDFPage;
begin
  if FPageIndex = -1 then
    Exit;

  LPage := FPDFDocument.Pages[FPageIndex];

  with FPageInfo[FPageIndex] do
  begin
    Dec(Rotation);
    if Ord(Rotation) < Ord(prNormal) then
      Rotation := pr90CounterClockwide;
    if Rotation in [prNormal, pr180] then
    begin
      Height := LPage.Height;
      Width := LPage.Width;
    end
    else
    begin
      Height := LPage.Width;
      Width := LPage.Height;
    end;
  end;

  DoSizeChanged;
end;

procedure TPDFiumControl.ZoomToHeight;
begin
  ZoomMode := smFitHeight;
  DoSizeChanged;
end;

procedure TPDFiumControl.ZoomToWidth;
begin
  ZoomMode := smFitWidth;
  DoSizeChanged;
end;

procedure TPDFiumControl.FormOutputSelectedRect(ADocument: TPDFDocument; APage: TPDFPage; const APageRect: TPDFRect);
begin
  if HandleAllocated then
  begin
    SetLength(FFormOutputSelectedRects, Length(FFormOutputSelectedRects) + 1);
    FFormOutputSelectedRects[Length(FFormOutputSelectedRects) - 1] := APageRect;
  end;
end;

procedure TPDFiumControl.FormGetCurrentPage(ADocument: TPDFDocument; var APage: TPDFPage);
begin
  APage := CurrentPage;
end;

procedure TPDFiumControl.FormFieldFocus(ADocument: TPDFDocument; AValue: PWideChar; AValueLen: Integer; AFieldFocused: Boolean);
begin
  ClearSelection;
  FFormFieldFocused := AFieldFocused;
end;

procedure TPDFiumControl.WebLinkClick(const AURL: string);
var
  LResult: Boolean;
begin
  LResult := ShellExecute(0, 'open', PChar(AURL), nil, nil, SW_NORMAL) > 32;
  if not LResult then
    MessageDlg(SysErrorMessage(GetLastError), mtError, [mbOK], 0);
end;

procedure TPDFiumControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  case Key of
    VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN:
      FChanged := True;
  end;

  case Key of
    Ord('C'), VK_INSERT:
      if AllowTextSelection then
      begin
        if Shift = [ssCtrl] then
        begin
          if FSelectionActive then
            CopyToClipboard;
          Key := 0;
        end
      end;

    Ord('A'):
      if AllowTextSelection then
      begin
        if Shift = [ssCtrl] then
        begin
          SelectAll;
          Key := 0;
        end;
      end;

    VK_RIGHT:
      HorzScrollBar.Position := HorzScrollBar.Position - cDefaultScrollOffset;
    VK_LEFT:
      HorzScrollBar.Position := HorzScrollBar.Position + cDefaultScrollOffset;
    VK_UP:
      VertScrollBar.Position := VertScrollBar.Position - cDefaultScrollOffset;
    VK_DOWN:
      VertScrollBar.Position := VertScrollBar.Position + cDefaultScrollOffset;
    VK_PRIOR:
      GotoPreviousPage;
    VK_NEXT:
      GotoNextPage;
    VK_HOME:
      GotoPage(0);
    VK_END:
      GotoPage(PageCount - 1);
  end;

  case Key of
    VK_UP, VK_DOWN:
      UpdatePageIndex;
  end;

  case Key of
    VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_HOME, VK_END:
      if Assigned(OnScroll) then
        OnScroll(Self, sbVertical);
  end;
end;

{$IFDEF ALPHASKINS}
procedure TPDFiumControl.WndProc(var AMessage: TMessage);
var
  LPaintStruct: TPaintStruct;
begin
  if AMessage.Msg = SM_ALPHACMD then
    case AMessage.WParamHi of
      AC_CTRLHANDLED:
        begin
          AMessage.Result := 1;
          Exit;
        end;
      AC_SETNEWSKIN:
        if ACUInt(AMessage.LParam) = ACUInt(SkinData.SkinManager) then
        begin
          CommonMessage(AMessage, FSkinData);
          Exit;
        end;
      AC_REMOVESKIN:
        if ACUInt(AMessage.LParam) = ACUInt(SkinData.SkinManager) then
        begin
          if Assigned(FScrollWnd) then
          begin
            FreeAndNil(FScrollWnd);
            RecreateWnd;
          end;
          Exit;
        end;
      AC_REFRESH:
        if RefreshNeeded(SkinData, AMessage) then
        begin
          RefreshEditScrolls(SkinData, FScrollWnd);
          CommonMessage(AMessage, FSkinData);
          if HandleAllocated and Visible then
            RedrawWindow(Handle, nil, 0, RDWA_REPAINT);
          Exit;
        end;
      AC_GETDEFSECTION:
        begin
          AMessage.Result := 1;
          Exit;
        end;
      AC_GETDEFINDEX:
        begin
          if Assigned(FSkinData.SkinManager) then
            AMessage.Result := FSkinData.SkinManager.SkinCommonInfo.Sections[ssEdit] + 1;
          Exit;
        end;
      AC_SETGLASSMODE:
        begin
          CommonMessage(AMessage, FSkinData);
          Exit;
        end;
    end;

  if not ControlIsReady(Self) or not Assigned(FSkinData) or not FSkinData.Skinned then
    inherited
  else
  begin
    case AMessage.Msg of
      WM_ERASEBKGND:
        if (SkinData.SkinIndex >= 0) and InUpdating(FSkinData) then
          Exit;
      WM_PAINT:
        begin
          if InUpdating(FSkinData) then
          begin
            BeginPaint(Handle, LPaintStruct);
            EndPaint(Handle, LPaintStruct);
          end
          else
            inherited;

          Exit;
        end;
    end;

    if CommonWndProc(AMessage, FSkinData) then
      Exit;

    inherited;

    case AMessage.Msg of
      CM_SHOWINGCHANGED:
        RefreshEditScrolls(SkinData, FScrollWnd);
      CM_VISIBLECHANGED, CM_ENABLEDCHANGED, WM_SETFONT:
        FSkinData.Invalidate;
      CM_TEXTCHANGED, CM_CHANGED:
        if Assigned(FScrollWnd) then
          UpdateScrolls(FScrollWnd, True);
    end;
  end;
end;
{$ENDIF}

{ TPDFDocumentVclPrinter }

function VclAbortProc(Prn: HDC; Error: Integer): Bool; stdcall;
begin
  Application.ProcessMessages;

  Result := not Printer.Aborted;
end;

function FastVclAbortProc(Prn: HDC; Error: Integer): Bool; stdcall;
begin
  Result := not Printer.Aborted;
end;

function TPDFDocumentVclPrinter.PrinterStartDoc(const AJobTitle: string): Boolean;
begin
  Result := False;
  FPagePrinted := False;
  if not Printer.Printing then
  begin
    if AJobTitle <> '' then
      Printer.Title := AJobTitle;
    Printer.BeginDoc;
    FBeginDocCalled := Printer.Printing;
    Result := FBeginDocCalled;
  end;

  if Result then
    SetAbortProc(GetPrinterDC, @FastVclAbortProc);
end;

procedure TPDFDocumentVclPrinter.PrinterEndDoc;
begin
  if Printer.Printing and FBeginDocCalled then
    Printer.EndDoc;

  SetAbortProc(GetPrinterDC, @VclAbortProc);
end;

procedure TPDFDocumentVclPrinter.PrinterStartPage;
begin
  if (Printer.PageNumber > 1) or FPagePrinted then
    Printer.NewPage;
end;

procedure TPDFDocumentVclPrinter.PrinterEndPage;
begin
  FPagePrinted := True;
end;

function TPDFDocumentVclPrinter.GetPrinterDC: HDC;
begin
  Result := Printer.Handle;
end;

class function TPDFDocumentVclPrinter.PrintDocument(const ADocument: TPDFDocument;
  const AJobTitle: string;  const AShowPrintDialog: Boolean = True; const AllowPageRange: Boolean = True;
  const AParentWnd: HWND = 0): Boolean;
var
  LPDFDocumentVclPrinter: TPDFDocumentVclPrinter;
  LPrintDialog: TPrintDialog;
  LFromPage, LToPage: Integer;
begin
  Result := False;

  if not Assigned(ADocument) then
    Exit;

  LFromPage := 1;
  LToPage := ADocument.PageCount;

  if AShowPrintDialog then
  begin
    LPrintDialog := TPrintDialog.Create(nil);
    try
      if AllowPageRange then
      begin
        LPrintDialog.Options := LPrintDialog.Options + [poPageNums];
        LPrintDialog.MinPage := 1;
        LPrintDialog.MaxPage := ADocument.PageCount;
        LPrintDialog.ToPage := ADocument.PageCount;
      end;

      if (AParentWnd = 0) or not IsWindow(AParentWnd) then
        Result := LPrintDialog.Execute
      else
        Result := LPrintDialog.Execute(AParentWnd);

      if not Result then
        Exit;

      if AllowPageRange and (LPrintDialog.PrintRange = prPageNums) then
      begin
        LFromPage := LPrintDialog.FromPage;
        LToPage := LPrintDialog.ToPage;
      end;
    finally
      LPrintDialog.Free;
    end;
  end;

  LPDFDocumentVclPrinter := TPDFDocumentVclPrinter.Create;
  try
    if LPDFDocumentVclPrinter.BeginPrint(AJobTitle) then
    try
      Result := LPDFDocumentVclPrinter.Print(ADocument, LFromPage - 1, LToPage - 1);
    finally
      LPDFDocumentVclPrinter.EndPrint;
    end;
  finally
    LPDFDocumentVclPrinter.Free;
  end;
end;

end.