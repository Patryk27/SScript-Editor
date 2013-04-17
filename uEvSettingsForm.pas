unit uEvSettingsForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, LCLType, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Buttons, EditBtn;

type

  { TEvSettingsForm }

  TEvSettingsForm = class(TForm)
    Bevel1: TBevel;
    btnBGColor: TButton;
    btnSave: TButton;
    btnCancel: TButton;
    btnFont: TButton;
    btn_cIdentifiers: TButton;
    btn_cKeywords: TButton;
    btn_cStrings: TButton;
    btn_cComments: TButton;
    btn_cMacros: TButton;
    btn_cPrimaryTypes: TButton;
    btn_cOther: TButton;
    btnFGColor: TButton;
    cAddBrackets:TCheckBox;
    cbLanguages:TComboBox;
    cOpenRecentProject:TCheckBox;
    cScrollPastEOL:TCheckBox;
    ColorDialog: TColorDialog;
    CompilerFile_Select: TBitBtn;
    CompilerFile_Select1: TBitBtn;
    btn_cNumbers: TButton;
    eCompilerFile: TEdit;
    eVMFile: TEdit;
    EXEOpen: TOpenDialog;
    FileTimer: TTimer;
    FontDialog: TFontDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3:TLabel;
    p_5:TPage;
    p_4:TPage;
    p_2: TPage;
    Pages: TNotebook;
    p_1: TPage;
    Setting: TTreeView;
    SampleCode: TSynEdit;
    procedure btnBGColorClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnFGColorClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure btn_cCommentsClick(Sender: TObject);
    procedure btn_cIdentifiersClick(Sender: TObject);
    procedure btn_cKeywordsClick(Sender: TObject);
    procedure btn_cMacrosClick(Sender: TObject);
    procedure btn_cNumbersClick(Sender: TObject);
    procedure btn_cOtherClick(Sender: TObject);
    procedure btn_cPrimaryTypesClick(Sender: TObject);
    procedure btn_cStringsClick(Sender: TObject);
    procedure CompilerFile_Select1Click(Sender: TObject);
    procedure CompilerFile_SelectClick(Sender: TObject);
    procedure eCompilerFileChange(Sender: TObject);
    procedure eVMFileChange(Sender: TObject);
    procedure FileTimerTimer(Sender: TObject);
    procedure p_1BeforeShow(ASender: TObject; ANewPage: TPage;
    ANewIndex: Integer);
    procedure SettingChange(Sender:TObject;Node:TTreeNode);
  private
   Procedure UpdateSampleCode;
  public
   Procedure Run;
  end;

var
  EvSettingsForm: TEvSettingsForm;

implementation
Uses mSettings, mProject, mLanguages, SynEditSScript, uMainForm, uSyntaxHighlighterChange;
Const SettingsFile       = mSettings.FileName;
      SettingsFileBackup = mSettings.FileName+'_';

Var Highlighter: THighlighter = nil;
    CheckTime  : Integer = 0;

{$R *.lfm}

// mCopyFile
Procedure mCopyFile(const fFrom, fTo: String);
Begin
 if (FileExists(fFrom)) Then
  CopyFile(fFrom, fTo, True);
End;

// mDeleteFile
Procedure mDeleteFile(const fFile: String);
Begin
 if (FileExists(fFile)) Then
  DeleteFile(fFile);
End;

{ TEvSettingsForm }

{ TEvSettingsForm.UpdateSampleCode }
Procedure TEvSettingsForm.UpdateSampleCode;
Begin
 if (Highlighter <> nil) Then
  Highlighter.Free;

 Highlighter            := THighlighter.Create(SampleCode);
 SampleCode.Highlighter := Highlighter;
End;

{ getLanguageName }
Function getLanguageName(FileName: String): String;
Begin
 Result := Copy(FileName, 1, LastDelimiter('.', FileName)-1);
End;

