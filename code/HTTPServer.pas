unit HTTPServer;

interface

uses
  Classes, SysUtils,
  IdContext, IdCustomHTTPServer, IdHTTPServer, IdGlobal,
  HTTPURI,
  HTTPRequest,
  HTTPResponse,
  HTTPRoute;

type
  IHTTPServer = interface
    ['{DFCCE323-D799-4136-B891-83471EE996BB}']
    function Start: boolean;
    function RouteList: THTTPRouteList;
  end;

  TOnHTTPServerLog = procedure(const Text: String);

  THTTPServer = class sealed(TInterfacedObject, IHTTPServer)
  strict private
    _IdHTTPServer: TIdHTTPServer;
    _RouteList: THTTPRouteList;
    _OnServerLog: TOnHTTPServerLog;
  private
    procedure IdHTTPServer1CommandGet(Context: TIdContext; RequestInfo: TIdHTTPRequestInfo;
      ResponseInfo: TIdHTTPResponseInfo);
    procedure FailRoute(const RequestInfo: TIdHTTPRequestInfo; var ResponseInfo: TIdHTTPResponseInfo;
      const E: Exception);
    procedure ResponseToIndy(const Response: IHTTPResponse; var ResponseInfo: TIdHTTPResponseInfo);
    function CommandToHTTPMethod(const Command: String): THTTPMethod;
    function ContentTypeToText(const Value: THTTPContentType): String;
    function EncodingToText(const Value: THTTPEncoding): String;
    procedure DoLog(const Text: String);
    function FindRoute(const RequestInfo: TIdHTTPRequestInfo): IHTTPRoute;
    function ResolveRequestURL(const RequestInfo: TIdHTTPRequestInfo): String;
    function BuildRequest(const RequestInfo: TIdHTTPRequestInfo): IHTTPRequest;
    function RequestInfoToText(const RequestInfo: TIdHTTPRequestInfo): String;
  public
    function Start: boolean;
    function RouteList: THTTPRouteList;
    constructor Create(const Port: Word; const OnServerLog: TOnHTTPServerLog);
    destructor Destroy; override;
    class function New(const Port: Word; const OnServerLog: TOnHTTPServerLog): IHTTPServer;
  end;

implementation

function THTTPServer.Start: boolean;
begin
  _IdHTTPServer.Active := true;
  Result := _IdHTTPServer.Active;
end;

function THTTPServer.RouteList: THTTPRouteList;
begin
  Result := _RouteList;
end;

function THTTPServer.CommandToHTTPMethod(const Command: String): THTTPMethod;
begin
  if SameText('GET', Command) then
    Result := THTTPMethod.Get
  else if SameText('POST', Command) then
    Result := THTTPMethod.Post
  else if SameText('PUT', Command) then
    Result := THTTPMethod.Put
  else if SameText('DELETE', Command) then
    Result := THTTPMethod.Delete
  else
    raise Exception.Create('Unrecognized HTTP command');
end;

function THTTPServer.ContentTypeToText(const Value: THTTPContentType): String;
const
  Text: array [THTTPContentType] of string = ('text/plain', 'text/html', 'application/json');
begin
  Result := Text[Value];
end;

function THTTPServer.EncodingToText(const Value: THTTPEncoding): String;
const
  Text: array [THTTPEncoding] of string = ('ansi', 'utf-8');
begin
  Result := Text[Value];
end;

function THTTPServer.RequestInfoToText(const RequestInfo: TIdHTTPRequestInfo): String;
begin
  Result := Format('Date=%s|Accept=%s|RemoteIP=%s|UserAgent=%s|RawHTTPCommand=%s|Version=%s', [
    DateTimeToStr(RequestInfo.Date), RequestInfo.Accept, RequestInfo.RemoteIP, RequestInfo.UserAgent,
    RequestInfo.RawHTTPCommand, RequestInfo.Version]);
end;

procedure THTTPServer.FailRoute(const RequestInfo: TIdHTTPRequestInfo; var ResponseInfo: TIdHTTPResponseInfo;
  const E: Exception);
var
  Route: IHTTPRoute;
  Response: IHTTPResponse;
begin
  Route := RouteList.FindRoute('FailRoute', CommandToHTTPMethod(RequestInfo.Command));
  if Assigned(Route) then
  begin
    RequestInfo.PostStream.Free;
    RequestInfo.PostStream := TStringStream.Create(Format('ClassName=%s|Message=%s|%s',
      [E.ClassName, E.Message, RequestInfoToText(RequestInfo)]));
    Response := Route.Execute(BuildRequest(RequestInfo));
    ResponseToIndy(Response, ResponseInfo);
  end
  else
  begin
    ResponseInfo.ResponseNo := Ord(THTTPStatusCode.BadRequest);
    ResponseInfo.ContentText := Format('<HTTP><body>Critical error<br>Command: %s => %s. Error: %s</body></HTTP>',
      [RequestInfo.Command, RequestInfo.URI, E.Message]);
  end;
