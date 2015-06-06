program Red_Stone_Mania;
uses windos,vesa,objects,crt,mouse,keyboard;
const screen='sprites\texbutt.dat';
      item:set of byte=[4,6,8];
      pause=4000;
      iten:set of byte=[4,6,8,0];
      xmpt=28;
      ympt=22;
      cmLoadtext=7;
      cmLoadMap=2;
      cmFile=4;
      cmSave=3;
      cmEdit=5;
      cmExit=255;
      cmCompile=9;
      cmRun=8;
      cmHelp=6;
      cmRe=32;
      demo1=101;
      demo2=102;
      demo3=103;
      demo4=104;
      demo5=105;

      cmNewmap=30;
      cmNewText=29;
      cmsavemap=31;
      instrNo=20;
      instrPIK=10;
      instrLop=30;
type tbutton=record
             x1,y1,x2,y2:integer;
             s:string;
             sost,ns:integer;
             f:boolean;
             end;
    txt=^ntxt;
    ntxt=record
         up,down:txt;
         s:string;
         end;
    button=array [0..10] of tbutton;
    tpic=array [0..210] of pointer;
var
    izmena,all,bool:boolean;
    maxbutton,ercol:integer;
    teki,visabli,kgold:integer;
    namemap,nametxt:string;
    pic:tpic;
    tekstr,tekstay:integer;
    tsm:integer;
    butt:button;
    ngold:integer;
    sG,sN:string;
    xmaster,ymaster:integer;
    t,tkursor:byte;
    intext,visabl,tek:txt;
    namef:string;
    butsost,j:integer;
    errorf:boolean;
    page,sb:byte;
    yhero,xhero:byte;
    pole:array [0..9,0..9] of byte;
    polelast:array [0..9,0..9] of byte;
type Ident=(cmProg,cmIf,cmThen,cmElse,cmRVar,cmBegin,cmEnd,cmFor,cmWhile,
            cmDO,cmRepeat,cmTake,cmUntil,cmEnd_If,cmTo,cmDOwnto,cmFrom,
            cmInt,cmReal,cmChar,cmAnd,cmOr,cmNot,cmTZ,cmTT,cmZP,cmT,cmLeft,
            cmRight,cmUp,cmDown,cmEqu,cmNumber,cmLess,cmMore,cmNotEqu,
            cmLessEqu,cmMoreEqu,cmLeftB,cmRightB,cmPrisv,cmDiv,cmUmn,cmplus,
            cmminus,cmWork_Up,cmWork_down,cmWork_right,CmWork_left,cmWhat_up,
            cmWhat_down,cmWhat_right,cmWhat_left,cmWhat_take,
            cmStone,cmSoil,cmEmpty,cmPik,cmLop,cmGold
            ,cmstring,cmIdent);
     iden=(cmVariable,cmOperation);
     str_15=string[15];
     pRef=^ttNode;
     ttNode=record
                 l,r:pRef;
                 case TypeNode:byte of
                 1:(num:real);
                 2:(index:integer);
                 3:(oper:string[3]);
                 4:(str:string);
                 5:(konst:ident);
                 end;
     ref=^node;
     node=record
                lit:char;
                l,r:ref;
          end;
     alf='А'..'Я';
     tVar=record
          Name:str_15;
          case type_:ident of
          cmInt:(ZnachI:integer);
          cmReal:(ZnachR:real);
          cmChar:(ZnachCh:string);
          end;
     pZnach=^tZnach;
     tZnach=record
            p:integer;
            f:boolean;
            end;
     pNode=^tNode;
     tNode=record
           n:integer;
           next:pNode;
           str:integer;
           case typ:ident of
           cmIf:(Then_,Else_:pNode;
                 usl:pref;);
           cmFor:(ForI:integer;
                  body:pNode;
                  nz,kz:pZnach;
                  dfor:boolean);
           cmwhile:(bodyW:pNode;
                  uslW:pref);
           cmrepeat:(bodyr:pNode;
                  uslr:pref);
           cmPrisv:(index:integer;
                   znach:pref;)
           end;
     setC=set of char;
     tVarM=array[0..100] of tVar;
     picture=array [1..10] of pointer;
     tvalue=array[alf]of real;
const MaxLex=61;
      operation:set of ident=[cmrepeat,cmWhile,cmIf,cmLeft,cmRight,cmFor,cmUp,
      cmDown,cmIdent,cmTake,cmWork_Up,cmWork_down,cmWork_right,CmWork_left];

      maxL=100;
      MaxStack=100;
      MainLex:array [Ident] of str_15=('программа','если','тогда',
      'иначе','переменные','начало','конец','для','пока','ок','повторять',
      'взять','покане','к_если','до','уменьш','от','целый','дробный',
      'символ','и','или','не',';',':',',','.','влево','вправо','вверх',
      'вниз','=','','<','>','<>','<=','>=','(',')',':=','/','*','+','-',
      '!вверх','!вниз','!вправо','!влево','?вверху','?внизу','?справа',
      '?слева','?взято','КАМЕНЬ','ЗЕМЛЯ','ПУСТО','КИРКА','ЛОПАТА','ЗОЛОТО',
      '','');

      ID=['Й','Ц','У','К','Е','Н','Г','Ш','Щ','З','Х','Ф','Ы','В','А','П',
      'Р','О','Л','Д','Ж','Э','Я','Ч','С','М','И','Т','Ь','Б','Ю','й','ц',
      'у','к','е','н','г','ш','щ','з','х','ф','ы','в','а','п','р','о','л',
      'д','ж','я','ч','с','м','и','т','ь','б','ю','0'..'9','_','!','?'];
      MaxBuffer=50;
      konst=[cmEmpty,cmPik,cmLop,cmGold,cmSoil];
      vopr=[cmWhat_up,
            cmWhat_down,cmWhat_right,cmWhat_left,cmWhat_take];
type tStack=array [1..MaxStack] of integer;
     tStackL=array [1..maxL] of pNode;
     tVarName=array[1..MaxBuffer]of Str_15;
     pwin=^tWin;
     tWin=record
          up,down:pwin;
          dir:tsearchrec;
          end;
var varN:tVarM;
    dir:twin;
    INStr:integer;
    inwin,tekwin,viswin:pwin;
    value:tvalue;
    memory:pointer;
    StackL:tStackL;
    Buffer:tVarName;
    Stack:tStack;
    num,nz:alf;
    Mass:array [alf] of pref;
    NumberVar:integer;
    bolv:ident;
    Top,TopL,TopBuffer:integer;
    st,textError:string;
    i:integer;
    f:text;
    Last,Code:pNode;
    ch:Ident;
    Lex:string;
    LexNumb:integer;
    lang:boolean;{true-LAT false-РУС}
function count2(x1,x2:txt):integer;
var x:txt;
    i:integer;
begin
     x:=x1;
     i:=0;
     while x<>x2 do
     begin
          x:=x^.down;
          inc(i);
     end;
     count2:=i;
end;
{procedure makenum(i:integer;n:integer);
var j:integer;
    t:txt;
begin
     t:=intext;
     j:=1;
     for j:=2 to i do
     t:=t^.down;
     if t<>nil
     then begin
          visabl:=t;
          for j:=i to n do
          t:=t^.down;
          tek:=t;
     end;
     teki:=0;
     visabli:=0;
end;}
procedure makefirst(i:integer);
var j:integer;
    t:txt;
begin
     t:=intext;
     j:=1;
     for j:=2 to i do
     t:=t^.down;
     if t<>nil
     then begin
          tek:=t;
          visabl:=t;
     end;
     teki:=0;
     visabli:=0;
end;
procedure destroyTXT(var intext:txt);
var tk,dl:txt;
begin
     if intext^.down<>nil
     then
     begin
          tk:=intext;
          dl:=intext;
          while dl<>nil do
          begin
               if tk<>nil
               then tk:=tk^.down;
               dispose(dl);
               dl:=tk;
          end;
          new(intext);
     end; intext^.s:='';
     intext^.up:=nil;
     intext^.down:=nil;
end;
{procedure destroyTXT(var intext:txt);
var tx,tp:txt;
begin
     if (intext<>nil)and(intext^.down<>nil)
     then
     begin
          tx:=intext^.down;
          intext^.s:='';
          intext^.up:=nil;
          intext^.down:=nil;
          while tx<>nil do
          begin
               if tx^.down=nil
               then begin
                    tp:=tx;
                    tx:=nil;
                    end
               else begin
               dispose(tx^.up);
               tx:=tx^.down;
               end;
          end;
          if tp<>nil
          then dispose(tp);
          new(intext);
     end;
     intext^.s:='';
     intext^.up:=nil;
     intext^.down:=nil;
end;}
procedure language(l:string);forward;
function mousein(x1,y1,x2,y2:integer):boolean;forward;
procedure makekursor(var tek:txt;var teki:integer);
var i,j:integer;
    tx:txt;
begin
     i:=1;
     j:=1;
     tx:=visabl;
     while (not mousein(400,35+15*i,700,35+15*(i+1)))
     and(tx<>nil) do
     begin
          tx:=tx^.down;
          inc(i);
     end;

     if tx<>nil
     then begin
     j:=visabli;
while (not mousein(452+(j-visabli)*textwidth(' '),35+15*i,452+(j-visabli+1)*textwidth(' '),35+25*(i+1)))
     and(j<length(tx^.s)) do
     begin
          inc(j);
     end;
     if j<=30
     then teki:=j;
     tek:=tx;
     end;
end;

procedure saveText;forward;
procedure saveORnot(map:boolean);
const x1=150;y1=200;x2=450;y2=300;
      xok11=150;
      yok11=250;
      xok12=300;
      yok12=300;

      xok21=300;
      yok21=250;
      xok22=450;
      yok22=300;
var x:longint;
    wt:string;
    s:char;
    ex:boolean;
begin
     if map
     then wt:='у карту ?'
     else wt:='от текст ?';
     setvisualpage(page);
     waitvbl;
     page:=1-page;
     setactivepage (page);
     drawscreen (x1,y1,x2,y2,'sprites/mib3.tex');
     ramka(x1-10,y1-10,x2+10,y2+10);
     drawbutton (xok11,yok11,xok12,yok12,'ДА',false,false);
     drawbutton (xok21,yok21,xok22,yok22,'НЕТ',false,false);
     outtextxy(x1+((x2-x1)div 2)-(textwidth('Сохраниь эт'+wt)div 2),y1+20,'Сохраниь эт'+wt);
     setvisualpage(page);
     waitvbl;
     page:=1-page;
     setactivepage (page);
     drawscreen (x1,y1,x2,y2,'sprites\mib3.tex');
     ramka(x1-10,y1-10,x2+10,y2+10);
     drawbutton (xok11,yok11,xok12,yok12,'ДА',false,false);
     drawbutton (xok21,yok21,xok22,yok22,'НЕТ',false,false);
     outtextxy(x1+((x2-x1)div 2)-(textwidth('Сохраниь эт'+wt)div 2),y1+20,'Сохраниь эт'+wt);
     ex:=false;
     repeat
           if mousebutton=1
           then begin
                while mousebutton=1 do;

                if mousein (xok11,yok11,xok12,yok12)
                then begin
                     ex:=true;
                     language('eng');
                     savetext;
                     language('rus');
                     end;

                if mousein (xok21,yok21,xok22,yok22)
                then ex:=true;
           end;
           x:=readkeyboard(s);
     until (x=kesc)or(x=kenter)or(ex);
end;
function pStrok(s:string):pchar;
var i:integer;
    ss:pchar;
begin
     i:=1;
     new(ss);
     for i:=0 to length(s)-1 do
     ss[i]:=s[i+1];
     ss[i+1]:=#0;
     pstrok:=ss;
end;
function findInDir(s:pchar):boolean;
var d:tsearchrec;
begin
     findfirst(s,faanyfile,d);
     findindir:=doserror=0;
end;
procedure outwin(main:boolean);
const maxwr=17;
var tz:pwin;
    i:integer;
begin
     tz:=viswin;
     i:=1;
     if main
     then  setcolor(255)
     else setcolor(30);
     if viswin<>nil
     then
     repeat
     if (tz=tekwin)and(main)
     then begin
          setcolor(14);
          outtextxy(110,90+15*i,tz^.dir.name);
          if main
          then  setcolor(255)
          else setcolor(50);
          end
     else outtextxy(110,90+15*i,tz^.dir.name);
     tz:=tz^.down;
     inc(i);
     until (tz=nil)or(i=maxwr);
end;
procedure buildDir(s:pchar);
var dd:tsearchrec;
    d:pwin;
begin
     new(inwin);
     tekwin:=inwin;
     viswin:=inwin;
     d:=inwin;
     inwin^.up:=nil;
     new(d^.down);
     FindFirst(s, faanyfile, Dd);
     if doserror=0
          then  begin
          d^.dir.name:=dd.name;

          d^.down^.up:=d;
          d:=d^.down;
          end
     else begin
          inwin:=nil;
          viswin:=nil;
          tekwin:=nil;
          end;
     While DosError = 0 Do
     Begin
          FindNext(Dd);
          if doserror=0
          then  begin
          d^.dir.name:=dd.name;
          new(d^.down);
          d^.up^.down:=d;
          d^.down^.up:=d;
          d:=d^.down;
          end;
     End;
     d^.up^.down:=nil;
     d^.up:=nil
end;
procedure massage(text:string);
const x1=150;y1=200;x2=450;y2=300;
      xok1=250;
      yok1=250;
      xok2=350;
      yok2=300;
var x:longint;
    s:char;
    ex:boolean;
begin
     setvisualpage(page);
     waitvbl;
     page:=1-page;
     setactivepage (page);
     drawscreen (x1,y1,x2,y2,'sprites\mib3.tex');
     ramka(x1-10,y1-10,x2+10,y2+10);
     drawbutton (xok1,yok1,xok2,yok2,'OK',false,false);
     outtextxy(x1+((x2-x1)div 2)-(textwidth(text)div 2),y1+20,text);
     setvisualpage(page);
     waitvbl;
     page:=1-page;
     setactivepage (page);
     drawscreen (x1,y1,x2,y2,'sprites\mib3.tex');
     ramka(x1-10,y1-10,x2+10,y2+10);
     drawbutton (xok1,yok1,xok2,yok2,'OK',false,false);
     outtextxy(x1+((x2-x1)div 2)-(textwidth(text)div 2),y1+20,text);
     ex:=false;
     repeat
           if mousebutton=1
           then begin
                while mousebutton=1 do;

                if mousein (xok1,yok1,xok2,yok2)
                then ex:=true;
           end;
           x:=readkeyboard(s);
     until (x=kesc)or(x=kenter)or(ex);
