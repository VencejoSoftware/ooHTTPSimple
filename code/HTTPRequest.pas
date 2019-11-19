unit HTTPRequest;

interface

uses
  HTTPURI;

type
  IHTTPRequest = interface
    ['{13CF42F3-0760-4C0F-B387-B5E7CA0C6AEB}']
    function URI: IURI;
    function Body: String;
  end;

  THTTPRequest = class sealed(TInterfacedObject, IHTTPRequest)
  strict private
    _URI: IURI;
    _Body: String;
  public
    function URI: IURI;
    function Body: String;
    constructor Create(const URI: IURI; const Body: String);
    class function New(const URI: IURI; const Body: String): IHTTPRequest;
  end;

implementation

function THTTPRequest.URI: IURI;
begin
  Result := _URI;
end;

function THTTPRequest.Body: String;
begin
  Result := _Body;
end;

constructor THTTPRequest.Create(const URI: IURI; const Body: String);
begin
  _URI := URI;
  _Body := Body;
end;

class function THTTPRequest.New(const URI: IURI; const Body: String): IHTTPRequest;
begin
  Result := THTTPRequest.Create(URI, Body);
end;

end.
