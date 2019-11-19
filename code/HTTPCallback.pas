unit HTTPCallback;

interface

uses
  HTTPURI,
  HTTPRequest,
  HTTPResponse;

type
  THTTPRequestCallback = reference to function(const RouteURI: IURI; const Request: IHTTPRequest): IHTTPResponse;

  IHTTPCallback = interface
    ['{7B2BA9CF-C2B3-4394-9702-170FC5372D39}']
    function Execute(const RouteURI: IURI; const Request: IHTTPRequest): IHTTPResponse;
  end;

  THTTPCallback = class sealed(TInterfacedObject, IHTTPCallback)
  strict private
    _Callback: THTTPRequestCallback;
  public
    function Execute(const RouteURI: IURI; const Request: IHTTPRequest): IHTTPResponse;
    constructor Create(const Callback: THTTPRequestCallback);
    class function New(const Callback: THTTPRequestCallback): IHTTPCallback;
  end;

implementation

function THTTPCallback.Execute(const RouteURI: IURI; const Request: IHTTPRequest): IHTTPResponse;
begin
  if Assigned(_Callback) then
    Result := _Callback(RouteURI, Request)
  else
    Result := nil;
end;

constructor THTTPCallback.Create(const Callback: THTTPRequestCallback);
begin
  _Callback := Callback;
end;

class function THTTPCallback.New(const Callback: THTTPRequestCallback): IHTTPCallback;
begin
  Result := THTTPCallback.Create(Callback);
end;

end.
