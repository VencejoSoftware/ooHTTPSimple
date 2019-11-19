unit HTTPClient;

interface

uses
  Classes, SysUtils,
  IdHTTP, IdException, IdStack;

type
  IHTTPClient = interface
    ['{E93CE894-B177-4223-B699-FDFA761DA807}']
    function Get(const URL: String; out ResponseContent: String): Integer;
  end;

  THTTPClient = class sealed(TInterfacedObject, IHTTPClient)
  strict private
    _IdHTTP: TIdHTTP;
  private
    function ResolveAddress(const URL: String): String;
  public
    function Get(const URL: String; out ResponseContent: String): Integer;
    constructor Create;
    destructor Destroy; override;
    class function New: IHTTPClient;
  end;

implementation


function THTTPClient.ResolveAddress(const URL: String): String;
begin
  Result := Copy(URL, Pos('//', URL) + 2);
  Result := Copy(Result, 1, Pred(Pos('/', Result)));
end;

function THTTPClient.Get(const URL: String; out ResponseContent: String): Integer;
var
  ResponseStream: TStringStream;
begin
  ResponseContent := EmptyStr;
  ResponseStream := TStringStream.Create(EmptyStr, TEncoding.UTF8);
  try
    try
      _IdHTTP.Get(URL, ResponseStream);
    except
      on E: EIdSocketError do
        raise Exception.Create(Format('%s The server "%s" maybe is down', [E.Message, ResolveAddress(URL)]));
      on E: Exception do
        raise;
    end;
    Result := _IdHTTP.ResponseCode;
    if _IdHTTP.ResponseCode = 200 then
    begin
      ResponseStream.Position := 0;
      ResponseContent := ResponseStream.DataString;
    end;
  finally
    ResponseStream.Free;
  end;
end;

constructor THTTPClient.Create;
begin
  _IdHTTP := TIdHTTP.Create(nil);
end;

destructor THTTPClient.Destroy;
begin
  _IdHTTP.Free;
  inherited;
end;

class function THTTPClient.New: IHTTPClient;
begin
  Result := THTTPClient.Create;
end;

end.
