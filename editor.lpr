(*
 SScript Editor
 Copyright � by Patryk Wychowaniec, 2013

 -------------------------------------------------------------------------------
 SScript Compiler is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation; either version 2.1 of the License, or
 (at your option) any later version.

 SScript Compiler is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with SScript Compiler; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA 
*)
{$MODE OBJFPC}{$H+}
program editor;
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, SysUtils, Forms, lazcontrols,
  runtimetypeinfocontrols, uMainForm, uProjectSettings,
  uAboutForm, uEvSettingsForm, uSyntaxHighlighterChange, Controls,

  mLanguages, mSettings, uCompilerOutput, uFindForm,
  uIdentifierListForm, uCompileStatusForm, uCodeEditor, virtualtreeview_package,
  Dialogs, mLayout, uLayoutManagerForm;

{$R *.res}

begin
 RequireDerivedFormResource := True;
 Application.Initialize;

 DefaultFormatSettings.DecimalSeparator := '.';

 Application.CreateForm(TMainForm, MainForm);
 Application.CreateForm(TProjectSettingsForm, ProjectSettingsForm);
 Application.CreateForm(TAboutForm, AboutForm);
 Application.CreateForm(TEvSettingsForm, EvSettingsForm);
 Application.CreateForm(TSyntaxHighlighterChange, SyntaxHighlighterChange);
 Application.CreateForm(TCompilerOutputForm, CompilerOutputForm);
 Application.CreateForm(TFindForm, FindForm);
 Application.CreateForm(TIdentifierListForm, IdentifierListForm);
 Application.CreateForm(TCompileStatusForm, CompileStatusForm);
 Application.CreateForm(TCodeEditor, CodeEditor);
 Application.CreateForm(TLayoutManagerForm, LayoutManagerForm);

 { load layout }
 mLayout.Reload;

 { load language }
 LoadLanguageFile(ExtractFilePath(ParamStr(0))+'lang/'+getString(sLanguage));
 MainForm.OnLanguageLoaded;

 { run application }
 Application.Title := 'SScript Editor';
 Application.Run;

 { save layout }
 CurrentLayout.Update;
 CurrentLayout.SaveToFile(getString(sLayoutFile));
end.

