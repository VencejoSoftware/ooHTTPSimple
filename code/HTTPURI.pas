unit HTTPURI;

interface

uses
  SysUtils, StrUtils,
  Generics.Collections,
  HTTPURIElement,
  HTTPURIParameter;

type
  IURI = interface
    ['{36F3CDF1-B78B-477B-9C44-CB05F6E92015}']
    function Address: String;
    function Elements: THTTPURIElementList;
    function Parameters: THTTPURIParameterList;
    function IsMatchedURI(const URI: String): Boolean;
    function ResolveParameter(const URI, ParamName: String): IHTTPURIElement;
  end;

  TURI = class sealed(TInterfacedObject, IURI)
  strict private
    _Address: String;
    _Elements: THTTPURIElementList;
    _Parameters: THTTPURIParameterList;
  public
    function Address: String;
    function Elements: THTTPURIElementList;
    function Parameters: THTTPURIParameterList;
    function IsMatchedURI(const URI: String): Boolean;
    function ResolveParameter(const URI, ParamName: String): IHTTPURIElement;
    constructor Create(const Address: String);
    destructor Destroy; override;
    class function New(const Address: String): IURI;
  end;

implementation

{ TURI }

function TURI.Address: String;
begin
  Result := _Address;
end;

function TURI.Elements: THTTPURIElementList;
begin
  Result := _Elements;
end;

function TURI.Parameters: THTTPURIParameterList;
begin
  Result := _Parameters;
end;

function TURI.IsMatchedURI(const URI: String): Boolean;
var
  URIElements: THTTPURIElementList;
  i: Integer;
begin
  URIElements := THTTPURIElementList.NewByURI(URI);
  try
    Result := URIElements.Count = _Elements.Count;
    if Result then
      for i := 0 to Pred(URIElements.Count) do
        if not SameText(URIElements[i].Content, _Elements[i].Content) then
          if Assigned(_Parameters.ItemByElement(_Elements[i])) then
            Exit(URIElements[i].Fields.IsEmpty)
          else
            Exit(False);
  finally
    URIElements.Free;
  end;
end;

function TURI.ResolveParameter(const URI, ParamName: String): IHTTPURIElement;
var
  URIElements: THTTPURIElementList;
  Parameter: IHTTPURIParameter;
begin
  Result := nil;
  URIElements := THTTPURIElementList.NewByURI(URI);
  try
    Parameter := _Parameters.ItemByName(ParamName);
    if Assigned(Parameter) then
      Result := THTTPURIElement.New(Parameter.Element.Index, URIElements[Parameter.Element.Index].Content);
  finally
    URIElements.Free;
  end;
end;

constructor TURI.Create(const Address: String);
begin
  _Address := Address;
  _Elements := THTTPURIElementList.NewByURI(Address);
  _Parameters := THTTPURIParameterList.NewByElements(_Elements);
end;

destructor TURI.Destroy;
begin
  _Elements.Free;
  _Parameters.Free;
  inherited;
end;

class function TURI.New(const Address: String): IURI;
begin
  Result := TURI.Create(Address);
end;

end.