end;
procedure language(l:string);
begin
     if l='eng'
     then begin
          if not lang
          then begin
               switchlanguage;
               lang:=not lang;
               end;
          end
     else if  lang
          then begin
               switchlanguage;
               lang:=not lang;
               end;
end;
procedure error (text:string);
begin
     texterror:=text;
     ercol:=red;
     errorF:=true;
     if tekstr>(count2(intext,visabl)+xmpt)
     then makefirst(tekstr-20)
     else if tekstr<(count2(intext,visabl))
          then makefirst(tekstr);
     exit;
end;
procedure errori (text:string;t:integer);
begin
     texterror:=text;
     ercol:=yellow;
     tekstr:=t;
     errorF:=true;
     if tekstr>(count2(intext,visabl)+xmpt)
     then makefirst(tekstr-20)
     else if tekstr<(count2(intext,visabl))
          then makefirst(tekstr);
     exit;
end;
function getlex:ident;
var i,code:integer;
    ii:ident;
    b,re:boolean;
begin
     b:=true;
     re:=false;
     while (st='')and(not(eof(f))) do
     begin
          inc(tekstr);
          if (eof(f))and(ch<>cmT)
          then begin
          error('Непредвиденный конец файла');
          exit;
          end;
           readln (f,st);
     end;
     i:=1;
     if st=''
     then all:=true;
     while st[i]=' ' do
      inc (i);
     delete (st,1,i-1);
     if (st='')and(not(all))
     then begin
          re:=true;
          getlex:=getlex;
          end;
     i:=1;
     if (not re)and(not all)
     then
     begin
     case st[i] of
     '<','>':begin
                  if  st[2] in ['>','=']
                  then i:=2
                  else i:=1;
                  Lex:=copy (st,1,i);
                  delete (st,1,i);
             end;
     '.',':',';',',','=','(',')','/','*','+','-':begin
                         if (st[1]=':')and(st[2]='=')
                         then i:=2
                         else i:=1;
                         Lex:=copy (st,1,i);
                         delete (st,1,i);
                    end;
     '0'..'9':begin
                   while st[i] in ['0'..'9','.'] do
                    inc(i);
                   Lex:=copy (st,1,i-1);
                   val (Lex,LexNumb,code);
                   delete (st,1,i-1);
                   Getlex:=cmNumber;
                   exit;
              end;
     '"':begin
               inc(i);
               if st[i] in ID
               then begin
                    while st[i] in ID do
                     inc(i);
                     Lex:=copy (st,2,i-2);
                    delete (st,1,i);
                    getlex:=cmString;
                    b:=false;
               end
          end;
     else if st[i] in ID
          then begin
                    while st[i] in ID do
                     inc(i);
                    Lex:=copy (st,1,i-1);
                    delete (st,1,i-1);
               end
          else begin
               error ('Недопустимый символ "'+st[i]+'"');
               exit;
               end;
     end;
     if b then
     begin
     ii:=cmProg;
     while (MainLex[ii]<>Lex)and(byte(ii)<MaxLex) do
      inc (ii);
     GetLex:=ii;
     end;
     end;
end;
procedure push (x:integer);
begin
     if top=MaxStack
     then error ('Стек переполнен')
     else begin
               inc(top);
               Stack[top]:=x;
          end;
end;
function pop:integer;
begin
     if Top=0
     then error ('Стек пуст')
     else begin
               pop:=Stack[top];
               dec(Top);
          end;
end;
procedure RemIn (s:str_15);
begin
     if topBuffer=MaxBuffer
     then error ('Буфер переполнен')
     else begin
               inc(topBuffer);
               Buffer[topbuffer]:=s;
          end;
end;
function RemOut:Str_15;
begin
     if TopBuffer=0
     then error ('Буфер пуст')
     else begin
               RemOut:=Buffer[topBuffer];
               dec(TopBuffer);
          end;
end;
procedure FillPerem (tip:Ident);
begin
     while topBuffer>0 do
      begin
           inc(NumberVar);
           VarN[NumberVar].Type_:=tip;
           VarN[NumberVar].Name:=RemOut;
           case tip of
           cmInt:VarN[NumberVar].ZnachI:=0;
           cmReal:VarN[NumberVar].ZnachR:=0.0;
           cmChar:VarN[NumberVar].ZnachCh:=#0;
           end;
      end;
end;
function newelem (typ:ident):pNode;
var p:pNode;
begin
     new (p);
     p^.Typ:=Typ;
     p^.next:=nil;
     p^.n:=tekstr;
     case typ of
     cmIf:begin
               p^.then_:=nil;
               p^.else_:=nil;
          end;
     cmFor:begin
               p^.body:=nil;
               p^.nz:=nil;
               p^.kz:=nil;
               p^.dfor:=false;
               p^.fori:=0;
          end;
     end;
     newelem:=p;
end;
procedure pushL(l:pNode);
begin
     if TopL=MaxL
     then begin
          error ('Стек переполнен');
          exit;
          end
     else begin
               inc(Topl);
               StackL[TopL]:=l;
          end;
end;
Function popL:pNode;
begin
     if TopL=0
     then begin
          error ('Стек пуст');
          exit;
          end
     else begin
               popL:=StackL[TopL];
               dec(TopL);
          end;
end;
procedure addelem (p:pNode);
begin
     last^:=p^;
end;
function NewEl(typez:integer;c:char):pref;
var tz:pref;
begin
     new(tz);
     tz^.l:=nil;
     tz^.r:=nil;
     case typez of
     1:tz^.num:=0;
     2:tz^.index:=0;
     end;
     newEl:=tz;
end;
procedure arif(var st:string;m:SetC);
var i:integer;
    tz:pref;
    ss:string;
    f:boolean;
begin
     if errorF
     then exit;
     f:=false;
     repeat
           i:=1;
           while (not(st[i] in m)and(i<length(st))) do
           inc (i);
           ss:=st[i];
           if st[i] in m
           then begin
                     tz:=newel(1,st[i]);
                   if st[i]=#6
                   then tz^.l:=nil
                   else if st[i-1]in ['А'..'Я']
                        then  tz^.L:=mass[st[i-1]]
                        else tz^.L:=NewEl(1,st[i-1]);
                     if st[i+1]in ['А'..'Я']
                     then tz^.R:=mass[st[i+1]]
                     else tz^.R:=NewEl(1,st[i+1]);
                     tz^.oper:=ss;
                     if st[i]=#6
                     then begin
                          Delete(st,i+1,2);
                          inc(nz);
                          Mass[Nz]:=tz;
                          st[i]:=nz;
                          end
                     else begin
                          Delete(st,i-1,2);
                          inc(nz);
                          Mass[Nz]:=tz;
                          st[i-1]:=nz;
                          end;
                end
                else f:=true;
     until f;
end;
procedure newZnach (var x:ttnode;typz:byte);
begin
     x.typenode:=typz;
end;
function index (l:string):integer;
var i:integer;
begin
     varN[numbervar+1].name:=l;
     i:=1;
     while (varN[i].name<>l)and(i<=numbervar) do
     inc(i);
     if i=numbervar+1
     then index:=0
     else index:=i;
end;
procedure replaceperem(ch:ident;var l:string);
var i:integer;
    x:ttnode;
    code:integer;
begin
     case ch of
     cmNumber:begin
                   inc(nz);
                   new(mass[nz]);
                   mass[nz]^.l:=nil;
                   mass[nz]^.r:=nil;
                   mass[nz]^.typenode:=1;
                   val(l,mass[nz]^.num,code);
                   val(l,value[nz],code);
                   l:=nz;
                   end;
     cmIdent:begin
                  if index(l)<>0
                  then begin
                  inc(nz);
                  new(mass[nz]);
                  mass[nz]^.typenode:=2;
                  mass[nz]^.l:=nil;
                  mass[nz]^.r:=nil;
                  mass[nz]^.index:=index(l);
                  l:=nz;
                  end
                  else begin
                       error('Неизвестный идентификатор');exit;
                  end;
             end;
     cmstring:begin
                   inc(nz);
                   new(mass[nz]);
                   mass[nz]^.l:=nil;
                   mass[nz]^.r:=nil;
                   mass[nz]^.typenode:=4;
                   mass[nz]^.str:=lex;
                   l:=nz;
                   end;
     cmMoreEqu:l:=#1;
     cmlessequ:l:=#2;
     cmNotequ:l:=#3;
     cmAnd:l:=#4;
     cmOr:l:=#5;
     cmNot:l:=#6;
     cmwhat_up,
     cmwhat_down,
     cmwhat_right,
     cmwhat_left,
     cmwhat_take,cmstone,cmsoil,cmempty,cmpik,cmlop,cmGold:begin
                   inc(nz);
                   new(mass[nz]);
                   mass[nz]^.l:=nil;
                   mass[nz]^.r:=nil;
                   mass[nz]^.typenode:=5;
                   mass[nz]^.konst:=ch;
                   l:=nz;
                   end;
     end;