{ SearchLanguages }
Procedure SearchLanguages;
Var M: TSearchRec;
Begin
 With EvSettingsForm.cbLanguages do
 Begin
  Clear;
  Items.Add('English');
 End;

 if (FindFirst(ExtractFilePath(ParamStr(0))+'/lang/*.lng', faAnyFile, M) <> 0) Then
  Exit; // no files found

 Repeat
  EvSettingsForm.cbLanguages.Items.Add(getLanguageName(M.Name)); // add next file
 Until (FindNext(M) <> 0);

 FindClose(M);

 With EvSettingsForm.cbLanguages do
 Begin
  ItemIndex := Items.IndexOf(getLanguageName(getString(sLanguage)));

  if (ItemIndex = -1) Then
   ItemIndex := 0;
 End;
End;

{ TEvSettingsForm.Run }
Procedure TEvSettingsForm.Run;
Begin
 // make a backup of current settings
 mCopyFile(SettingsFile, SettingsFileBackup);

 UpdateSampleCode;

 // load config
 eCompilerFile.Text         := getString(sCompilerFile);
 eVMFile.Text               := getString(sVMFile);
 cScrollPastEOL.Checked     := getBoolean(sScrollPastEOL);
 cOpenRecentProject.Checked := getBoolean(sOpenRecentProject);
 cAddBrackets.Checked       := getBoolean(sAddBrackets);

 // search languages
 SearchLanguages;

 // show form
 CheckTime := 0;
 FileTimer.OnTimer(FileTimer);
 ShowModal;

 // delete backup file
 mDeleteFile(SettingsFileBackup);
End;

