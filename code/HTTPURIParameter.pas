unit HTTPURIParameter;

interface

uses
  SysUtils, StrUtils,
  Generics.Collections,
  HTTPURIElement;

type
  IHTTPURIParameter = interface
    ['{BBDD61C4-7E51-4926-A144-990DAAEA3071}']
    function Name: String;
    function Element: IHTTPURIElement;
  end;

  THTTPURIParameter = class sealed(TInterfacedObject, IHTTPURIParameter)
  strict private
    _Element: IHTTPURIElement;
    _Name: String;
  public
    function Name: String;
    function Element: IHTTPURIElement;
    constructor Create(const Element: IHTTPURIElement);
    class function New(const Element: IHTTPURIElement): IHTTPURIParameter;
  end;

  THTTPURIParameterList = class sealed(TList<IHTTPURIParameter>)
  strict private
    function IsParameter(const URIElement: String): Boolean;
    procedure ParseElements(const Elements: THTTPURIElementList);
  public
    function ItemByElement(const Element: IHTTPURIElement): IHTTPURIParameter;
    function ItemByName(const Name: String): IHTTPURIParameter;
    class function New: THTTPURIParameterList;
    class function NewByElements(const Elements: THTTPURIElementList): THTTPURIParameterList;
  end;

implementation


{ THTTPURIParameter }

function THTTPURIParameter.Element: IHTTPURIElement;
begin
  Result := _Element;
end;

function THTTPURIParameter.Name: String;
begin
  Result := _Name;
end;

constructor THTTPURIParameter.Create(const Element: IHTTPURIElement);
begin
  _Element := Element;
  _Name := Copy(Element.Content, 2, Length(Element.Content) - 2);
end;

class function THTTPURIParameter.New(const Element: IHTTPURIElement): IHTTPURIParameter;
begin
  Result := THTTPURIParameter.Create(Element);
end;

{ THTTPURIParameterList }

function THTTPURIParameterList.IsParameter(const URIElement: String): Boolean;
begin
  Result := (LeftStr(URIElement, 1) = '{') and (RightStr(URIElement, 1) = '}');
end;

procedure THTTPURIParameterList.ParseElements(const Elements: THTTPURIElementList);
var
  Item: IHTTPURIElement;
begin
  for Item in Elements do
    if IsParameter(Item.Content) then
      Add(THTTPURIParameter.New(Item));
end;

function THTTPURIParameterList.ItemByElement(const Element: IHTTPURIElement): IHTTPURIParameter;
var
  Item: IHTTPURIParameter;
begin
  Result := nil;
  for Item in Self do
    if Element = Item.Element then
      Exit(Item);
end;

function THTTPURIParameterList.ItemByName(const Name: String): IHTTPURIParameter;
var
  Item: IHTTPURIParameter;
begin
  Result := nil;
  for Item in Self do
    if SameText(Name, Item.Name) then
      Exit(Item);
end;

class function THTTPURIParameterList.New: THTTPURIParameterList;
begin
  Result := THTTPURIParameterList.Create;
end;

class function THTTPURIParameterList.NewByElements(const Elements: THTTPURIElementList): THTTPURIParameterList;
begin
  Result := THTTPURIParameterList.New;
  Result.ParseElements(Elements);
end;

end.