end;

procedure THTTPServer.ResponseToIndy(const Response: IHTTPResponse; var ResponseInfo: TIdHTTPResponseInfo);
begin
  ResponseInfo.ResponseNo := Ord(Response.StatusCode);
  ResponseInfo.ContentText := Response.Content;
  ResponseInfo.ContentEncoding := EncodingToText(Response.Encoding);
  ResponseInfo.CharSet := EncodingToText(Response.Encoding);
  ResponseInfo.ContentType := ContentTypeToText(Response.ContentType);
end;

procedure THTTPServer.DoLog(const Text: String);
begin
  if Assigned(_OnServerLog) then
    _OnServerLog(Text);
end;

function THTTPServer.ResolveRequestURL(const RequestInfo: TIdHTTPRequestInfo): String;
begin
  Result := RequestInfo.URI;
  if Length(RequestInfo.QueryParams) > 0 then
    Result := Result + '?' + RequestInfo.QueryParams;
end;

function THTTPServer.FindRoute(const RequestInfo: TIdHTTPRequestInfo): IHTTPRoute;
var
  URL: String;
begin
  URL := ResolveRequestURL(RequestInfo);
  Result := RouteList.FindRoute(URL, CommandToHTTPMethod(RequestInfo.Command));
  if not Assigned(Result) then
    raise EHTTPRoute.Create('URL not found');
end;

function THTTPServer.BuildRequest(const RequestInfo: TIdHTTPRequestInfo): IHTTPRequest;
var
  Stream: TStream;
  URI: IURI;
  Body: String;
begin
  Stream := RequestInfo.PostStream;
  if Assigned(Stream) then
  begin
    Stream.Position := 0;
    Body := ReadStringFromStream(Stream);
  end
  else
    Body := EmptyStr;
  URI := TURI.New(ResolveRequestURL(RequestInfo));
  Result := THTTPRequest.New(URI, Body);
end;

procedure THTTPServer.IdHTTPServer1CommandGet(Context: TIdContext; RequestInfo: TIdHTTPRequestInfo;
  ResponseInfo: TIdHTTPResponseInfo);
var
  Route: IHTTPRoute;
  Response: IHTTPResponse;
begin
  DoLog(Format('%s|%s|%s|%s|%s', [RequestInfo.RemoteIP, RequestInfo.UserAgent, RequestInfo.Version,
    RequestInfo.Command, RequestInfo.RawHTTPCommand]));
  try
    Route := FindRoute(RequestInfo);
    Response := Route.Execute(BuildRequest(RequestInfo));
    ResponseToIndy(Response, ResponseInfo);
    DoLog(Format('%s|%s|%s|%s|%s|%d|%s', [RequestInfo.RemoteIP, RequestInfo.UserAgent, RequestInfo.Version,
      RequestInfo.Command, RequestInfo.RawHTTPCommand, ResponseInfo.ResponseNo, ResponseInfo.ContentText]));
  except
    on E: Exception do
    begin
      DoLog(Format('%s|%s|%s|%s|%s|%s', [RequestInfo.RemoteIP, RequestInfo.UserAgent, RequestInfo.Version, 'ERROR',
        RequestInfo.RawHTTPCommand, E.Message]));
      FailRoute(RequestInfo, ResponseInfo, E);
    end;
  end;
end;

constructor THTTPServer.Create(const Port: Word; const OnServerLog: TOnHTTPServerLog);
begin
  _OnServerLog := OnServerLog;
  _RouteList := THTTPRouteList.New;
  _IdHTTPServer := TIdHTTPServer.Create(nil);
  _IdHTTPServer.DefaultPort := Port;
  _IdHTTPServer.AutoStartSession := true;
  _IdHTTPServer.OnCommandGet := IdHTTPServer1CommandGet;
  _IdHTTPServer.OnCommandOther := IdHTTPServer1CommandGet;
end;

destructor THTTPServer.Destroy;
begin
  _RouteList.Free;
  _IdHTTPServer.Free;
  inherited;
end;

class function THTTPServer.New(const Port: Word; const OnServerLog: TOnHTTPServerLog): IHTTPServer;
begin
  Result := THTTPServer.Create(Port, OnServerLog);
end;

end.
