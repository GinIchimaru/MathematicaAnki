(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



BeginPackage["AnkiExporter`",{"PackageUtils`"}];
ExportToAnki::usage ="Function exporting selected sections of the notebook to Anki using cloze notes";

Begin["`Private`"];

ExportToAnki[sync_:True]:=Module[{separator,styleTags,cells,sections,subsections,subsubsections,subsubsubsections,allinfo,cellids,celltags,data,cloze,matchEq,encoding,eqCloze,GetTOC,exported,filtered,splited,marked,paths,fixed,final,threaded,deck,title, base,dat,ndir,tempPicPath, allspecial,npath},
Run[OpenRead["!osascript -e 'tell application \"Anki\" to quit'"]];
separator="#";
ShowStatus["Export to Anki begins..."];
If[NotebookDirectory[]===$Failed,ShowStatus["Nothing to export"]; Abort[]];
tempPicPath=Quiet@Check[CreateDirectory["~/Dropbox/Anki/Ranza/collection.media/",CreateIntermediateDirectories-> True],"~/Dropbox/Anki/Ranza/collection.media/",CreateDirectory::filex];

TeXFix[what_]:=StringReplace[what,{"[/$]}}[$][/$]"-> "[/$]}}",("\\text{"~~c:Except["}"]..~~"}"):>(ToString@c)}];
TeXFixPoor[what_]:=StringReplace[what,{"[/$]}}[$][/$]"-> "[/$]}}"}];
EncodingFix[what_]:=FromCharacterCode[ToCharacterCode[what],"UTF8"];
ToTex[what_,n_:1]:=Convert`TeX`BoxesToTeX[what, "BoxRules"->{
"\[Transpose]":>"^{\\mathsf{T}}",
"\[ConjugateTranspose]":>"^{\\dagger} ",
"\[HermitianConjugate]":>"^{\\dagger} ",
"\[Conjugate]":>"^{*} ",
"\[OAcute]":> "\[OAcute]",
"\[CapitalOAcute]":> "\[CapitalOAcute]",
"\:015b":> "\:015b",
"\:015a":> "\:015a",
"\[CAcute]":> "\[CAcute]",
"\[CapitalCAcute]":> "\[CapitalCAcute]",
"\:0119":> "\:0119",
"\:0118":> "\:0118",
"\:0105":> "\:0105",
"\:0104":> "\:0104",
"\[LSlash]":> "\[LSlash]",
"\[CapitalLSlash]":> "\[CapitalLSlash]",
"\:017c":> "\:017c",
"\:017b":> "\:017b",
"\:017a":>"\:017a",
"\:0179":>"\:0179",
"\:0144":>"\:0144",
"\:0143":>"\:0143",

FormBox[GraphicsBox[{C__},E___,ImageSize->D_],__]|GraphicsBox[{C__},E___,ImageSize->D_]:>("\\includegraphics[natwidth="<>ToString[(First@D)/4]<>",natheight="<>ToString[(First@D)/4]<>"]{"<>FileNameTake@Export[tempPicPath<>"f"<>ToString[Hash[Graphics[{C},E]]]<>".png",Graphics[{C},E],ImageSize->{First@D,First@D}]<>"} "),
FormBox[GraphicsBox[___],___]:> "",
GraphicsBox[___]:> "",

StyleBox[D_,Background->LightGreen]:>"\\color[HTML]{1111FF}{{c"<>ToString[n]<>"::"<>StringReplace[ToTex[D],{"{{":>" { { ","}}":>" } } "}]<>" }}\\color[HTML]{000000}"}];

cells=Cells[EvaluationNotebook[],CellStyle->{"Text","EquationNumbered","Equation","Figure","Item1","Item2","Item3","Item1Numbered","Item2Numbered","Item3Numbered","Theorem","Example","Proof","Axiom","Solution","Definition"}];

title=First@(Cases[NotebookGet@EvaluationNotebook[],Cell[name_,style:"Title",___]:>name,Infinity]/.{}-> {""});
ShowStatus["Gathering section info..."];
sections=CurrentValue[#,{"CounterValue","Section"}]&/@cells;
subsections=CurrentValue[#,{"CounterValue","Subsection"}]&/@cells;
subsubsections=CurrentValue[#,{"CounterValue","Subsubsection"}]&/@cells;
subsubsubsections=CurrentValue[#,{"CounterValue","Subsubsubsection"}]&/@cells;
celltags=ToString[StringJoin[separator,Riffle[If[MatchQ[CurrentValue[#,{"CellTags"}],_String],{CurrentValue[#,{"CellTags"}]},CurrentValue[#,{"CellTags"}]]," "]]]&/@cells;
allinfo=DeleteCases[Replace[Thread[{sections,subsections,subsubsections,subsubsubsections}],{x___,0...}:>{x},1],0,2];
ShowStatus["Gathering table of contents"];
GetTOC=Cases[NotebookGet@EvaluationNotebook[],Cell[name_,style:"Section"|"Subsection"|"Subsubsection"|"Subsubsubsection",___]:>{style,Convert`TeX`BoxesToTeX[ name,"BoxRules"->{D_String:>D}]},Infinity]/.{"Subsubsubsection",x_}:>x[]//.
{x___,{"Subsubsection",y_},z:Except[_List]...,w:PatternSequence[{_,_},___]|PatternSequence[]}:>{x,y[z],w}//.{x___,{"Subsection",y_},z:Except[_List]...,w:PatternSequence[{_,_},___]|PatternSequence[]}:>{x,y[z],w}//.{x___,{"Section",y_},z:Except[_List]...,w:PatternSequence[{_,_},___]|PatternSequence[]}:>{x,y[z],w};
ShowStatus["Preparing paths..."];
paths=(StringJoin[separator,title<>"/"<>Riffle[Head/@(GetTOC[[#/.List->Sequence]]&/@Reverse@NestList[Most,#,Length[#]-1]),"/"]])&/@allinfo;
ShowStatus["Extracting data... (1/3)"];
data=NotebookRead@cells;
dat=Block[{n=1},ReplaceRepeated[data,
{
ButtonBox[DynamicBox[C_,___],___]:> Evaluate@C,
ButtonBox[RowBox[C__],___]:> C,
CounterBox["FigureCaptionNumbered",N_]:> (First@Cases[data,Cell[TextData[name__],___,"Figure",___,CellTags->N,___]:>name,Infinity]),
CounterBox["EquationNumbered",N_]:> ("[$]"<>ToTex[First@Cases[data,Cell[name_,___,CellTags->N,___]:>name,Infinity]]<>"[/$] "),
CounterBox[___]:>"",
StyleBox[D__,Background->None,E___]:>StyleBox[D,E],
StyleBox[D_String]:>D,
RowBox[{C__String}]:>StringJoin@C,
Cell[TextData[data_],style_,___, CellID->Nr_Integer]:> {Nr ,data,style},
Cell[BoxData[data_],style_,___, CellID->Nr_Integer]:> {Nr ,data,style},
Cell[data_,style_,___, CellID->Nr_Integer]:> {Nr ,data,style},
Cell[BoxData[data_],___]:> data
}]];

ShowStatus["Extracting data... (2/3)"];
PrintToConsole["Identified Ank collection folder "<>tempPicPath];
dat=Block[{pic=0},ReplaceAll[dat,{
FormBox[GraphicsBox[{C__,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[0.6]}],R__RectangleBox},D___},E___],__]|GraphicsBox[{C__,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[0.6]}],R__RectangleBox},D___},E___]:>"{{c1::<img src=\""<>FileNameTake@Export[tempPicPath<>"f"<>ToString[++pic]<>ToString[Hash[Graphics[{C,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[1.0]}],R},D},E]]]<>"a.png",Cell[BoxData[GraphicsBox[{C,D},E]]]]<>"\">::<img src=\""<>FileNameTake@Export[tempPicPath<>"f"<>ToString[pic]<>ToString[Hash[Graphics[{C,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[1.0]}],R},D},E]]]<>".png",Cell[BoxData[GraphicsBox[{C,{FaceForm[{RGBColor[0.88,1,0.88],Opacity[1.0]}],R},D},E]]]]<>"\">}}",
(FormBox[C__, TraditionalForm]|FormBox[C__, TextForm]):>("[$]"<>ToTex[C]<>"[/$] "),
FormBox[GraphicsBox[___],___]:> "",GraphicsBox[___]:> "",
FormBox[RowBox[{E___,TraditionalForm}],___]:> FormBox[RowBox[{E}],TraditionalForm]
}]];
ShowStatus["Extracting data... (3/3)"];
dat=Block[{n=1},ReplaceAll[dat,{
(FormBox[RowBox[{C__String}],TextForm]|FormBox[RowBox[{C__String}],TraditionalForm]):>StringJoin@C,
(FormBox[C__, TraditionalForm]|FormBox[C__, TextForm]):>("[$]"<>ToTex[C]<>"[/$] "),
StyleBox[D_,E___ ,Background->LightGreen,F___]:>("{{c"<>ToString[n]<>"::"<>
ReplaceAll[StyleBox[D,E,F],{
StyleBox[U_String,___,FontWeight->"Bold",___]:> ("<b>"<>U<>"</b>"),
StyleBox[U_String,___,FontSlant->"Italic",___]:> ("<i>"<>U<>"</i>"),
StyleBox[U_String,___,FontWeight->"Plain",___]:> U,
StyleBox[U_String,___,FontVariations->{___,"Underline"->True,___},___]:> ("<u>"<>U<>"</u>"),
StyleBox[U_String,___,FontVariations->__,___]:> U,
StyleBox[U_String,___]:>U
}]<>"}}"),
StyleBox[D_String,___,FontWeight->"Bold",___]:> ("<b>"<>D<>"</b>"),
StyleBox[D_String,___,FontSlant->"Italic",___]:> ("<i>"<>D<>"</i>"),
StyleBox[D_String,___,FontWeight->"Plain",___]:> D,
StyleBox[D_String,___,FontVariations->{___,"Underline"->True,___},___]:> ("<u>"<>D<>"</u>"),
StyleBox[D_String,___,FontVariations->__,___]:> D,
StyleBox[D_, Background->_]:>ToString[n],
RowBox[{C___String}]:>StringJoin@C
}]];
ShowStatus["Fixing data... (1/2)"];
base=(ToString[First@#]<>separator <> StringReplace[StringJoin[#[[2]]],{"\n"-> "<br>","\[LineSeparator]"-> "<br>"}])&/@ dat;
styleTags=(" "<>#[[3]]<>"::"<> StringReplace[title," "-> ""])&/@dat;
ShowStatus["Fixing data... (2/2)"];
base=StringReplace[base,{
("}}\\color[HTML]{000000}\\color[HTML]{1111FF}{{c"~~Shortest[c__]~~"::")->"",
"}}{{c"~~Shortest[c__]~~"::"->"",
"[$][/$]"->"",
"{{c1::}}"->"",
"{{c1::<br>}}"->"<br>",
("^{"~~Shortest[c__]~~"}^{"~~WhitespaceCharacter...~~"\\dagger"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"\\dagger}",
("^"~~c_~~"^{"~~WhitespaceCharacter...~~"\\dagger"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"\\dagger}",

("^{"~~Shortest[c__]~~"}^{\\mathsf{T}"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"\\mathsf{T}}",
("^"~~c_~~"^{"~~WhitespaceCharacter...~~"\\mathsf{T}"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"\\mathsf{T}}",

("^{"~~Shortest[c__]~~"}^{"~~WhitespaceCharacter...~~"*"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"*}",
("^"~~c_~~"^{"~~WhitespaceCharacter...~~"*"~~WhitespaceCharacter...~~"}")/;StringFreeQ[c,"}"|"{"]:>"^{"<>c<>"*}",

"\\overset{"~~WhitespaceCharacter...~~"\\mathsym{"~~WhitespaceCharacter...~~"\\OverBracket"~~WhitespaceCharacter...~~"}"~~WhitespaceCharacter...~~"}":> "\\overbrace",
"\\underset{"~~WhitespaceCharacter...~~"\\mathsym{"~~WhitespaceCharacter...~~"\\UnderBracket"~~WhitespaceCharacter...~~"}"~~WhitespaceCharacter...~~"}":> "\\underbrace",
(*,("\\text{"~~Shortest[c__]~~"}")\[RuleDelayed]ToString@StringReplace[c,{"$"\[RuleDelayed]  ""}] *)
"\\left\\left|"~~Shortest[c__]~~"\\right\\right|":> "\\left|"~~c ~~"\\right|",
"\\right\\right| "~~WhitespaceCharacter...~~"{}_":> "\\right|_",
"\\right\\right| "~~WhitespaceCharacter...~~"_":> "\\right|_"
}];
ShowStatus["Preparing final structure..."];
npath=NotebookFileName[EvaluationNotebook[]];
final=MapThread[StringJoin,{base,paths,ConstantArray[StringJoin[separator,NotebookFileName[EvaluationNotebook[]]],Length[paths]],celltags}];
final=MapThread[StringJoin,{final,styleTags}];
ShowStatus["Filtering..."];
filtered=Select[final,StringMatchQ[#,"*{{c@::*"] & ];

ShowStatus["Exporting..."];
Export["text.txt",filtered];
ndir=NotebookDirectory[EvaluationNotebook[]];
deck=StringReplace[StringReplace[ndir,e___~~"/Knowledge/" ~~ f___ ~~"/":> f],"/":>"::"];
PrintToConsole[deck];
ShowStatus["Importing to Anki..."];
PrintToConsole[filtered];
PrintToConsole[Import[("!export PYTHONPATH=/usr/local/lib/python2.7/site-packages:$PYTHONPATH;python ~/Projects/anki/runimport -p Ranza -d "<>deck<> " -s "<>ToString[sync]<>" ~/text.txt"),"Text"]];
PrintToConsole[filtered];
ShowStatus["Exported "<>ToString[Length@filtered]<>"/"<>ToString[Length@final]<>" cells to anki"];
PrintToConsole["Finished exporting"];
];
End[];
EndPackage[];
