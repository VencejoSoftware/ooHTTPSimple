unit HTTPURIElementField;

interface

uses
  SysUtils, StrUtils,
  Generics.Collections;

type
  IHTTPURIElementField = interface
    ['{4F6B9D2A-CC8E-4F97-B1D0-3B20E9FAF919}']
    function Name: String;
    function Expression: String;
  end;

  THTTPURIElementField = class sealed(TInterfacedObject, IHTTPURIElementField)
  strict private
    _Name, _Expression: String;
  public
    function Name: String;
    function Expression: String;
    constructor Create(const Name, Expression: String);
    class function New(const Name, Expression: String): IHTTPURIElementField;
    class function NewByText(const Text: String): IHTTPURIElementField;
  end;

  THTTPURIElementFieldList = class sealed(TList<IHTTPURIElementField>)
  strict private
    procedure ParseContent(const Content: String);
  public
    function ItemByName(const Name: String): IHTTPURIElementField;
    function IsEmpty: Boolean;
    class function New: THTTPURIElementFieldList;
    class function NewByContent(const Content: String): THTTPURIElementFieldList;
  end;

implementation

{ THTTPURIElementField }

function THTTPURIElementField.Name: String;
begin
  Result := _Name;
end;

function THTTPURIElementField.Expression: String;
begin
  Result := _Expression;
end;

constructor THTTPURIElementField.Create(const Name, Expression: String);
begin
  _Name := Name;
  _Expression := Expression;
end;

class function THTTPURIElementField.New(const Name, Expression: String): IHTTPURIElementField;
begin
  Result := THTTPURIElementField.Create(Name, Expression);
end;

class function THTTPURIElementField.NewByText(const Text: String): IHTTPURIElementField;
var
  Name, Expression: String;
  SeparatorPos: Integer;
begin
  SeparatorPos := Pos('=', Text);
  Name := Copy(Text, 1, Pred(SeparatorPos));
  Expression := Copy(Text, Succ(SeparatorPos));
  Result := THTTPURIElementField.Create(Name, Expression);
end;

{ THTTPURIElementFieldList }

function THTTPURIElementFieldList.IsEmpty: Boolean;
begin
  Result := Count < 1;
end;

function THTTPURIElementFieldList.ItemByName(const Name: String): IHTTPURIElementField;
var
  Item: IHTTPURIElementField;
begin
  Result := nil;
  for Item in Self do
    if SameText(Name, Item.Name) then
      Exit(Item);
end;

procedure THTTPURIElementFieldList.ParseContent(const Content: String);
Var
  SeparatorPos, PosOffset: Integer;
  Text: String;
begin
  PosOffset := Pos('?', Content);
  if PosOffset > 0 then
  begin
    PosOffset := Succ(PosOffset);
    repeat
      SeparatorPos := PosEx('&', Content, PosOffset);
      if SeparatorPos > 0 then
      begin
        Text := Copy(Content, PosOffset, SeparatorPos - PosOffset);
        if Length(Text) > 0 then
          Add(THTTPURIElementField.NewByText(Text));
        PosOffset := Succ(SeparatorPos);
      end;
    until SeparatorPos < 1;
    Text := Copy(Content, PosOffset, Succ(Length(Content) - PosOffset));
    if Length(Text) > 0 then
      Add(THTTPURIElementField.NewByText(Text));
  end;
end;

class function THTTPURIElementFieldList.New: THTTPURIElementFieldList;
begin
  Result := THTTPURIElementFieldList.Create;
end;

class function THTTPURIElementFieldList.NewByContent(const Content: String): THTTPURIElementFieldList;
begin
  Result := THTTPURIElementFieldList.Create;
  Result.ParseContent(Content);
end;

end.
