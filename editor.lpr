program editor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, runtimetypeinfocontrols, uMainForm, uProjectSettings,
  uAboutForm, uEvSettingsForm, uSyntaxHighlighterChange,
  mLanguages, mSettings;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TProjectSettingsForm, ProjectSettingsForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TEvSettingsForm, EvSettingsForm);
  Application.CreateForm(TSyntaxHighlighterChange, SyntaxHighlighterChange);

  LoadLanguageFile('lang\'+getString(sLanguage));

  Application.Run;
end.

