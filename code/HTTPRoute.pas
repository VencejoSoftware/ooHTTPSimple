unit HTTPRoute;

interface

uses
  SysUtils,
  Generics.Collections,
  HTTPRequest,
  HTTPResponse,
  HTTPURI;

type
  EHTTPRoute = class sealed(Exception)

  end;

  THTTPMethod = (Get, Post, Put, Delete);

  IHTTPRoute = interface
    ['{5DA7698E-E10F-4814-8DFC-CE967547D771}']
    function URI: IURI;
    function Method: THTTPMethod;
    function Execute(const Request: IHTTPRequest): IHTTPResponse;
  end;

  THTTPRoute = class sealed(TInterfacedObject, IHTTPRoute)
  strict private
    _URI: IURI;
    _Method: THTTPMethod;
  public
    function URI: IURI;
    function Method: THTTPMethod;
    function Execute(const Request: IHTTPRequest): IHTTPResponse;
    constructor Create(const URI: IURI; const Method: THTTPMethod);
    class function New(const URI: IURI; const Method: THTTPMethod): IHTTPRoute;
  end;

  THTTPRouteList = class sealed(TList<IHTTPRoute>)
  public
    function FindRoute(const URI: String; const Method: THTTPMethod): IHTTPRoute;
    class function New: THTTPRouteList;
  end;

implementation

{ THTTPRoute }

function THTTPRoute.URI: IURI;
begin
  Result := _URI;
end;

function THTTPRoute.Method: THTTPMethod;
begin
  Result := _Method;
end;

function THTTPRoute.Execute(const Request: IHTTPRequest): IHTTPResponse;
begin
  Result := nil;
end;

constructor THTTPRoute.Create(const URI: IURI; const Method: THTTPMethod);
begin
  _URI := URI;
  _Method := Method;
end;

class function THTTPRoute.New(const URI: IURI; const Method: THTTPMethod): IHTTPRoute;
begin
  Result := THTTPRoute.Create(URI, Method);
end;

{ THTTPRouteList }

function THTTPRouteList.FindRoute(const URI: String; const Method: THTTPMethod): IHTTPRoute;
var
  Item: IHTTPRoute;
begin
  Result := nil;
  for Item in Self do
    if Item.URI.IsMatchedURI(URI) and (Item.Method = Method) then
      Exit(Item);
end;

class function THTTPRouteList.New: THTTPRouteList;
begin
  Result := THTTPRouteList.Create;
end;

end.