end;
function calc (st:string):pref;
begin
     arif(st,['*','/']);
     arif(st,['+','-']);
     arif(st,['>','<','=']);
     arif(st,[#1{>=},#2{<=},#3{<>}]);
     arif(st,[#4{i},#5{ili},#6{ne}]);
     calc:=mass[st[1]]
end;
function calcscob (st:string):pref;
var f:boolean;
    i,j:integer;
    tz:pref;
begin
     if errorF
     then exit;
     f:=false;
     calcScob:=nil;
     repeat
            i:=pos(')',st);
            if i<>0
            then begin
                      j:=i;
                      while (st[j]<>'(')and(j>0) do
                      dec (j);
                      if j=0
                      then begin
                           error ('Ошибка скобочной структуры');
                           exit;
                           end;
                      tz:=calc(copy(st,j+1,i-j-1));
                      delete(st,j,i-j);
                      inc(nz);
                      mass[nz]:=tz;
                      st[j]:=nz;
                  end
              else f:=true;
     until f;
     if length(st)<>1
     then calcscob:=calc(st)
     else calcscob:=mass[st[1]];
end;
function wtf(x,y:integer):ident;
begin
     case pole[y,x]of
     0:wtf:=cmEmpty;
     9:wtf:=cmstone;
     2:wtf:=cmSoil;
     4:wtf:=cmgold;
     6:wtf:=cmpik;
     8:wtf:=cmLop;
     end;
end;
function wtt:ident;
begin
     case instr of
     instrNo:wtt:=cmEmpty;
     instrPik:wtt:=cmpik;
     instrlop:wtt:=cmlop;
     end;
end;
function orient(ch:ident):ident;
begin
     case ch of
     cmWhat_up:orient:=wtf(yhero,xhero-1);
     cmWhat_down:orient:=wtf(yhero,xhero+1);
     cmWhat_right:orient:=wtf(yhero+1,xhero);
     cmWhat_left:orient:=wtf(yhero-1,xhero);
     cmWhat_take:orient:=wtt;
     end;
end;
function arifmet(root:pref;var ci:ident):real;
begin
     if root^.l=root^.r
     then begin
               case root^.typenode of
               2:case varn[root^.index].type_ of
                    cmint:arifmet:=varn[root^.index].znachi;
                    cmreal:arifmet:=varn[root^.index].znachr;
                    end;
               1:arifmet:=root^.num;
               5:if root^.konst in [cmWhat_up,cmWhat_down,cmWhat_right,cmWhat_left,cmWhat_take]
                 then ci:=orient(ch);
               end;
       end
     else case root^.oper[1] of
          '+':arifmet:=arifmet(root^.l,bolv)+arifmet(root^.r,bolv);
          '-':arifmet:=arifmet(root^.l,bolv)-arifmet(root^.r,bolv);
          '*':arifmet:=arifmet(root^.l,bolv)*arifmet(root^.r,bolv);
          '/':arifmet:=arifmet(root^.l,bolv)/arifmet(root^.r,bolv);
          end;
end;
function uslovie(var last:pNode;key:ident):pref;
var sst:string;
    p:pNode;
    tz:pref;
    x:real;
begin
     if errorF
     then exit;
      ch:=getlex;
      sst:='';
      while (ch<>key)and(not(all))and(not errorF) do
      begin
           replaceperem(ch,lex);
           sst:=sst+Lex;
           if not errorF
           then ch:=getlex;
      end;
      if not errorf
      then uslovie:=calcscob(sst);
end;
procedure comand(var SOST:INTEGER);forward;
procedure IFanalise(Var sost:integer);forward;
procedure repanalis(var sost:integer);
const stop=-1;
var e:boolean;
begin
     if errorF
     then exit;
     e:=false;
     repeat
     if errorF
     then exit;
     case sost of
     7:begin
             ch:=getlex;
             if ch=cmUntil
             then begin
                  last:=popl;
                  pushl(last);
                  new(last^.uslr);
                  last^.uslr:=uslovie(last,cmTZ);
                  last^.n:=tekstr;
                  sost:=20;
                  end
             else if ch in operation
                  then begin
                            sost:=9;
                            push (19);
                       end
                  else begin
                       error ('Требуется оператор');
                       exit;
                       end;
       end;
      19:begin
              if ch<>cmTZ
              then begin
                   Error ('Требуется ";"');
                   exit;
                   end
              else sost:=7;
         end;
      20:begin
              sost:=pop;
              e:=true;
         end;
      9:begin
             comand(sost);
        end;
      16,15,12:begin
                 ch:=getlex;
                 ifanalise(sost);
            end;
      end;
      until (sost=stop)or(e);
end;
procedure beg(var sost:integer);
const stop=-1;
var e:boolean;
begin
     e:=false;
     repeat
     if errorF
     then exit;
     if all
     then begin
               error('Ошибка в операторе');
               exit;
          end;
     case sost of
     7:begin
             ch:=getlex;
             if ch=cmEnd
             then begin
                  ch:=getlex;
                  if ch=cmT
                  then {sost:=stop}
                  begin
                       sost:=20;
                  end
                  else if ch<>cmTZ
                       then begin
                            error('Требуется";"');
                            exit;
                            end
                       else      sost:=20;
                  end
             else if ch in operation
                  then begin
                            sost:=9;
                            push (19);
                       end
                  else begin
                       error ('Требуется оператор');
                       exit;
                       end;
       end;
      19:begin
              if ch<>cmTZ
              then begin
                   Error ('Требуется ";"');
                   exit;
                   end
              else sost:=7;
         end;
      20:begin
              sost:=pop;
              e:=true;
         end;
      9:begin
             comand(sost);
        end;
      16,15,12:begin
                 ch:=getlex;
                 ifanalise(sost);
            end;
      end;
      until (sost=stop)or(e);
end;
procedure IFanalise(Var sost:integer);
begin
     if errorF
     then exit;
     repeat
           if errorF
     then exit;
                case sost of
                10:if ch<>cmThen
                   then begin
                        error ('Требуется "ТОГДА"');
                        exit;
                        end
                   else begin
                             sost:=11;
                             new (last^.then_);
                             ch:=getlex;
                        end;
                11:if ch=cmBegin
                   then begin
                             push (12);
                             pushL(last);
                             last:=last^.then_;
                             sost:=7;
                             beg(sost);
                             last:=popl;
                        end
                   else if ch in operation
                        then begin
                                  push(12);
                                  last:=last^.then_;
                                  sost:=255;
                                  comand(sost);
                             end;
                12:begin
                        if ch=cmElse
                             then begin
                                       sost:=14;
                                       last^.next:=nil;
                                       last:=popl;
                                       pushl(last);
                                       ch:=getlex;
                                  end
                          else begin  sost:=13;
                                  last^.next:=nil;
                                  last:=popl;
                                  pushl(last);
                                  last^.else_:=nil;
                             end;
                            { else begin
                                  ch:=getlex;
                                  error('Требуется "К_ЕСЛИ"');
                                  end;}
                   end;
                14:begin
                        if ch in operation
                        then sost:=15
                        else if ch=cmBegin
                             then
                             begin
                                  push (16);
                                  new(last^.else_);
                                  last:=last^.else_;
                                  sost:=7;
                                  beg(sost);
                             end;
                   end;
                15:begin
                        pushl(last);
                        new(last^.else_);
                        last:=last^.else_;
                        sost:=255;
                        push (16);
                        comand(sost);
                        last:=popl;
                   end;
                  16:begin
                            {ch:=getlex;
                            if Ch=cmEnd_IF
                            then begin}
                            sost:=13;
                                 { end
                            else  begin
                                  error('Требуется "К_ЕСЛИ"');
                                  end;}
                        end;
               end;
               until (sost=13)or(sost=7);
     if sost=13
     then begin
               sost:=pop;
               last:=popl;
               new(last^.next);
               last:=last^.next;
          end;
end;
procedure usloper(var last:pNode;lit:string);
var sst:string;
    p:pNode;
    tz:pref;
    x:real;
begin
     if errorF
     then exit;
      last^.index:=index(lit);
      ch:=getlex;
      sst:='';
      while (ch<>cmtz)and(not(all)) do
      begin
           replaceperem(ch,lex);
           sst:=sst+Lex;
           ch:=getlex;
      end;
      last^.znach:=calcscob(sst);
end;
procedure foranalis(var sost:integer);
var sst:string;
    code:integer;
begin
     if errorF
     then exit;
     repeat
           if errorF
           then exit;
           case sost of
           30:begin
                   if ch=cmident
                   then begin
                        if index(lex)<>0
                        then begin
                             last^.fori:=index(lex);
                             ch:=getlex;
                             sost:=31;
                             end
                        else begin
                             error('Требуется имя переменной');
                             exit;
                             end;
                        end
                   else begin
                        error('Требуется имя переменной');
                        exit;
                        end;
              end;
              31:if ch=cmfrom
                 then sost:=32
                 else begin
                      error('Требуется "ОТ"');
                      exit;
                      end;
              32:begin
                      ch:=getlex;
                      if ch=cmnumber
                      then sost:=33
                      else if (ch=cmIdent)and(index(lex)<>0)
                           then sost:=34
                           else begin
                                error('Требуется имя переменной или число');
                                exit;
                                end;
                end;
              33:begin
                      new(last^.nz);
                      last^.nz^.f:=false;
                      val(lex,last^.nz^.p,code);
                      ch:=getlex;
                      if ch=cmTo
                      then sost:=35
                      else if ch=cmDownto
                           then sost:=36
                           else begin
                                error('Требуется "ДО" или "СПУСК"');
                                exit;
                                end;
                end;
                34:begin
                      new(last^.nz);
                      last^.nz^.f:=true;
                      last^.nz^.p:=index(lex);
                      ch:=getlex;
                      if ch=cmTo
                      then sost:=35
                      else if ch=cmDownto
                           then sost:=36
                           else begin
                                error('Требуется "ДО" или "СПУСК"');
                                exit;
                                end;
               end;
              35:begin
                      last^.dfor:=true;
                      ch:=getlex;
                      if ch=cmnumber
                      then sost:=41
                      else if (ch=cmIdent)and(index(lex)<>0)
                           then sost:=40
                           else begin
                                error('Требуется имя переменной или число');
                                exit;
                                end;
                 end;
              36:begin
                      last^.dfor:=false;
                      ch:=getlex;
                      if ch=cmnumber
                      then sost:=41
                      else if (ch=cmIdent)and(index(lex)<>0)
                           then sost:=40
                           else begin
                                error('Требуется имя переменной или число');
                                exit;
                                end;
                 end;
              37:begin
                      ch:=getlex;
                      if ch=cmBegin
                      then sost:=38
                      else if ch in operation
                           then sost:=39
                           else begin
                                error('Требуется оператор');
                                exit;
                                end;
                 end;
                 39:begin
                         pushl(last);
                         new(last^.body);
                         last:=last^.body;
                         push(29);
                         sost:=255;
                         comand(sost);;
                         last:=popl;
                    end;
                 38:begin
                         pushl(last);
                         push (29);
                         new(last^.body);
                         last:=last^.body;
                         sost:=7;
                         beg(sost);
                         last:=popl;
                 end;
                 41:begin
                      new(last^.kz);
                      last^.kz^.f:=false;
                      val(lex,last^.kz^.p,code);
                      ch:=getlex;
                      if ch=cmDO
                      then sost:=37
                      else begin
                           error('Требуется "ОК"');
                           exit;
                           end;
                end;
                40:begin
                      new(last^.kz);
                      last^.kz^.f:=true;
                      last^.kz^.p:=index(lex);
                      ch:=getlex;
                      if ch=cmDO
                      then sost:=37
                      else begin
                           error('Требуется "ОК"');
                           exit;
                           end;
                end;
              end;
     until sost=29;
     if sost=29
     then begin
               sost:=pop;
               new(last^.next);
               last:=last^.next;
               last^.typ:=cmProg;
          end;
end;
procedure Comand(var sost:integer);
var sperem:string;
begin
     if errorF
     then exit;
     if sost in[12,15]
     then ifanalise(sost);
     case ch of
     cmrepeat:begin
                   AddElem (newElem(ch));
                   new(last^.bodyr);
                   pushl(last);
                   last:=last^.bodyr;
                   sost:=7;
                   repanalis(sost);
                   last:=popl;
                   new(last^.next);
                  last^.next^.typ:=cmProg;
                  last:=last^.next;
              end;
     cmWhile:begin
                  AddElem (newElem(ch));
                  sost:=50;
                  last^.uslw:=uslovie(last,cmDo);
                  ch:=getlex;
                  if ch=cmBegin
                  then begin
                            pushl(last);
                            new(last^.bodyW);
                            last:=last^.bodyW;
                            sost:=7;
                            beg(sost);
                            last:=popl;
                       end
                  else if ch in operation
                           then begin
                                     pushl(last);
                                     new(last^.bodyW);
                                     last:=last^.bodyW;
                                     push(19);
                                     sost:=255;
                                     comand(sost);
                                     last:=popl;
                                end
                           else begin
                                error('Требуется оператор');
                                exit;
                                end;
                  new(last^.next);
                  last^.next^.typ:=cmProg;
                  last:=last^.next;
             end;
     cmFor:begin
                AddElem (newElem(ch));
                         ch:=Getlex;
                         sost:=30;
                         foranalis(sost);
           end;
     cmleft,cmright,cmUp,cmDown,cmTake,
     cmWork_Up,cmWork_down,cmWork_right,CmWork_left:begin
                         AddElem (newElem(ch));
                         ch:=Getlex;
                         new(last^.next);
                         last^.next^.typ:=cmProg;
                         last:=last^.next;
                         sost:=pop;
                    end;
     cmIdent:begin
                        sperem:=lex;
                        if index(sperem)=0
                        then begin
                                  error('Неизвестный идентификакатор');
                                  exit;
                             end;
                         AddElem (newElem(cmPrisv));
                         ch:=Getlex;
                         if ch<>cmPrisv
                         then begin
                              error('Требуется ":="');
                              exit;
                              end
                         else begin
                              usloper(last,sperem);
                              new(last^.next);
                              last^.next^.typ:=cmProg;
                              last:=last^.next;
                              sost:=pop;
                              end;
                    end;
     cmIf:begin
               AddElem (newElem(ch));
               pushl(last);
               last^.usl:=uslovie(last,cmThen);
               sost:=10;
               ifAnalise(sost);
          end;
     end;
end;
procedure Automat;
const stop=-1;
var sost:integer;
begin
     sost:=0;
     ch:=getlex;
     repeat
      if errorF
      then exit;
      if all
     then begin
               error('Ошибка в операторе');
               exit;
          end;
      case sost of
      0:if ch<>cmProg
        then begin
             error ('Требуется слово "ПРОГРАММА"');
             exit;
             end
        else begin
                  sost:=1;
                  ch:=getlex;
             end;
      1:if ch<>cmIdent
        then begin
             error ('Требуется имя программы');
             exit;
             end
        else begin
                  ch:=getlex;
                  if ch<>cmTZ
                  then begin
                       error ('Требуется ";"');
                       exit;
                       end;
                  sost:=2;
                  ch:=getlex;
             end;
      2:if ch=cmRVar
        then sost:=21
        else if ch=cmBegin
             then begin
                       sost:=7;
                       push(stop);
                  end
             else begin
                  error ('Требуется "НАЧАЛО"');
                  exit;
                  end;
      21:begin
              ch:=getlex;
              if ch<>cmIdent
              then begin
                   error ('Требуется имя переменной');
                   exit;
                   end
              else  sost:=3;
         end;
      3:begin
             RemIn (Lex);
             ch:=getlex;
             if ch=cmTT
             then sost:=5
             else if ch=cmZP
                  then sost:=4
                  else begin
                       error ('Требуется ":" или ","');
                       exit;
                       end;
        end;
      4:begin
             ch:=getlex;
             if ch=cmIdent
             then sost:=3
             else begin
                  error ('Требуется имя переменной');
                  exit;
                  end;
        end;
      5:begin
             ch:=getlex;
             if not (ch in [cmInt,cmReal,cmChar])
             then begin
                  error ('Требуется тип переменной');
                  exit;
                  end
             else sost:=6;
        end;
      6:begin
             FillPerem (ch);
             ch:=getlex;
             if ch<>cmTZ
             then begin
                  error ('Требуется ";"');
                  exit;
                  end;
             ch:=getlex;
             if ch=cmBegin
             then begin
                       sost:=7;
                       push (stop);
                  end
              else  if ch=cmIdent
                    then sost:=3
                    else begin
                         error ('Требуется "НАЧАЛО"');
                         exit;
                         end;
        end;
        7:
        beg(sost);
      end;
     until sost=stop;
     last^.typ:=cmProg;
end;
function sol(root:pref):boolean;
begin
     case root^.oper[1] of
     #4:
     sol:=sol(root^.l)and sol(root^.r);
     #5:
     sol:=sol(root^.l)or sol(root^.r);
     #6:
     sol:=not(sol(root^.r));
     #1:
     sol:=arifmet(root^.l,bolv)>= arifmet(root^.r,bolv);
     #2:
     sol:=arifmet(root^.l,bolv)<= arifmet(root^.r,bolv);
     #3:
        begin
         if (root^.l^.typenode=5)and(root^.r^.typenode=5)
         then begin
              if (root^.l^.konst in vopr)and(root^.r^.konst in vopr)
              then sol:=orient(root^.l^.konst)<>orient(root^.r^.konst);

              if (root^.l^.konst in vopr)and(root^.r^.konst in konst)
              then sol:=orient(root^.l^.konst)<>root^.r^.konst;

              if (root^.l^.konst in konst)and(root^.r^.konst in konst)
              then sol:=root^.l^.konst<>root^.r^.konst;

              if (root^.l^.konst in konst)and(root^.r^.konst in vopr)
              then sol:=root^.l^.konst<>orient(root^.r^.konst);;

              end

         else sol:=arifmet(root^.l,bolv)<> arifmet(root^.r,bolv);
         end;
     '<':
     sol:=arifmet(root^.l,bolv)< arifmet(root^.r,bolv);
     '>':
     sol:=arifmet(root^.l,bolv)> arifmet(root^.r,bolv);
     '=':begin
         if (root^.l^.typenode=5)and(root^.r^.typenode=5)
         then begin
              if (root^.l^.konst in vopr)and(root^.r^.konst in vopr)
              then sol:=orient(root^.l^.konst)=orient(root^.r^.konst);

              if (root^.l^.konst in vopr)and(root^.r^.konst in konst)
              then sol:=orient(root^.l^.konst)=root^.r^.konst;

              if (root^.l^.konst in konst)and(root^.r^.konst in konst)
              then sol:=root^.l^.konst=root^.r^.konst;

              if (root^.l^.konst in konst)and(root^.r^.konst in vopr)
              then sol:=root^.l^.konst=orient(root^.r^.konst);;

              end

         else sol:=arifmet(root^.l,bolv)= arifmet(root^.r,bolv);
     end;
     end;
end;
procedure interpritator(p:pNode;level:string);
var i,nz,kz:integer;
begin
     while (p<>nil)and(p^.typ<>cmProg) do
     begin
          case p^.Typ of
          cmfor:begin
                     if p^.nz^.f
                     then nz:=varn[p^.nz^.p].znachi
                     else nz:=p^.nz^.p;
                     if p^.kz^.f
                     then kz:=varn[p^.kz^.p].znachi
                     else kz:=p^.kz^.p;
                     if p^.dfor
                     then for i:=nz to kz do
                          begin
                               varn[p^.fori].znachi:=i;
                               interpritator(p^.body,level+'      ')
                          end
                     else for i:=nz downto kz do
                          begin
                               varn[p^.fori].znachi:=i;
                               interpritator(p^.body,level+'      ')
                          end
                end;
          cmWhile:begin
                     writeln(mainlex[p^.Typ],' ');
                     while sol(p^.uslw) do
                     interpritator(p^.bodyW,level+'     ');
                end;
          cmrepeat:begin
                     writeln(mainlex[p^.Typ],' ');
                     repeat
                     interpritator(p^.bodyr,level+'     ');
                     writeln(sol(p^.uslr));
                     until sol(p^.uslr);
                     writeln('Until',' ',sol(p^.uslr));
                end;
          cmLeft,cmRight,cmUp,cmDown:writeln(mainlex[p^.Typ],level);
          cmPrisv:case varn[p^.index].type_ of
                  cmInt:begin
                        varn[p^.index].znachi:=round(arifmet(p^.znach,bolv));
                       writeln(varn[p^.index].name,mainlex[p^.Typ],varn[p^.index].znachi)
                       end;
                  cmreal:begin
                        varn[p^.index].znachr:=arifmet(p^.znach,bolv);
                       writeln(varn[p^.index].name,mainlex[p^.Typ],varn[p^.index].znachr)
                       end;
                  cmchar:begin
                              if p^.znach^.typenode=4
                              then varn[p^.index].znachch:=p^.znach^.str[1]
                              else if p^.znach^.typenode=2
                                   then varn[p^.index].znachch:=varn[p^.znach^.index].znachch;
                         writeln(varn[p^.index].name,mainlex[p^.Typ],varn[p^.index].znachch)
                         end;
                       end;
          cmIf:begin
                    writeln(level,mainlex[p^.typ],'   ',sol(p^.usl));
                    write(level,'then: ');
                    interpritator(p^.then_,level+'      ');
                    if p^.else_<>nil
                    then begin
                         write (level,'else: ');
                         interpritator(p^.else_,level+'      ');
                         end;
               end;
          end;
          p:=p^.next;
     end;
end;


function mousein (x1,y1,x2,y2:integer):boolean;
begin
     mousein:=(mousex>x1)and(mousex<x2)and(mousey>y1)and(mousey<y2)
end;


procedure mouseAnalis;
var i:integer;
begin
     if mousebutton=1
     then begin
               while mousebutton=1 do;
               for i:=1 to MaxButton do
               if (mouseIn (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2))and((butt[i].ns=sb)or(butt[i].ns=0))
               then BEGIN
                          butt[i].f:=true;
                          sb:=butt[i].sost;
                          drawbutton (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2,butt[i].s,true,false);
                          t:=0;
                     end;
               makekursor(tek,teki);
          end;
end;

procedure insertlit(c:char);
begin
     tek^.s:=copy(tek^.s,1,teki)+c+copy(tek^.s,teki+1,length(tek^.s));
     if teki <=length(tek^.s)
                       then  if visabli+ympt-1=teki
                             then begin
                             inc(visabli);
                             inc(teki);
                             end
                             else inc(teki);
end;
procedure delstr(var tz:txt);
var tt:txt;
begin
     tt:=tz^.down;
     if tz^.down^.down<>nil
     then begin
          tz^.down:=tz^.down^.down;
     tz^.down^.up:=tz;
                      dispose(tt);
     end
     else begin
               dispose(tt);
               tz^.down:=nil;
               tek:=tz;
          end;
end;
procedure delnext(var s:string;n:integer);
begin
     if length(s)>n
     then s:=copy(tek^.s,1,n)+copy(tek^.s,n+2,length(tek^.s))
     else
         if (tek^.down<>nil)and(length(s)<=n)
          then   begin
                 s:=s+tek^.down^.s;
                 delstr(tek);
                 end;
end;
procedure delprev(var s:string;n:integer);
begin
     if 0<=n-1
     then begin
          s:=copy(tek^.s,1,n-1)+copy(tek^.s,n+1,length(tek^.s));
          dec(teki);
          if teki<=visabli-1
          then dec(visabli);
          end;
     if (tek^.up<>nil)and(0=n)
          then   begin
                 teki:=length(tek^.up^.s);
                 tek^.up^.s:=tek^.up^.s+tek^.s;
                 tek:=tek^.up;
                 delstr(tek);
                 if teki>=ympt
                 then visabli:=teki-ympt+2;
                 end;
end;
procedure delstroku(var tz:txt);
var tt,r:txt;
    vi:boolean;
begin
     tt:=tz;
     vi:=false;
     if tz^.down<>nil
     then begin
                         if visabl=tek
                      then vi:=true;
                        tz^.up^.down:=tz^.down;
                    tz^.down^.up:=tz^.up;
                    tz:=tz^.down;
                      dispose(tt);
                      if vi
                      then visabl:=tek;
     end
     else begin
               if visabl=tek
                      then visabl:=visabl^.up;
               tz^.up^.down:=nil;
               if tz=visabl
               then visabl:=visabl^.up;
               tz:=tz^.up;
          end;
     if length(tek^.s)<teki
     then teki:=length(tek^.s);
end;
procedure insertstr(var tx:txt);
var ttx:txt;
begin
     new(ttx);
     ttx^.s:=copy(tx^.s,teki+1,length(tx^.s)-teki+1);
     delete(tx^.s,teki+1,length(tx^.s)-teki+1);
     tx^.down^.up:=ttx;
     ttx^.up:=tx;
     ttx^.down:=tx^.down;
     tx^.down:=ttx;
     if length(tek^.s)<teki
     then teki:=length(tek^.s);
end;
procedure delfirst(var tz:txt);
var tt:txt;
begin
     tt:=tz;
     if tz^.down<>nil
     then begin
               intext:=tz^.down;
               tz:=intext;
               visabl:=intext;
               tz^.up:=nil;
               dispose(tt);

     end
     else begin
               tz^.s:='';
               tek:=intext;
               teki:=0;
          end;
end;
function count:integer;
var x:txt;
    i:integer;
begin
     x:=visabl;
     i:=0;
     while x<>tek do
     begin
          x:=x^.down;
          inc(i);
     end;
     count:=i;
end;
function countw:integer;
var x:pwin;
    i:integer;
begin
     x:=viswin;
     i:=0;
     while x<>tekwin do
     begin
          x:=x^.down;
          inc(i);
     end;
     countw:=i;
end;
procedure selection(var tek:pwin);forward;
procedure scrolld;
const xreal=xmpt-1;
var tx,pred:txt;
    i:integer;
begin
     i:=1;
     tx:=visabl;
     while (tx<>nil)and(i<xmpt) do
     begin
     inc(i);
     pred:=tx;
     tx:=tx^.down;
     end;
     visabl:=pred;
     tek:=visabl;
     if length(tek^.s)<teki
            then begin
                 teki:=length(tek^.s);
                 if teki < (xmpt-1)
                 then visabli:=0
                 else visabli:=teki-xmpt-1
                 end;
end;
procedure scrollu;
const xreal=xmpt-1;
var tx,pred:txt;
    i:integer;
begin
     i:=1;
     tx:=visabl;
     while (tx<>nil)and(i<xmpt) do
     begin
     inc(i);
     pred:=tx;
     tx:=tx^.up;
     end;
     visabl:=pred;
     tek:=visabl;
     if length(tek^.s)<teki
            then begin
                 teki:=length(tek^.s);
                 if teki < (xmpt-1)
                 then visabli:=0
                 else visabli:=teki-xmpt-1
                 end;
end;

procedure keyboardanalis;
var c:char;
    x:word;
    x1:longint;
begin
     x1:=readkeyboard(c);
     if (c <>#0)and(c <>#10)
     then begin
          insertlit(c);
          izmena:=true;
          end;
     {if  x1=kLeftShift+KAlt
     then begin
          switchlanguage;
          lang:=not lang;
          end
     else }x:=x1;
     while readkeyboard(c)<>0 do;
     case x of
     42079:begin
                if length(tek^.s)>(visabli+ympt-1)
                then begin
                          visabli:=length(tek^.s)-ympt+1;
                     end;
                teki:=length(tek^.s)
     end;
     42071:begin
                visabli:=0;
                teki:=0;
           end;
     42081:scrolld;
     42073:scrollU;
     Kctrl+KY:begin

                   if tek^.up<>nil
              then   delstroku(tek)
              else delfirst(tek);
              if length(tek^.s)<teki
                  then teki:=length(tek^.s);
              if teki<visabli
              then visabli:=teki;
              if tek^.up<>nil
            then  begin
                  if tek^.down=visabl
                  then  visabl:=visabl^.up
                  end;
              izmena:=true;
              end;
     42000+kleft:
                 if teki >=1
                       then  if visabli>=teki
                             then begin
                             dec(visabli);
                             dec(teki);
                             end
                             else dec(teki);
     42072:
     begin
     if tek^.up<>nil
            then  begin
                  if tek=visabl
                  then begin
                       tek:=tek^.up;
                       visabl:=visabl^.up;
                       end
                  else
                  begin
                  tek:=tek^.up;
                  if length(tek^.s)<teki
                  then teki:=length(tek^.s);
                  end;
                  end;
            if visabli>=teki
            then visabli:=teki;
            end;
     42080:
     if tek^.down<>nil
            then  begin
                  if count=xmpt-2
                  then begin
                       tek:=tek^.down;
                       visabl:=visabl^.down;
                       end
                  else  tek:=tek^.down;
                  if length(tek^.s)<teki
                  then teki:=length(tek^.s);
                  if visabli>=teki
            then visabli:=teki;
                  end;
     42000+kright:begin
                       if teki <length(tek^.s)
                       then  begin
                             if visabli+ympt-1=teki
                             then begin
                             inc(visabli);
                             inc(teki);
                             end
                             else inc(teki);
                             end;
                  end;
     kBackSpace:begin
                     if tek^.up<>nil
                then  begin
                  if (tek=visabl)and(teki=0)
                  then  visabl:=visabl^.up
                  end;
                delprev(tek^.s,teki);
                izmena:=true;
                end;
     42000+kDelete:begin
                        delnext(tek^.s,teki);
                        izmena:=true;
                   end;
     56045:sb:=cmExit;
     kEnter: begin
            if tek^.down=nil
            then begin
                 new(tek^.down);
                 tek^.down^.up:=tek;
                 tek:=tek^.down;
                 tek^.down:=nil;
                 if teki=length(tek^.up^.s)
                 then tek^.s:=''
                 else begin
                      tek^.s:=copy(tek^.up^.s,teki+1,length(tek^.up^.s));
                      delete(tek^.up^.s,teki+1,length(tek^.up^.s))
                      end;
                 teki:=0;
                 visabli:=0;
                  if count>=xmpt-2
                  then begin
                       tek:=tek^.down;
                       visabl:=visabl^.down;
                       end
                 end
            else begin
                 insertstr(tek);
                 if count>=xmpt-2
                  then begin
                       tek:=tek^.down;
                       visabl:=visabl^.down;
                       end
                  else  tek:=tek^.down;
                 end;

            if length(tek^.s)<teki
            then begin
                 teki:=length(tek^.s);
                 if teki < (xmpt-1)
                 then visabli:=0
                 else visabli:=teki-xmpt-1
                 end;
            izmena:=true;
          end;
     61:sb:=cmloadText;
     60:sb:=cmSave;
     67:
        sb:=cmCompile;
     kF1:sb:=cmHelp;
     kctrl+kF9:sb:=cmrun;
     kTab:begin izmena:=true; insertlit(' ');insertlit(' ');insertlit(' ');insertlit(' ');insertlit(' ');end;
     kCtrl+k1:sb:=demo1;
     kCtrl+k2:sb:=demo2;
     kCtrl+k3:sb:=demo3;
     kCtrl+k4:sb:=demo4;
     kCtrl+k5:sb:=demo5;
     end;
end;
procedure loadtxt(name:string;var intext:txt);
var tx,txp:txt;
    f:text;
begin
     if not findindir(pstrok(name))
     then begin
          massage('Файл не найден');
          sb:=cmloadtext;
          exit;
          end;
     nametxt:=name;
{     destroyTXT(intext);}
     assign(f,name);
     reset(f);
{ new(intext);}
     tx:=intext;
    { new(txp);}
     txp:=nil;
     while not(eof(f)) do
     begin
          readln(f,tx^.s);
          tx^.up:=txp;
          txp:=tx;
          {}
          new(tx^.down);
          tx^.down^.s:='';
          tx^.down^.up:=nil;tx^.down^.down:=nil;
          tx:=tx^.down;
          txp^.down:=tx;
     end;
     tx:=txp;
     tx^.down:=nil;
     tek:=intext;
     visabl:=intext;
     izmena:=false;
     close(f);
end;
procedure savetxt(name:string;intext:txt);
var tx:txt;
    f:text;
begin
     assign(f,name);
     rewrite(f);
     tx:=intext;
     while tx<>nil do
     begin
          write(f,tx^.s);
          tx:=tx^.down;
          writeln(f);
     end;
     close(f);
end;
procedure saveText;
const xz1=320;
      yz1=150;
      xz2=490;
      yz2=200;
      xo1=320;
      yo1=250;
      xo2=490;
      yo2=300;
var c:char;
    ex,select:boolean;
    s:string;
    x:word;
    ku:integer;
begin
     select:=false;
     builddir('texts\*.mtx');
     s:='texts\';
     ku:=length(s);
     ex:=false;
     tkursor:=0;
     repeat
           setvisualpage(page);
           waitvbl;
           page:=1-page;
           setactivepage (page);
           drawscreen (100,100,300,380,'sprites\mib3.tex');
           drawscreen (299,100,500,380,'sprites\mib3.tex');
           ramka(90,90,310,360);
           ramka(90,350,510,390);
           ramka(300,90,510,360);
           drawbutton (xz1,yz1,xz2,yz2,'Сохранить',false,false);
           drawbutton (xo1,yo1,xo2,yo2,'Отмена',false,false);
           showmouse;
           outwin(select);
           if mousebutton=1
           then begin
               while mousebutton=1 do;
               if mousein(100,100,300,380)
               then select:=true;
               if mousein (90,350,510,390)
               then select:=false;
               if mousein (xo1,yo1,xo2,yo2)
               then ex:=true;
               if mousein (xz1,yz1,xz2,yz2)
               then begin
                    if select
                    then savetxt('texts\'+tekwin^.dir.name,intext)
                    else savetxt(s,intext);
                    ex:=true;
                    end;
               if select then selection(tekwin);
           end;
           x:=readkeyboard(c);
           if select
           then
       {}  begin
           outwin(true);
           if x=42000+kup
           then
           if tekwin^.up<>nil
            then  begin
                  if tekwin=viswin
                  then begin
                       tekwin:=tekwin^.up;
                       viswin:=viswin^.up;
                       end
                  else
                  begin
                  tekwin:=tekwin^.up;
                  end;
                  end;
           if x=42000+kdown
           then if tekwin^.down<>nil
                then
                    begin
                         if countw>=15
                         then begin
                              viswin:=viswin^.down;
                              tekwin:=tekwin^.down;
                              end
                         else tekwin:=tekwin^.down;
                    end;
                setcolor(30);
                outtextxy(102,362,s);
                if x=kenter
           then   begin
                       savetxt('texts\'+tekwin^.dir.name,intext);
                    ex:=true;
                    end;
       {}  end;
           if not select
           then begin
           if c<>#0
           then begin
                S:=copy(s,1,ku)+c+copy(s,ku+1,length(s)-ku);;
                inc(ku);
                end;
           if x=kenter
               then begin
                    savetxt(s,intext);
                    ex:=true;
                    end;
           if x=kBackSpace
           then begin
                s:=copy(s,1,ku-1)+copy(s,ku+1,length(s)-ku);
                dec(ku);
                end;
           if x=42000+kDelete
           then begin
                s:=copy(s,1,ku)+copy(s,ku+2,length(s)-ku);
                end;
           if (x=42000+kright)and(ku<length(s))
           then inc(ku);
           if (x=42000+kleft)and(ku>0)
           then dec(ku);
           if x=kesc
           then ex:=true;
           setcolor(255);
           if tkursor>=5
           then begin
           tkursor:=0;
           outtextxy(102+ku*textwidth('_'),362,'_');
           end;
           outtextxy(102,362,s);
           inc(tkursor);
           end;
     until ex=true;
     sb:=0;
     tkursor:=0;
end;
procedure initmap(name:string);
var f:text;
    i,j:integer;
begin
     assign(f,name);
     reset(f);
     readln(f,xmaster,ymaster);
     xhero:=xmaster;
     yhero:=ymaster;
     for i:=1 to 8 do
     begin
      for j:=1 to 8 do
      read(f,pole[i,j]);
      readln(f);
     end;
     close(f);
     for i:=1 to 8 do
     for j:=1 to 8 do
     polelast[i,j]:=pole[i,j];
     namemap:=name;
     instr:=instrNO;
     tekstay:=instr;
end;
procedure selection(var tek:pwin);
var tw:pwin;
    i:integer;
begin
     tw:=viswin;
     i:=0;
     while (tw<>nil)and(not mousein(100,105+15*i,300,120+15*i)) do
     begin
          tw:=tw^.down;
          inc(i);
     end;
     if tw<>nil
     then tek:=tw;
end;
procedure LoadText;
const xz1=320;
      yz1=100;
      xz2=490;
      yz2=150;
      xo1=320;
      yo1=200;
      xo2=490;
      yo2=250;
      xt1=320;
      yt1=280;
      xt2=402;
      yt2=330;
      xm1=404;
      ym1=280;
      xm2=490;
      ym2=330;
var c:char;
    ex:boolean;
    s:string;
    x:word;
    ku:integer;
    stxt,smap,select:boolean;
begin
     builddir('texts\*.mtx');
     stxt:=true;
     smap:=false;
     s:='texts\';
     ku:=length(s);
     ex:=false;
     tkursor:=0;
     select:=false;
     repeat
           setvisualpage(page);
           waitvbl;
           page:=1-page;
           setactivepage (page);
           drawscreen (100,100,300,380,'sprites\mib3.tex');
           drawscreen (299,100,500,380,'sprites\mib3.tex');
           ramka(90,90,310,360);
           ramka(90,350,510,390);
           ramka(300,90,510,360);
           drawbutton (xz1,yz1,xz2,yz2,'Загрузить',false,false);
           drawbutton (xo1,yo1,xo2,yo2,'Отмена',false,false);
           drawbutton (xm1,ym1,xm2,ym2,'Карту',smap,false);
           drawbutton (xt1,yt1,xt2,yt2,'Текст',stxt,false);
           showmouse;
           if mousebutton=1
           then begin
               while mousebutton=1 do;
               if mousein (xo1,yo1,xo2,yo2)
               then ex:=true;
               if mousein (xm1,ym1,xm2,ym2)
               then begin
                    stxt:=false;
                    builddir('maps\*.rsm');
                    s:='maps\';
                    ku:=length(s);
                    smap:=true;
                    end;
               if mousein(100,100,300,380)
               then select:=true;
               if mousein (90,350,510,390)
               then select:=false;
               if mousein (xt1,yt1,xt2,yt2)
               then begin
                    smap:=false;
                    builddir('texts\*.mtx');
                    s:='texts\';
                    ku:=length(s);
                    stxt:=true;
                    end;
               if mousein (xz1,yz1,xz2,yz2)
               then begin
                         if select
                         then
                             begin
                                  if stxt
                                  then loadtxt('texts\'+tekwin^.dir.name,intext)
                                  else initmap('maps\'+tekwin^.dir.name);
                             end
                         else
                             begin
                                  if stxt
                                  then loadtxt(s,intext)
                                  else if not findindir(pstrok(s))
                                       then begin
                                       massage('Файл не найден');
                                       sb:=cmloadtext;
                                       exit;
                                       end
                                       else initmap(s);
                             end;
                        ex:=true;
                        end;
                        if select
               then selection(tekwin);
                    end;
           x:=readkeyboard(c);
           if select
           then
       {}  begin
           outwin(true);
           if x=42000+kup
           then
           if tekwin^.up<>nil
            then  begin
                  if tekwin=viswin
                  then begin
                       tekwin:=tekwin^.up;
                       viswin:=viswin^.up;
                       end
                  else
                  begin
                  tekwin:=tekwin^.up;
                  end;
                  end;
           if x=42000+kdown
           then if tekwin^.down<>nil
                then
                    begin
                         if countw>=15
                         then begin
                              viswin:=viswin^.down;
                              tekwin:=tekwin^.down;
                              end
                         else tekwin:=tekwin^.down;
                    end;
                setcolor(30);
                outtextxy(102,362,s);
                if x=kenter
           then   begin
                  if stxt
                    then loadtxt('texts\'+tekwin^.dir.name,intext)
                    else initmap('maps\'+tekwin^.dir.name);
                    ex:=true;
                    end;
       {}  end;
           if x=kTab
           then  begin
                    smap:=not smap;
                    stxt:=not stxt;
                    if smap
                    then begin
                         builddir('maps\*.rsm');
                         s:='maps\';
                         ku:=length(s);
                         end
                    else begin
                         builddir('texts\*.mtx');
                         s:='texts\';
                         ku:=length(s);
                         end
                    end;
           if not select
           then
      {}   begin
           outwin(false);
           if c<>#0
           then begin
                S:=copy(s,1,ku)+c+copy(s,ku+1,length(s)-ku);;
                inc(ku);
                end;

           if x=kenter
           then   begin
                  if stxt
                    then loadtxt(s,intext)
                    else if not findindir(pstrok(s))
                         then begin
                              massage('Файл не найден');
                              sb:=cmloadtext;
                              exit;
                             end
                         else initmap(s);
                    ex:=true;
                    end;
           if (x=kBackSpace)and(ku>0)
           then begin
                s:=copy(s,1,ku-1)+copy(s,ku+1,length(s)-ku);
                dec(ku);
                end;
           if x=42000+kDelete
           then begin
                s:=copy(s,1,ku)+copy(s,ku+2,length(s)-ku);
                end;
           if (x=42000+kright)and(ku<length(s))
           then inc(ku);
           if (x=42000+kleft)and(ku>0)
           then dec(ku);
           setcolor(255);
           if tkursor>=5
           then begin
           tkursor:=0;
           outtextxy(102+ku*textwidth('_'),362,'_');
           outtextxy(102,362,s);
           end;
           outtextxy(102,362,s);
        {} end;
           if x=kesc
           then ex:=true;
           inc(tkursor);
     until ex=true;
     tkursor:=0;
     teki:=0;
     visabli:=0;
end;


procedure initbuttons;
begin
     butt[6].x1:=0;
     butt[6].x2:=100;
     butt[6].y1:=0;
     butt[6].y2:=30;
     butt[6].s:='Новый';
     butt[6].sost:=cmNewtext;
     butt[6].f:=false;
     butt[6].ns:=0;

     butt[1].x1:=100;
     butt[1].x2:=200;
     butt[1].y1:=0;
     butt[1].y2:=30;
     butt[1].s:='Загрузить';
     butt[1].sost:=cmloadtext;
     butt[1].f:=false;
     butt[1].ns:=0;

     butt[2].x1:=300;
     butt[2].x2:=400;
     butt[2].y1:=0;
     butt[2].y2:=30;
     butt[2].s:='Редактор';
     butt[2].sost:=cmEdit;
     butt[2].f:=false;
     butt[2].ns:=0;

     butt[3].x1:=200;
     butt[3].x2:=300;
     butt[3].y1:=0;
     butt[3].y2:=30;
     butt[3].s:='Сохранить';
     butt[3].sost:=cmsave;
     butt[3].f:=false;
     butt[3].ns:=0;

     butt[5].x1:=500;
     butt[5].x2:=600;
     butt[5].y1:=0;
     butt[5].y2:=30;
     butt[5].s:='Выход';
     butt[5].sost:=cmexit;
     butt[5].f:=false;
     butt[5].ns:=0;

     butt[4].x1:=400;
     butt[4].x2:=500;
     butt[4].y1:=0;
     butt[4].y2:=30;
     butt[4].s:='Запуск';
     butt[4].sost:=cmRun;
     butt[4].f:=false;
     butt[4].ns:=0;

     {butt[7].x1:=600;
     butt[7].x2:=640;
     butt[7].y1:=0;
     butt[7].y2:=30;
     butt[7].s:='?';
     butt[7].sost:=cmhelp;
     butt[7].f:=false;
     butt[7].ns:=0; }
     maxbutton:=6;
end;


procedure inittextures;
begin
     setbuttontexture('sprites\button.dat');
     setedittexture('sprites\mib3.tex');
     setwindowtexture('sprites\wood2.tex');
end;


procedure initpictures;
begin
     pic[0]:=loadspr('sprites\fon3.spr');
     pic[1]:=loadspr('sprites\crack.spr');
     pic[9]:=loadspr('sprites\st.spr');{admint}
     pic[2]:=loadspr('sprites\gr.spr'); {zemlya}
     pic[4]:=loadspr('sprites\gold2.spr');
     pic[6]:=loadspr('sprites\kir.spr');
     pic[8]:=loadspr('sprites\lop.spr');
                                            {lopata}
     pic[10]:=loadspr('sprites\stopp2.spr');
     pic[11]:=loadspr('sprites\gks1.spr');
     pic[12]:=loadspr('sprites\gks2.spr');
     pic[13]:=loadspr('sprites\gks3.spr');
     pic[14]:=loadspr('sprites\gks4.spr');
     pic[15]:=loadspr('sprites\gks5.spr');
     pic[16]:=loadspr('sprites\gks3.spr');
     pic[17]:=loadspr('sprites\gks2.spr');
     pic[18]:=loadspr('sprites\gks3.spr');

     pic[20]:=loadspr('sprites\stoppno.spr');
     pic[21]:=loadspr('sprites\gns1.spr');
     pic[22]:=loadspr('sprites\gns2.spr');
     pic[23]:=loadspr('sprites\gns3.spr');
     pic[24]:=loadspr('sprites\gns4.spr');
     pic[25]:=loadspr('sprites\gns5.spr');
     pic[26]:=loadspr('sprites\gns3.spr');
     pic[27]:=loadspr('sprites\gns2.spr');
     pic[28]:=loadspr('sprites\gns3.spr');

     pic[30]:=loadspr('sprites\stopplo.spr');
     pic[31]:=loadspr('sprites\gls1.spr');
     pic[32]:=loadspr('sprites\gls2.spr');
     pic[33]:=loadspr('sprites\gls3.spr');
     pic[34]:=loadspr('sprites\gls4.spr');
     pic[35]:=loadspr('sprites\gls5.spr');
     pic[36]:=loadspr('sprites\gls3.spr');
     pic[37]:=loadspr('sprites\gls2.spr');
     pic[38]:=loadspr('sprites\gls3.spr');

     pic[40]:=loadspr('sprites\stoppn.spr');
     pic[41]:=loadspr('sprites\gkn1.spr');
     pic[42]:=loadspr('sprites\gkn2.spr');
     pic[43]:=loadspr('sprites\gkn3.spr');
     pic[44]:=loadspr('sprites\gkn4.spr');
     pic[45]:=loadspr('sprites\gkn5.spr');
     pic[46]:=loadspr('sprites\gkn3.spr');
     pic[47]:=loadspr('sprites\gkn2.spr');
     pic[48]:=loadspr('sprites\gkn3.spr');

     pic[50]:=loadspr('sprites\stoppnl.spr');
     pic[51]:=loadspr('sprites\gln1.spr');
     pic[52]:=loadspr('sprites\gln2.spr');
     pic[53]:=loadspr('sprites\gln3.spr');
     pic[54]:=loadspr('sprites\gln4.spr');
     pic[55]:=loadspr('sprites\gln5.spr');
     pic[56]:=loadspr('sprites\gln3.spr');
     pic[57]:=loadspr('sprites\gln2.spr');
     pic[58]:=loadspr('sprites\gln3.spr');

     pic[60]:=loadspr('sprites\stoppnn.spr');
     pic[61]:=loadspr('sprites\gnn1.spr');
     pic[62]:=loadspr('sprites\gnn2.spr');
     pic[63]:=loadspr('sprites\gnn3.spr');
     pic[64]:=loadspr('sprites\gnn4.spr');
     pic[65]:=loadspr('sprites\gnn5.spr');
     pic[66]:=loadspr('sprites\gnn3.spr');
     pic[67]:=loadspr('sprites\gnn2.spr');
     pic[68]:=loadspr('sprites\gnn3.spr');

     pic[70]:=loadspr('sprites\stoppelk.spr');
     pic[71]:=loadspr('sprites\gkw1.spr');
     pic[72]:=loadspr('sprites\gkw2.spr');
     pic[73]:=loadspr('sprites\gkw3.spr');
     pic[74]:=loadspr('sprites\gkw4.spr');
     pic[75]:=loadspr('sprites\gkw5.spr');
     pic[76]:=loadspr('sprites\gkw3.spr');
     pic[77]:=loadspr('sprites\gkw2.spr');
     pic[78]:=loadspr('sprites\gkw3.spr');

     pic[80]:=loadspr('sprites\stop2el.spr');
     pic[81]:=loadspr('sprites\glw1.spr');
     pic[82]:=loadspr('sprites\glw2.spr');
     pic[83]:=loadspr('sprites\glw3.spr');
     pic[84]:=loadspr('sprites\glw4.spr');
     pic[85]:=loadspr('sprites\glw5.spr');
     pic[86]:=loadspr('sprites\glw3.spr');
     pic[87]:=loadspr('sprites\glw2.spr');
     pic[88]:=loadspr('sprites\glw3.spr');

     pic[90]:=loadspr('sprites\stop3er.spr');
     pic[91]:=loadspr('sprites\gnw1.spr');
     pic[92]:=loadspr('sprites\gnw2.spr');
     pic[93]:=loadspr('sprites\gnw3.spr');
     pic[94]:=loadspr('sprites\gnw4.spr');
     pic[95]:=loadspr('sprites\gnw5.spr');
     pic[96]:=loadspr('sprites\gnw3.spr');
     pic[97]:=loadspr('sprites\gnw2.spr');
     pic[98]:=loadspr('sprites\gnw3.spr');

     pic[100]:=loadspr('sprites\stopperk.spr');
     pic[101]:=loadspr('sprites\gke1.spr');
     pic[102]:=loadspr('sprites\gke2.spr');
     pic[103]:=loadspr('sprites\gke3.spr');
     pic[104]:=loadspr('sprites\gke4.spr');
     pic[105]:=loadspr('sprites\gke5.spr');
     pic[106]:=loadspr('sprites\gke3.spr');
     pic[107]:=loadspr('sprites\gke2.spr');
     pic[108]:=loadspr('sprites\gke3.spr');

     pic[110]:=loadspr('sprites\stop2er.spr');
     pic[111]:=loadspr('sprites\gle1.spr');
     pic[112]:=loadspr('sprites\gle2.spr');
     pic[113]:=loadspr('sprites\gle3.spr');
     pic[114]:=loadspr('sprites\gle4.spr');
     pic[115]:=loadspr('sprites\gle5.spr');
     pic[116]:=loadspr('sprites\gle3.spr');
     pic[117]:=loadspr('sprites\gle2.spr');
     pic[118]:=loadspr('sprites\gle3.spr');

     pic[120]:=loadspr('sprites\stop3el.spr');
     pic[121]:=loadspr('sprites\gne1.spr');
     pic[122]:=loadspr('sprites\gne2.spr');
     pic[123]:=loadspr('sprites\gne3.spr');
     pic[124]:=loadspr('sprites\gne4.spr');
     pic[125]:=loadspr('sprites\gne5.spr');
     pic[126]:=loadspr('sprites\gne3.spr');
     pic[127]:=loadspr('sprites\gne2.spr');
     pic[128]:=loadspr('sprites\gne3.spr');

     pic[130]:=loadspr('sprites\wks1.spr');
     pic[131]:=loadspr('sprites\wks2.spr');
     pic[132]:=loadspr('sprites\wks3.spr');
     pic[133]:=loadspr('sprites\wks4.spr');
     pic[134]:=loadspr('sprites\wks5.spr');
     pic[135]:=loadspr('sprites\wks6.spr');
     pic[136]:=loadspr('sprites\wks1.spr');

     pic[140]:=loadspr('sprites\wls1.spr');
     pic[141]:=loadspr('sprites\wls6.spr');
     pic[142]:=loadspr('sprites\wls5.spr');
     pic[143]:=loadspr('sprites\wls4.spr');
     pic[144]:=loadspr('sprites\wls3.spr');
     pic[145]:=loadspr('sprites\wls2.spr');
     pic[146]:=loadspr('sprites\wls1.spr');

     pic[150]:=loadspr('sprites\wkn1.spr');
     pic[151]:=loadspr('sprites\wkn2.spr');
     pic[152]:=loadspr('sprites\wkn3.spr');
     pic[153]:=loadspr('sprites\wkn4.spr');
     pic[154]:=loadspr('sprites\wkn5.spr');
     pic[155]:=loadspr('sprites\wkn6.spr');
     pic[156]:=loadspr('sprites\wkn1.spr');

     pic[160]:=loadspr('sprites\wln1.spr');
     pic[161]:=loadspr('sprites\wln6.spr');
     pic[162]:=loadspr('sprites\wln5.spr');
     pic[163]:=loadspr('sprites\wln4.spr');
     pic[164]:=loadspr('sprites\wln3.spr');
     pic[165]:=loadspr('sprites\wln2.spr');
     pic[166]:=loadspr('sprites\wln1.spr');

     pic[170]:=loadspr('sprites\wke1.spr');
     pic[171]:=loadspr('sprites\wke2.spr');
     pic[172]:=loadspr('sprites\wke3.spr');
     pic[173]:=loadspr('sprites\wke4.spr');
     pic[174]:=loadspr('sprites\wke5.spr');
     pic[175]:=loadspr('sprites\wke6.spr');
     pic[176]:=loadspr('sprites\wke1.spr');

     pic[180]:=loadspr('sprites\wle1.spr');
     pic[181]:=loadspr('sprites\wle6.spr');
     pic[182]:=loadspr('sprites\wle5.spr');
     pic[183]:=loadspr('sprites\wle4.spr');
     pic[184]:=loadspr('sprites\wle3.spr');
     pic[185]:=loadspr('sprites\wle2.spr');
     pic[186]:=loadspr('sprites\wle1.spr');

     pic[190]:=loadspr('sprites\wkw.spr');
     pic[191]:=loadspr('sprites\wkw2.spr');
     pic[192]:=loadspr('sprites\wkw3.spr');
     pic[193]:=loadspr('sprites\wkw4.spr');
     pic[194]:=loadspr('sprites\wkw5.spr');
     pic[195]:=loadspr('sprites\wkw6.spr');
     pic[196]:=loadspr('sprites\wkw1.spr');

     pic[200]:=loadspr('sprites\wlw1.spr');
     pic[201]:=loadspr('sprites\wlw6.spr');
     pic[202]:=loadspr('sprites\wlw5.spr');
     pic[203]:=loadspr('sprites\wlw4.spr');
     pic[204]:=loadspr('sprites\wlw3.spr');
     pic[205]:=loadspr('sprites\wlw2.spr');
     pic[206]:=loadspr('sprites\wlw1.spr');
end;


procedure done_all;
begin
     doneall;
     keyboarddone;
end;



procedure Init_all;
begin
     initmap('maps\default.rsm');
     page:=0;
     teki:=0;
     izmena:=false;
     instr:=instrNO;
     t:=0;
     texterror:='';
     new(intext);
     intext^.up:=nil;
     intext^.down:=nil;
     intext^.s:='';
     tek:=intext;
     xhero:=1;
     yhero:=1;
     tekstay:=20;
     instr:=instrNO;
     visabl:=intext;
     nametxt:='naname.mtx';

     initall (m640x480);
     keyboardinit;
     initbuttons;
     initpictures;
     inittextures;
     lang:=true;
     language('rus');
end;
procedure translator(name:string);
begin
     nz:='А';
     assign (f,name);
     reset (f);
     new(Code);
     Last:=Code;
     automat;
     close (f);
end;
procedure outmap(hero:boolean);
var i,j:integer;
begin
     for i:=1 to 8 do
      for j:=1 to 8 do
      begin
           if pole[i,j]<>0
           then
           begin
           putsprite (j*50-25,i*50+5,pic[pole[i,j]]);
           {putsprite (j*50-25,i*50+10,pic[1]);}
           end;
           if pole[i,j]in item
           then begin
{                     putsprite (j*50-25,i*50+5,pic[0]);        }
                     putsprite (j*50-25,i*50+5,pic[pole[i,j]]);
                end;
           if (hero)and(i=xhero) and(j=yhero)
           then putsprite (j*50-20,i*50-15,pic[tekstay]);
      end;
end;
procedure outtxt(erstr:integer;color:integer);
var tz:txt;
    i,e:integer;
begin
     tz:=visabl;
     i:=1;
     repeat
     if (erstr-count2(intext,visabl))=i
     then begin
          setcolor(color);
          outtextxy(448,35+15*i,chr(219)+chr(219)+chr(219)+chr(219)+chr(219)+chr(219)+chr(219)+chr(219)+chr(219)+chr(219)
          +chr(219)+chr(219)+chr(219)
          +chr(219)+chr(219)+chr(219)
          +chr(219)+chr(219)+chr(219)+chr(219)+chr(219)+chr(219)+chr(219))  ;
          setcolor(255);
          end
     else setcolor(255);
     if (tz=tek)and(tkursor=4)
     then begin
          tkursor:=0;
          if visabli=0
          then  outtextxy((452)+(teki-visabli)*textwidth('_'),35+15*i,'_')
          else outtextxy((452)+(teki-visabli+1)*textwidth('_'),35+15*i,'_');
          end;
     outtextxy(452,35+15*i,copy(tz^.s,visabli,ympt));
     tz:=tz^.down;
     inc(i);
     until (tz=nil)or(i=xmpt);
end;
procedure pere(hero:boolean;n:integer);
begin
     delay(PAUSE);
          setvisualpage(page);
           page:=1-page;
           waitvbl;
           setactivepage(page);
     drawscreen (0,0,639,479,'sprites\fon3.dat');
                for i:=1 to maxbutton do
           drawbutton (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2,butt[i].s,false,false);
           drawscreen (450,50,630,460,'sprites\mib3.tex');
           ramka(440,42,639,469);
           if n>(xmpt+count2(intext,visabl))
          then makefirst(n-20);
          outtxt(n,lightblue);
          outmap(hero);
end;
procedure godown(n:integer);
const sp=6;
var i,form,y:integer;
begin
     form:=instr;
     for i:=1 to 8 do
     begin
     inc(form);
     pere(false,n);
     putsprite (yhero*50-20,xhero*50-15+(i*sp),pic[form]);
     end;
end;
procedure goup(n:integer);
const sp=6;
var i,form,y:integer;
begin
     case instr of
     instrNO:form:=60;
     instrpik:form:=40;
     instrlop:form:=50;
     end;
     for i:=1 to 8 do
     begin
     inc(form);
     pere(false,n);
     putsprite (yhero*50-20,xhero*50-15-(i*sp),pic[form]);
     end;
end;
procedure gowest(n:integer);
const sp=6;
var i,form,y:integer;
begin
     case instr of
     instrNO:form:=90;
     instrpik:form:=70;
     instrlop:form:=80;
     end;
     for i:=1 to 8 do
     begin
     inc(form);
     pere(false,n);
     putsprite (yhero*50-20-(i*sp),xhero*50-15,pic[form]);
     end;
end;
procedure goeast(n:integer);
const sp=6;
var i,form,y:integer;
begin
     case instr of
     instrNO:form:=120;
     instrpik:form:=100;
     instrlop:form:=110;
     end;
     for i:=1 to 8 do
     begin
     inc(form);
     pere(false,n);
     putsprite (yhero*50-20+(i*sp),xhero*50-15,pic[form]);
     end;
end;
procedure makeform(cod:integer);
begin
     case instr of
     instrNO:begin
                  case cod of
                  1:tekstay:=60;
                  2:tekstay:=20;
                  3:tekstay:=90;
                  4:tekstay:=120;
                  end;
             end;
     instrpik:begin
                  case cod of
                  1:tekstay:=40;
                  2:tekstay:=10;
                  3:tekstay:=70;
                  4:tekstay:=100;
                  end;
             end;
     instrlop:begin
                  case cod of
                  1:tekstay:=50;
                  2:tekstay:=30;
                  3:tekstay:=80;
                  4:tekstay:=110;
                  end;
             end;
     end;
end;
function sovmest (obj:integer):boolean;
begin
     case obj of
     9:sovmest:=instr=instrPIK;
     2:sovmest:=instr=instrLOP;
     end;
end;
procedure workdown(n:integer);
var form:integer;
    i:integer;
begin
     if instr<>instrNO
     then begin
     case instr of
     instrpik:form:=129;
     instrlop:form:=139;
     end;
     for i:=1 to 6 do
     begin
     inc(form);
     pere(false,n);
     putsprite (yhero*50-20,xhero*50-15,pic[form]);
     end;
     end;
end;
procedure workup(n:integer);
var form:integer;
    i:integer;
begin
     if instr<>instrNO
     then begin
     case instr of
     instrpik:form:=149;
     instrlop:form:=159;
     end;
     for i:=1 to 6 do
     begin
     inc(form);
     pere(false,n);
     putsprite (yhero*50-20,xhero*50-15,pic[form]);
     end;
     end;
end;
procedure workright(n:integer);
var form:integer;
    i:integer;
begin
     if instr<>instrNO
     then begin
     case instr of
     instrpik:form:=169;
     instrlop:form:=179;
     end;
     for i:=1 to 6 do
     begin
     inc(form);
     pere(false,n);
     putsprite (yhero*50-20,xhero*50-15,pic[form]);
     end;
     end;
end;

procedure workleft(n:integer);
var form:integer;
    i:integer;
begin
     if instr<>instrNO
     then begin
     case instr of
     instrpik:form:=189;
     instrlop:form:=199;
     end;
     for i:=1 to 6 do
     begin
     inc(form);
     pere(false,n);
     if ((i in [5,6])and(instr=instrpik))or((i in [2,3])and(instr=instrlop))
     then putsprite (yhero*50-30,xhero*50,pic[form])
     else putsprite (yhero*50-30,xhero*50-10,pic[form]);
     end;
     end;
end;
{procedure threwinstr(var instr:integer;var under:integer);
begin
     case instr of
     instrNO:begin
                  if under=4
                  then inc(ngold)
                  else instr:=under;
                  under:=0;
             end
     instrbegin
          end;
end;      }
function tmo(n:integer):boolean;
var c:char;
    x:word;
    x1:longint;
begin
     x1:=readkeyboard(c);
     tmo:=x1=kesc;
     if x1=kesc
     then errori('Прервано пользователем',n);
end;
procedure intergraph(p:pNode);
var i,nz,kz:integer;
begin
     pere(true,0);
     while (p<>nil)and(p^.typ<>cmProg)and(not errorF)and(not tmo(p^.n)) do
     begin
          pere(true,p^.n);
          case p^.Typ of
          cmfor:begin
                     if p^.nz^.f
                     then nz:=varn[p^.nz^.p].znachi
                     else nz:=p^.nz^.p;
                     if p^.kz^.f
                     then kz:=varn[p^.kz^.p].znachi
                     else kz:=p^.kz^.p;
                     if p^.dfor
                     then for i:=nz to kz do
                          begin
                               varn[p^.fori].znachi:=i;
                               intergraph(p^.body)
                          end
                     else for i:=nz downto kz do
                          begin
                               varn[p^.fori].znachi:=i;
                               intergraph(p^.body)
                          end
                end;
          cmLeft:begin
                      if (yhero>1)and(pole[xhero,yhero-1]in iten)
                      then
                      begin
                      gowest(p^.n);
                      dec(yhero);
                      makeform(3);
                      pere(true,p^.n);
                      end
                      else begin
                           errori('Непреодолимое препятствие',p^.n);
                           exit;
                           end;
                      end;
          cmRight:begin
                      if (yhero<8)and(pole[xhero,yhero+1]in iten)
                      then
                      begin
                      goeast(p^.n);
                      inc(yhero);
                      makeform(4);
                      pere(true,p^.n);
                      end
                      else begin
                           errori('Непреодолимое препятствие',p^.n);
                           exit;
                           end;
                      end;
          cmUp:begin
                    if (xhero>1)and(pole[xhero-1,yhero]in iten)
                 then begin
                      goup(p^.n);
                      dec(xhero);
                      makeform(1);
                      pere(true,p^.n);
                      end
                 else begin
                      errori('Непреодолимое препятствие',p^.n);
                      exit;
                      end;
                 end;
          cmDown:begin
                      if (xhero<8)and(pole[xhero+1,yhero]in iten)
                      then begin
                      godown(p^.n);
                      inc(xhero);
                      makeform(2);
                      pere(true,p^.n);
                      end
                      else
                          begin
                      errori('Непреодолимое препятствие',p^.n);
                      exit;
                      end;
                 end;

          cmwork_Left:if (yhero>1)and(not (pole[xhero,yhero-1] in iten))
                      then
                      if sovmest(pole[xhero,yhero-1])
                      then begin
                      workleft(p^.n); workleft(p^.n);
                      pole[xhero,yhero-1]:=0;
                      makeform(3);
                      pere(true,p^.n);
                      end

                      else begin
                           errori('Неподходящий инструмент',p^.n);
                      exit;
                           end;
          cmwork_Right:if (yhero<8)and(not (pole[xhero,yhero+1] in iten))
                 then
                 if sovmest(pole[xhero,yhero+1])
                      then begin
                      workright(p^.n); workright(p^.n);
                       pole[xhero,yhero+1]:=0;
                      makeform(4);
                      pere(true,p^.n);
                      end
                      else begin
                           errori('Неподходящий инструмент',p^.n);
                      exit;
                           end;
          cmwork_Up:if (xhero>1)and(not (pole[xhero-1,yhero] in iten))
                 then
                     if sovmest(pole[xhero-1,yhero])
                      then begin
                      workup(p^.n); workup(p^.n);
                      pole[xhero-1,yhero]:=0;
                      makeform(1);
                      pere(true,p^.n);
                      end

                      else begin
                           errori('Неподходящий инструмент',p^.n);
                      exit;
                           end;
          cmwork_Down:if (xhero<8)and(not (pole[xhero+1,yhero] in iten))
                 then
                     if sovmest(pole[xhero+1,yhero])
                      then begin
                      workdown(p^.n); workdown(p^.n);
                      pole[xhero+1,yhero]:=0;
                      makeform(2);
                      pere(true,p^.n);
                      end

                      else begin
                           errori('Неподходящий инструмент',p^.n);
                      exit;
                           end;
          cmPrisv:case varn[p^.index].type_ of
                  cmInt:begin
                        varn[p^.index].znachi:=round(arifmet(p^.znach,bolv));
                       end;
                  cmreal:begin
                        varn[p^.index].znachr:=arifmet(p^.znach,bolv);
                       end;
                  cmchar:begin
                              if p^.znach^.typenode=4
                              then varn[p^.index].znachch:=p^.znach^.str[1]
                              else if p^.znach^.typenode=2
                                   then varn[p^.index].znachch:=varn[p^.znach^.index].znachch;
                         end;
                       end;
          cmIf:begin
                    if sol(p^.usl)
                    then intergraph(p^.then_)
                    else if p^.else_<>nil
                         then intergraph(p^.else_);
               end;
               cmfor:begin
                     if p^.nz^.f
                     then nz:=varn[p^.nz^.p].znachi
                     else nz:=p^.nz^.p;
                     if p^.kz^.f
                     then kz:=varn[p^.kz^.p].znachi
                     else kz:=p^.kz^.p;
                     if p^.dfor
                     then for i:=nz to kz do
                          begin
                               varn[p^.fori].znachi:=i;
                               intergraph(p^.body);
                               pere(true,p^.n);
                          end
                     else for i:=nz downto kz do
                          begin
                               varn[p^.fori].znachi:=i;
                               intergraph(p^.body);
                               pere(true,p^.n);
                          end
                end;
          cmWhile:begin
                     while sol(p^.uslw)and(not tmo(p^.n))and(not errorF) do
                     begin
                     intergraph(p^.bodyW);
                     pere(true,p^.n);
                     end;
                end;
          cmrepeat:begin
                     repeat
                     intergraph(p^.bodyr);
                     pere(true,p^.n);
                     until sol(p^.uslr) or tmo(p^.n) or errorF;
                end;
          cmTake:begin
                      if pole[xhero,yhero] in item
                      then case pole[xhero,yhero] of
                           4:begin
                                  inc(ngold);
                                  pole[xhero,yhero]:=0;
                             end;
                           6:begin
                                case instr of
                                30:pole[xhero,yhero]:=8;
                                20:pole[xhero,yhero]:=0;
                                end;
                                instr:=10;
                               end;
                               8:begin
                                case instr of
                                10:pole[xhero,yhero]:=6;
                                20:pole[xhero,yhero]:=0;
                                end;
                                instr:=30;
                               end;
                           end;
                 end;
          end;
          p:=p^.next;
     end;
     if not errorf
     then pere(true,0);
end;
procedure REinitbuttons;
begin
     butt[1].x1:=100;
     butt[1].x2:=200;
     butt[1].y1:=0;
     butt[1].y2:=30;
     butt[1].s:='Загрузить';
     butt[1].sost:=cmLoadMap;
     butt[1].f:=false;
     butt[1].ns:=0;

     butt[2].x1:=0;
     butt[2].x2:=100;
     butt[2].y1:=0;
     butt[2].y2:=30;
     butt[2].s:='Новый';
     butt[2].sost:=cmnewmap;
     butt[2].f:=false;
     butt[2].ns:=0;

     butt[3].x1:=200;
     butt[3].x2:=300;
     butt[3].y1:=0;
     butt[3].y2:=30;
     butt[3].s:='Сохранить';
     butt[3].sost:=cmsavemap;
     butt[3].f:=false;
     butt[3].ns:=0;

     butt[5].x1:=400;
     butt[5].x2:=500;
     butt[5].y1:=0;
     butt[5].y2:=30;
     butt[5].s:='Выход';
     butt[5].sost:=cmexit;
     butt[5].f:=false;
     butt[5].ns:=0;

     butt[4].x1:=300;
     butt[4].x2:=400;
     butt[4].y1:=0;
     butt[4].y2:=30;
     butt[4].s:='Обратно';
     butt[4].sost:=cmre;
     butt[4].f:=false;
     butt[4].ns:=0;
     maxbutton:=5;
end;
procedure save_M(name:string;xher,yher:integer);
var i,j:integer;
begin
     assign(f,name);
     rewrite(f);
     writeln(f,xher,' ',yher);
     for i:=1 to 8 do
     begin
      for j:=1 to 7 do
      write(f,pole[i,j],' ');
      write(f,pole[i,8]);
      writeln(f);
     end;
     close(f);
end;
procedure saveMap;
const xz1=320;
      yz1=150;
      xz2=490;
      yz2=200;
      xo1=320;
      yo1=250;
      xo2=490;
      yo2=300;
var c:char;
    ex,select:boolean;
    s:string;
    x:word;
    ku:integer;
begin
     select:=false;
     builddir('maps\*.rsm');
     s:='maps\';
     ku:=length(s);
     ex:=false;
     tkursor:=0;
     repeat
           setvisualpage(page);
           waitvbl;
           page:=1-page;
           setactivepage (page);
           drawscreen (100,100,300,380,'sprites\mib3.tex');
           drawscreen (299,100,500,380,'sprites\mib3.tex');
           ramka(90,90,310,360);
           ramka(90,350,510,390);
           ramka(300,90,510,360);
           drawbutton (xz1,yz1,xz2,yz2,'Сохранить',false,false);
           drawbutton (xo1,yo1,xo2,yo2,'Отмена',false,false);
           showmouse;
           outwin(select);
           if mousebutton=1
           then begin
               while mousebutton=1 do;
               if mousein(100,100,300,380)
               then select:=true;
               if mousein (90,350,510,390)
               then select:=false;
               if mousein (xo1,yo1,xo2,yo2)
               then ex:=true;
               if mousein (xz1,yz1,xz2,yz2)
               then begin
                    if select
                    then save_M('maps\'+tekwin^.dir.name,xhero,yhero)
                    else save_m(s,xhero,yhero);
                    ex:=true;
                    end;
                if select then selection(tekwin);
           end;
           x:=readkeyboard(c);
           if select
           then
       {}  begin
           outwin(true);
           if x=42000+kup
           then
           if tekwin^.up<>nil
            then  begin
                  if tekwin=viswin
                  then begin
                       tekwin:=tekwin^.up;
                       viswin:=viswin^.up;
                       end
                  else
                  begin
                  tekwin:=tekwin^.up;
                  end;
                  end;
           if x=42000+kdown
           then if tekwin^.down<>nil
                then
                    begin
                         if countw>=15
                         then begin
                              viswin:=viswin^.down;
                              tekwin:=tekwin^.down;
                              end
                         else tekwin:=tekwin^.down;
                    end;
                setcolor(30);
                outtextxy(102,362,s);
                if x=kenter
           then   begin
                       save_M('maps\'+tekwin^.dir.name,xhero,yhero);
                    ex:=true;
                    end;
       {}  end;
           if not select
           then begin
           if c<>#0
           then begin
                S:=copy(s,1,ku)+c+copy(s,ku+1,length(s)-ku);;
                inc(ku);
                end;
           if x=kenter
               then begin
                    save_M(s,xhero,yhero);
                    ex:=true;
                    end;
           if x=kBackSpace
           then begin
                s:=copy(s,1,ku-1)+copy(s,ku+1,length(s)-ku);
                dec(ku);
                end;
           if x=42000+kDelete
           then begin
                s:=copy(s,1,ku)+copy(s,ku+2,length(s)-ku);
                end;
           if (x=42000+kright)and(ku<length(s))
           then inc(ku);
           if (x=42000+kleft)and(ku>0)
           then dec(ku);
           if x=kesc
           then ex:=true;
           setcolor(255);
           if tkursor>=5
           then begin
           tkursor:=0;
           outtextxy(102+ku*textwidth('_'),362,'_');
           end;
           outtextxy(102,362,s);
           inc(tkursor);
           end;
     until ex=true;
     sb:=0;
     tkursor:=0;
end;
procedure LoadMap;
const xz1=320;
      yz1=100;
      xz2=490;
      yz2=150;
      xo1=320;
      yo1=200;
      xo2=490;
      yo2=250;
      xt1=320;
      yt1=280;
      xt2=402;
      yt2=330;
      xm1=404;
      ym1=280;
      xm2=490;
      ym2=330;
var c:char;
    ex:boolean;
    s:string;
    x:word;
    ku:integer;
    stxt,smap,select:boolean;
begin
     builddir('maps\*.rsm');
     s:='maps\';
     ku:=length(s);
     ex:=false;
     tkursor:=0;
     select:=false;
     repeat
           setvisualpage(page);
           waitvbl;
           page:=1-page;
           setactivepage (page);
           drawscreen (100,100,300,380,'sprites\mib3.tex');
           drawscreen (299,100,500,380,'sprites\mib3.tex');
           ramka(90,90,310,360);
           ramka(90,350,510,390);
           ramka(300,90,510,360);
           drawbutton (xz1,yz1,xz2,yz2,'Загрузить',false,false);
           drawbutton (xo1,yo1,xo2,yo2,'Отмена',false,false);
           showmouse;
           if mousebutton=1
           then begin
               while mousebutton=1 do;
               if mousein (xo1,yo1,xo2,yo2)
               then ex:=true;
               if mousein(100,100,300,380)
               then select:=true;
               if mousein (90,350,510,390)
               then select:=false;
               if mousein (xz1,yz1,xz2,yz2)
               then begin
                         if select
                         then initmap('maps\'+tekwin^.dir.name)
                         else
                             begin
                                   if not findindir(pstrok(s))
                                       then begin
                                       massage('Файл не найден');
                                       sb:=cmloadmap;
                                       exit;
                                       end
                                       else initmap(s);
                             end;
                        ex:=true;
                        end;
               if select then selection(tekwin);
                    end;
           x:=readkeyboard(c);
           if select
           then
       {}  begin
           outwin(true);
           if x=42000+kup
           then
           if tekwin^.up<>nil
            then  begin
                  if tekwin=viswin
                  then begin
                       tekwin:=tekwin^.up;
                       viswin:=viswin^.up;
                       end
                  else
                  begin
                  tekwin:=tekwin^.up;
                  end;
                  end;
           if x=42000+kdown
           then if tekwin^.down<>nil
                then
                    begin
                         if countw>=15
                         then begin
                              viswin:=viswin^.down;
                              tekwin:=tekwin^.down;
                              end
                         else tekwin:=tekwin^.down;
                    end;
                setcolor(30);
                outtextxy(102,362,s);
           if x=kenter
           then   begin
                         initmap('maps\'+tekwin^.dir.name);
                    ex:=true;
                    end;
       {}  end;
           if not select
           then
      {}   begin
           outwin(false);
           if c<>#0
           then begin
                S:=copy(s,1,ku)+c+copy(s,ku+1,length(s)-ku);;
                inc(ku);
                end;

           if x=kenter
           then   begin
                        if not findindir(pstrok(s))
                         then begin
                              massage('Файл не найден');
                              sb:=cmloadmap;
                              exit;
                             end
                         else initmap(s);
                    ex:=true;
                    end;
           if (x=kBackSpace)and(ku>0)
           then begin
                s:=copy(s,1,ku-1)+copy(s,ku+1,length(s)-ku);
                dec(ku);
                end;
           if x=42000+kDelete
           then begin
                s:=copy(s,1,ku)+copy(s,ku+2,length(s)-ku);
                end;
           if (x=42000+kright)and(ku<length(s))
           then inc(ku);
           if (x=42000+kleft)and(ku>0)
           then dec(ku);
           setcolor(255);
           if tkursor>=5
           then begin
           tkursor:=0;
           outtextxy(102+ku*textwidth('_'),362,'_');
           outtextxy(102,362,s);
           end;
           outtextxy(102,362,s);
        {} end;
           if x=kesc
           then ex:=true;
           inc(tkursor);
     until ex=true;
     tkursor:=0;
     teki:=0;
     visabli:=0;
end;
procedure mapEditor;
const maxpic=6;
     Tone:array[1..maxpic] of integer =(0,2,9,4,6,8);
     xher=565;
     yher=55;
var x:word;
    c:char;
    tekpic,i,ii,jj,ppic,ip,jp:integer;
begin
     instr:=instrNO;
     ip:=xmaster;
     jp:=ymaster;
     ppic:=pole[ip,jp];
     xhero:=xmaster;
     yhero:=ymaster;
     tekpic:=-1;
     reinitbuttons;
     setvisualpage(page);
           waitvbl;
           page:=1-page;
           setactivepage (page);
     repeat
           setvisualpage(page);
           waitvbl;
           page:=1-page;
           setactivepage (page);
           drawscreen (0,0,639,479,'sprites\fon3.dat');
           setcolor(219);
           bar(450,50,630,460);
           drawscreen (450,50,630,460,'sprites\wood2.tex');
           ramka(440,42,639,469);
           outmap(true);
           for i:=1 to maxbutton do
           drawbutton (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2,butt[i].s,false,false);

           for i:=1 to maxpic do
           putsprite (490,(i*50)+(i*20)-15,pic[tone[i]]);
           putsprite (xher,yher,pic[20]);


           if tekpic>=0
           then putsprite (mousex-25,mouseY-25,pic[tekpic]);


           if mousebutton=1
           then begin
                while mousebutton=1 do;

                if mousein(xher,yher,xher+42,yher+64)
                then tekpic:=20;

                for i:=1 to maxpic do
                if mousein (510,(i*50)+(i*20)-15,510+50,(i*50)+(i*20)-15+50)
                then tekpic:=tone[i];
               for i:=1 to MaxButton do
               if (mouseIn (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2))and((butt[i].ns=sb)or(butt[i].ns=0))
               then BEGIN
                          sb:=butt[i].sost;
                          drawbutton (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2,butt[i].s,false,false);
                          t:=0;
                     end;
               for ii:=1 to 8 do
               for jj:=1 to 8 do
               if (tekpic>=0)and(mousein (jj*50-25,ii*50+5,jj*50-25+50,ii*50+5+50))
               then begin
                    if (ii=xhero)and(jj=yhero)and(tekpic<>20)
                    then begin
                              ppic:=tekpic;
                              ip:=ii;jp:=jj;
                         end;
                    if tekpic=20
                    then begin
                         xhero:=ii;
                         yhero:=jj;
                         pole[ip,jp]:=ppic;
                         ppic:=pole[ii,jj];
                         ip:=ii;jp:=jj;
                         pole[ii,jj]:=0;
                         end
                    else begin
                         pole[ii,jj]:=tekpic;
                         if (ii=xhero)and(jj=yhero)
                         then begin
                              xhero:=0;
                         yhero:=0;
                         end;
                         end;
                    end;
                end;

           x:=readkeyboard(c);
           while readkeyboard(c)<>0 do;
           case x of
           kesc:sb:=cmRE;
           56045:sb:=cmExit;
           kF3:sb:=cmLoadmap;
           kF2:sb:=cmsavemap;
           end;
           if (tekpic>=0)and(x=kesc)
           then begin
                tekpic:=-1;
                sb:=0;
                end;
           if sb=cmNEwMAp
           then begin
                initmap('maps\default.rsm');
                sb:=0;
                end;
           if sb=cmsaveMAp
           then if (xhero=0)or(yhero=0)
                then begin
                     massage('Установите стартовую позицию');
                     sb:=0;
                     end;
           if sb=cmsaveMAp
           then
           begin
           drawscreen (0,0,639,479,'sprites\fon3.dat');
           setcolor(219);
           bar(450,50,630,460);
           drawscreen (450,50,630,460,'sprites\wood2.tex');
           ramka(440,42,639,469);
           outmap(true);
           for i:=1 to maxbutton do
           drawbutton (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2,butt[i].s,false,false);
           for i:=1 to maxpic do
           putsprite (490,(i*50)+(i*20)-15,pic[tone[i]]);
           putsprite (xher,yher,pic[20]);


           setvisualpage(page);
           waitvbl;
           page:=1-page;
           setactivepage (page);
           drawscreen (0,0,639,479,'sprites\fon3.dat');
           setcolor(219);
           bar(450,50,630,460);
           drawscreen (450,50,630,460,'sprites\wood2.tex');
           ramka(440,42,639,469);
           outmap(true);
           for i:=1 to maxbutton do
           drawbutton (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2,butt[i].s,false,false);
           for i:=1 to maxpic do
           putsprite (490,(i*50)+(i*20)-15,pic[tone[i]]);
           putsprite (xher,yher,pic[20]);

           for i:=1 to maxpic do
           putsprite (490,(i*50)+(i*20)-15,pic[tone[i]]);
           putsprite (xher,yher,pic[20]);
                      sb:=0;
                      language('eng');
                      saveMap;
                      language('rus');
                end;
           if sb=cmLoadMap
           then begin
           drawscreen (0,0,639,479,'sprites\fon3.dat');
           setcolor(219);
           bar(450,50,630,460);
           drawscreen (450,50,630,460,'sprites\wood2.tex');
           ramka(440,42,639,469);
           outmap(true);
           for i:=1 to maxbutton do
           drawbutton (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2,butt[i].s,false,false);
           for i:=1 to maxpic do
           putsprite (490,(i*50)+(i*20)-15,pic[tone[i]]);
           putsprite (xher,yher,pic[20]);


           setvisualpage(page);
           waitvbl;
           page:=1-page;
           setactivepage (page);
           drawscreen (0,0,639,479,'sprites\fon3.dat');
           setcolor(219);
           bar(450,50,630,460);
           drawscreen (450,50,630,460,'sprites\wood2.tex');
           ramka(440,42,639,469);
           outmap(true);
           for i:=1 to maxbutton do
           drawbutton (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2,butt[i].s,false,false);
           for i:=1 to maxpic do
           putsprite (490,(i*50)+(i*20)-15,pic[tone[i]]);
           putsprite (xher,yher,pic[20]);

           for i:=1 to maxpic do
           putsprite (490,(i*50)+(i*20)-15,pic[tone[i]]);
           putsprite (xher,yher,pic[20]);
                      sb:=0;
                      language('eng');
                      loadMap;
                      language('rus');
                end;
     until (sb=cmExit)or (sb=cmRE);
     if sb=cmRE
     then begin
               if (xhero=0)or(yhero=0)
                then begin
                     massage('Установите стартовую позицию');
                     sb:=0;
                     end
           else
           begin
                      save_M('map.run',xhero,yhero);
                      initmap('map.run');
                end;
          end;
     if sb<>cmExit
     then sb:=0;
     initbuttons;
end;
function count_gold:integer;
var i,j,rez:integer;
begin
     rez:=0;
     for i:=1 to 8 do
      for j:=1 to 8  do
      if polelast[i,j]=4
      then inc(rez);
  count_gold:=rez;
end;
procedure checkPIK;
var i:integer;
begin
     i:=1;
     instr:=instrPIK;
     for i:=1 to 4 do
     begin
          makeform(i);
          putsprite (i*50,100,pic[tekstay]);
     end;
     instr:=instrNO;
     for i:=1 to 4 do
     begin
          makeform(i);
          putsprite (i*50,200,pic[tekstay]);
     end;
     instr:=instrlop;
     for i:=1 to 4 do
     begin
          makeform(i);
          putsprite (i*50,300,pic[tekstay]);
     end;

end;
procedure outinfo;
var tz:txt;
    i,e:integer;
begin
     tz:=visabl;
     i:=1;
     repeat
     setcolor(255);
     outtextxy(20,35+15*i,tz^.s);
     tz:=tz^.down;
     inc(i);
     until tz=nil;
end;
procedure outhelp;
var c:char;
    x:word;
    x1:longint;
begin
     x1:=0; x:=0;
     loadtxt('HELP.INF',intext);
     repeat
     setvisualpage(page);
           page:=1-page;
           waitvbl;
           setactivepage(page);
           drawscreen (0,50,630,460,'sprites\mib3.tex');
           ramka(0,42,639,469);
           outinfo;
     x1:=readkeyboard(c);
     X:=X1;
     case x of
     42072:
     begin
     if tek^.up<>nil
            then  begin
                  if tek=visabl
                  then begin
                       tek:=tek^.up;
                       visabl:=visabl^.up;
                       end
                  else
                  begin
                  tek:=tek^.up;
                  if length(tek^.s)<teki
                  then teki:=length(tek^.s);
                  end;
                  end;
            if visabli>=teki
            then visabli:=teki;
            end;
     42080:
     if tek^.down<>nil
            then  begin
                  if count=xmpt-2
                  then begin
                       tek:=tek^.down;
                       visabl:=visabl^.down;
                       end
                  else  tek:=tek^.down;
                  if length(tek^.s)<teki
                  then teki:=length(tek^.s);
                  if visabli>=teki
            then visabli:=teki;
                  end;
            end;
     until x1=kEsc;
end;
begin
     init_all;
     initmap('maps\map1.rsm');
     setvisualpage(page);
     repeat
           inc(t);
           inc(tkursor);
           pere(true,0);
           for i:=1 to maxbutton do
           drawbutton (butt[i].x1,butt[i].y1,butt[i].x2,butt[i].y2,butt[i].s,false,false);
           showmouse;
           MouseAnalis;
           keyboardAnalis;
           if t=2
           then
           begin
           t:=0;
           if tkursor<>1
           then
           case sb of
           cmloadtext:
                      begin
                      sb:=0;
                      language('eng');
                      loadtext;
                      language('rus');
                      end;
           cmSave:begin
                  sb:=0;
                  language('eng');
                  savetext;
                  language('rus');
                  end;
           cmrun:begin
                      teki:=0; visabli:=0;
                      tek:=intext;
                      visabl:=intext;
                      all:=false;
                      sb:=0;
                      xhero:=xmaster;
                      yhero:=ymaster;
                      ngold:=0;
                      instr:=20;
                       for i:=1 to 8 do
                       for j:=1 to 8 do
                       pole[i,j]:=polelast[i,j];
                      numbervar:=0;
                      topl:=0;
                      top:=0;
                      ch:=cmProg;lex:='';st:='';
                      errorF:=false;texterror:='';
                      tekstr:=0;tekstay:=20;
                      savetxt('text.run',intext);
                      {mark(memory); }
                      translator('text.run');
                      if not errorF
                      then begin
                           intergraph(code);
                           str(count_gold,sN);
                           str(ngold,sG);
                           pere(true,0);
                           if errorF
                          then begin
                               drawscreen (450,50,630,460,'sprites\mib3.tex');
                               outtxt(tekstr,ercol);
                               setvisualpage(page);
                               page:=1-page;
                               waitvbl;
                               setactivepage(page);
                               drawscreen (450,50,630,460,'sprites\mib3.tex');
                               outtxt(tekstr,ercol);
                               massage(texterror);
                               errorf:=false;
                               end
                           else massage('Собрано золотых слитков - '+sG+' из '+sN);
                           end;
                           if errorF
                           then begin
                               drawscreen (450,50,630,460,'sprites\mib3.tex');
                               outtxt(tekstr,ercol);
                               setvisualpage(page);
                               page:=1-page;
                               waitvbl;
                               setactivepage(page);
                               drawscreen (450,50,630,460,'sprites\mib3.tex');
                               outtxt(tekstr,ercol);
                               massage(texterror);
                               end;
                      {release(memory);}
                 end;
           cmCompile:begin
                          teki:=0; visabli:=0;
                          tek:=intext;
                          visabl:=intext;
                          all:=false;
                          ch:=cmProg;lex:='';st:='';
                          errorF:=false;texterror:='';
                          xhero:=xmaster;
                          yhero:=ymaster;
                          tekstay:=20;
                          for i:=1 to 8 do
                       for j:=1 to 8 do
                       pole[i,j]:=polelast[i,j];
                          numbervar:=0;
                          tekstr:=0;
                          topl:=0;
                          top:=0;
                          savetxt('text.run',intext);
                          translator('text.run');
                          if not errorF
                          then massage('Компиляция успешна');
                          if errorF
                          then begin
                               drawscreen (450,50,630,460,'sprites\mib3.tex');
                               outtxt(tekstr,red);
                               setvisualpage(page);
                               page:=1-page;
                               waitvbl;
                               setactivepage(page);
                               drawscreen (450,50,630,460,'sprites\mib3.tex');
                               outtxt(tekstr,red);
                               massage(texterror);
                               end;
                          sb:=0;
                     end;
           cmEdit:begin
                       for i:=1 to 8 do
                       for j:=1 to 8 do
                       pole[i,j]:=polelast[i,j];
                       instr:=instrNo;
                       tekstay:=instrNO;
                       outmap(true);
                        mapEditor;
                  end;
           cmNewtext:begin
                          sb:=0;
                          if izmena
                          then begin
                               saveORnot(false);
                               izmena:=false;
                               end;
                          teki:=0; visabli:=0;
                          tek:=intext;
                          visabl:=intext;
                          destroyTXT(intext);
                          {loadtxt('miner/default.new',intext);}
                     end;
           cmHelp:begin
                       savetxt('text.run',intext);
                       sb:=0;
                       outhelp;
                       loadtxt('text.run',intext);
                  end;
           demo1:begin
                      sb:=0;
                      initmap('maps\deMO1.rsm');
                      loadtxt('texts\demo1.mtx',intext)
                 end;
           demo2:begin
                      sb:=0;
                      initmap('maps\map1.rsm');
                      loadtxt('texts\real!.mtx',intext)
                 end;
           demo3:begin
                      sb:=0;
                      initmap('maps\demo2.rsm');
                      loadtxt('texts\demo2.mtx',intext)
                 end;
           demo4:begin
                      sb:=0;
                      initmap('maps\labir.rsm');
                      loadtxt('texts\demo3.mtx',intext)
                 end;
           demo5:begin
                      sb:=0;
                      initmap('maps\demo5.rsm');
                      loadtxt('texts\demo5.mtx',intext)
                 end;
           end;
           end;
     until sb=cmExit;
     done_all;
end.