procedure TEvSettingsForm.btnSaveClick(Sender: TObject);
Var Tmp: String;
begin
 { hide form }
 Hide;

 { save new settings }
 setString(sCompilerFile, eCompilerFile.Text);
 setString(sVMFile, eVMFile.Text);
 setBoolean(sScrollPastEOL, cScrollPastEOL.Checked);
 setBoolean(sOpenRecentProject, cOpenRecentProject.Checked);
 setBoolean(sAddBrackets, cAddBrackets.Checked);

 { has the language changed? }
 if (cbLanguages.Items.Count = 0) Then
  Tmp := '' Else
 Begin
  if (cbLanguages.ItemIndex = 0) Then // `English` (default) language
   Tmp := '' { `English` language doesn't have its corresponding language file, as it is internal } Else
   Tmp := cbLanguages.Items[cbLanguages.ItemIndex]+'.lng';
 End;

 if (Tmp <> getString(sLanguage)) Then
  Application.MessageBox(PChar(getLangValue(ls_msg_env_restart)), PChar(getLangValue(ls_msg_info)), MB_IconInformation);
 setString(sLanguage, Tmp);

 { refresh controls }
 if (uMainForm.getProjectPnt <> nil) Then // is any project opened?
  TProject(uMainForm.getProjectPnt).RefreshControls;

 { close form }
 Close;
end;

procedure TEvSettingsForm.btnFontClick(Sender: TObject);
begin
 FontDialog.Font := FetchFont(getFont(sEditorFont));

 { run font dialog }
 if (FontDialog.Execute) Then
  mSettings.setFont(sEditorFont, CreateFont(FontDialog.Font));

 UpdateSampleCode;
end;

procedure TEvSettingsForm.btn_cCommentsClick(Sender: TObject);
begin
 setFormat(sCommentFormat, SyntaxHighlighterChange.Run(getFormat(sCommentFormat)));
 UpdateSampleCode;
end;

procedure TEvSettingsForm.btn_cIdentifiersClick(Sender: TObject);
begin
 setFormat(sIdentFormat, SyntaxHighlighterChange.Run(getFormat(sIdentFormat)));
 UpdateSampleCode;
end;

procedure TEvSettingsForm.btn_cKeywordsClick(Sender: TObject);
begin
 setFormat(sKeywordFormat, SyntaxHighlighterChange.Run(getFormat(sKeywordFormat)));
 UpdateSampleCode;
end;

procedure TEvSettingsForm.btn_cMacrosClick(Sender: TObject);
begin
 setFormat(sMacroFormat, SyntaxHighlighterChange.Run(getFormat(sMacroFormat)));
 UpdateSampleCode;
end;

procedure TEvSettingsForm.btn_cNumbersClick(Sender: TObject);
begin
 setFormat(sNumberFormat, SyntaxHighlighterChange.Run(getFormat(sNumberFormat)));
 UpdateSampleCode;
end;

procedure TEvSettingsForm.btn_cOtherClick(Sender: TObject);
begin
 setFormat(sOtherFormat, SyntaxHighlighterChange.Run(getFormat(sOtherFormat)));
 UpdateSampleCode;
end;

procedure TEvSettingsForm.btn_cPrimaryTypesClick(Sender: TObject);
begin
 setFormat(sPrimaryTypesFormat, SyntaxHighlighterChange.Run(getFormat(sPrimaryTypesFormat)));
 UpdateSampleCode;
end;

procedure TEvSettingsForm.btn_cStringsClick(Sender: TObject);
begin
 setFormat(sStringFormat, SyntaxHighlighterChange.Run(getFormat(sStringFormat)));
 UpdateSampleCode;
end;

procedure TEvSettingsForm.CompilerFile_Select1Click(Sender: TObject);
begin
 if (EXEOpen.Execute) Then
  eVMFile.Text := EXEOpen.FileName;
end;

procedure TEvSettingsForm.CompilerFile_SelectClick(Sender: TObject);
begin
 if (EXEOpen.Execute) Then
  eCompilerFile.Text := EXEOpen.FileName;
end;

procedure TEvSettingsForm.eCompilerFileChange(Sender: TObject);
begin
 CheckTime := 4;
end;

procedure TEvSettingsForm.eVMFileChange(Sender: TObject);
begin
 CheckTime := 4;
end;

procedure TEvSettingsForm.FileTimerTimer(Sender: TObject);
begin
 Dec(CheckTime);

 { update file status }
 if (CheckTime < 0) Then
 Begin
  if (not FileExists(eCompilerFile.Text)) Then
   eCompilerFile.Color := clRed Else
   eCompilerFile.Color := clWhite;

  if (not FileExists(eVMFile.Text)) Then
   eVMFile.Color := clRed Else
   eVMFile.Color := clWhite;
 End;
end;

procedure TEvSettingsForm.p_1BeforeShow(ASender: TObject; ANewPage: TPage;
ANewIndex: Integer);
begin

end;

procedure TEvSettingsForm.SettingChange(Sender:TObject;Node:TTreeNode);
Var Page: Integer;
begin
 With Setting do
 Begin
  if (Node = nil) Then
   Exit;

  if (Node.Count = 0) Then
   Page := Node.ImageIndex Else
   Page := Node.Items[0].ImageIndex;

  Pages.PageIndex := Page;
 End;
end;

procedure TEvSettingsForm.btnCancelClick(Sender: TObject);
begin
 // remove config and replace with backup
 mSettings.FreeConfig;
 mDeleteFile(SettingsFile);
 mCopyFile(SettingsFileBackup, SettingsFile);
 mSettings.ReloadConfig;

 Close;
end;

procedure TEvSettingsForm.btnBGColorClick(Sender: TObject);
begin
 ColorDialog.Color := getColor(sEditorBackground);
 if (ColorDialog.Execute) Then
  mSettings.setColor(sEditorBackground, ColorDialog.Color);
 UpdateSampleCode;
end;

procedure TEvSettingsForm.btnFGColorClick(Sender: TObject);
begin
 ColorDialog.Color := getColor(sEditorForeground);
 if (ColorDialog.Execute) Then
  mSettings.setColor(sEditorForeground, ColorDialog.Color);
 UpdateSampleCode;
end;

end.

