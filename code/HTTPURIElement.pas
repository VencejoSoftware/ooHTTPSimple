unit HTTPURIElement;

interface

uses
  SysUtils, StrUtils,
  HTTPURIElementField,
  Generics.Collections;

type
  IHTTPURIElement = interface
    ['{9191363A-F8FA-414D-9BC4-AA6479BFBB8D}']
    function Index: Cardinal;
    function Content: String;
    function Fields: THTTPURIElementFieldList;
  end;

  THTTPURIElement = class sealed(TInterfacedObject, IHTTPURIElement)
  strict private
    _Index: Cardinal;
    _Content: String;
    _Fields: THTTPURIElementFieldList;
  public
    function Index: Cardinal;
    function Content: String;
    function Fields: THTTPURIElementFieldList;
    constructor Create(const Index: Cardinal; const Content: String);
    destructor Destroy; override;
    class function New(const Index: Cardinal; const Content: String): IHTTPURIElement;
  end;

  THTTPURIElementList = class sealed(TList<IHTTPURIElement>)
  strict private
    procedure ParseURI(const URI: String);
  public
    function ItemByName(const Name: String): IHTTPURIElement;
    class function New: THTTPURIElementList;
    class function NewByURI(const URI: String): THTTPURIElementList;
  end;

implementation

{ THTTPURIElement }

function THTTPURIElement.Index: Cardinal;
begin
  Result := _Index;
end;

function THTTPURIElement.Content: String;
begin
  Result := _Content;
end;

function THTTPURIElement.Fields: THTTPURIElementFieldList;
begin
  Result := _Fields;
end;

constructor THTTPURIElement.Create(const Index: Cardinal; const Content: String);
begin
  _Index := Index;
  _Fields := THTTPURIElementFieldList.NewByContent(Content);
  if _Fields.IsEmpty then
    _Content := Content
  else
    _Content := Copy(Content, 1, Pred(Pos('?', Content)));
end;

destructor THTTPURIElement.Destroy;
begin
  _Fields.Free;
  inherited;
end;

class function THTTPURIElement.New(const Index: Cardinal; const Content: String): IHTTPURIElement;
begin
  Result := THTTPURIElement.Create(Index, Content);
end;

{ THTTPURIElementList }

procedure THTTPURIElementList.ParseURI(const URI: String);
Var
  SeparatorPos, PosOffset: Integer;
  Text: String;
begin
  PosOffset := 1;
  repeat
    SeparatorPos := PosEx('/', URI, PosOffset);
    if SeparatorPos > 0 then
    begin
      Text := Copy(URI, PosOffset, SeparatorPos - PosOffset);
      if Length(Text) > 0 then
        Add(THTTPURIElement.New(Count, Text));
      PosOffset := Succ(SeparatorPos);
    end;
  until SeparatorPos < 1;
  Text := Copy(URI, PosOffset, Succ(Length(URI) - PosOffset));
  if Length(Text) > 0 then
    Add(THTTPURIElement.New(Count, Text));
end;

function THTTPURIElementList.ItemByName(const Name: String): IHTTPURIElement;
var
  Item: IHTTPURIElement;
begin
  Result := nil;
  for Item in Self do
    if SameText(Name, Item.Content) then
      Exit(Item);
end;

class function THTTPURIElementList.New: THTTPURIElementList;
begin
  Result := THTTPURIElementList.Create;
end;

class function THTTPURIElementList.NewByURI(const URI: String): THTTPURIElementList;
begin
  Result := THTTPURIElementList.New;
  Result.ParseURI(URI);
end;

end.
