unit HTTPResponse;

interface

uses
  SysUtils;

type
  THTTPStatusCode = (Ok = 200, Created = 201, NoContent = 204, BadRequest = 400, NotFound = 404, Conflict = 409,
    UnprocessableEntity = 422);
  THTTPContentType = (PlainText, HTML, JSON);
  THTTPEncoding = (Ansi, UTF8);

  IHTTPResponse = interface
    ['{DE03B0CF-B499-4FB4-9CB1-706A4798E2BC}']
    function Content: String;
    function ContentType: THTTPContentType;
    function Encoding: THTTPEncoding;
    function StatusCode: THTTPStatusCode;
    function StatusText: String;
  end;

  THTTPResponse = class sealed(TInterfacedObject, IHTTPResponse)
  strict private
    _Content: String;
    _ContentType: THTTPContentType;
    _Encoding: THTTPEncoding;
    _StatusText: String;
    _StatusCode: THTTPStatusCode;
  public
    function Content: String;
    function ContentType: THTTPContentType;
    function Encoding: THTTPEncoding;
    function StatusCode: THTTPStatusCode;
    function StatusText: String;
    constructor Create(const Content: String; const ContentType: THTTPContentType; const Encoding: THTTPEncoding;
      const StatusCode: THTTPStatusCode; const StatusText: String);
    class function New(const Content: String; const ContentType: THTTPContentType; const Encoding: THTTPEncoding;
      const StatusCode: THTTPStatusCode; const StatusText: String = ''): IHTTPResponse;
  end;

  THTTPJSONResponse = class sealed(TInterfacedObject, IHTTPResponse)
  strict private
    _Response: IHTTPResponse;
  public
    function Content: String;
    function ContentType: THTTPContentType;
    function Encoding: THTTPEncoding;
    function StatusCode: THTTPStatusCode;
    function StatusText: String;
    constructor Create(const Content: String; const StatusCode: THTTPStatusCode; const StatusText: String);
    class function New(const Content: String; const StatusCode: THTTPStatusCode; const StatusText: String = '')
      : IHTTPResponse;
  end;

implementation

function THTTPResponse.StatusCode: THTTPStatusCode;
begin
  Result := _StatusCode;
end;

function THTTPResponse.StatusText: String;
begin
  Result := _StatusText;
end;

function THTTPResponse.Content: String;
begin
  Result := _Content;
end;

function THTTPResponse.ContentType: THTTPContentType;
begin
  Result := _ContentType;
end;

function THTTPResponse.Encoding: THTTPEncoding;
begin
  Result := _Encoding;
end;

constructor THTTPResponse.Create(const Content: String; const ContentType: THTTPContentType;
  const Encoding: THTTPEncoding; const StatusCode: THTTPStatusCode; const StatusText: String);
begin
  _Content := Content;
  _ContentType := ContentType;
  _Encoding := Encoding;
  _StatusCode := StatusCode;
  _StatusText := StatusText;
end;

class function THTTPResponse.New(const Content: String; const ContentType: THTTPContentType;
  const Encoding: THTTPEncoding; const StatusCode: THTTPStatusCode; const StatusText: String): IHTTPResponse;
begin
  Result := THTTPResponse.Create(Content, ContentType, Encoding, StatusCode, StatusText);
end;

{ THTTPJSONResponse }

function THTTPJSONResponse.Content: String;
begin
  Result := _Response.Content;
end;

function THTTPJSONResponse.ContentType: THTTPContentType;
begin
  Result := _Response.ContentType;
end;

function THTTPJSONResponse.Encoding: THTTPEncoding;
begin
  Result := _Response.Encoding;
end;

function THTTPJSONResponse.StatusCode: THTTPStatusCode;
begin
  Result := _Response.StatusCode;
end;

function THTTPJSONResponse.StatusText: String;
begin
  Result := _Response.StatusText;
end;

constructor THTTPJSONResponse.Create(const Content: String; const StatusCode: THTTPStatusCode;
  const StatusText: String);
begin
  _Response := THTTPResponse.Create(Content, THTTPContentType.JSON, THTTPEncoding.UTF8, StatusCode, StatusText);
end;

class function THTTPJSONResponse.New(const Content: String; const StatusCode: THTTPStatusCode;
  const StatusText: String = ''): IHTTPResponse;
begin
  Result := THTTPJSONResponse.Create(Content, StatusCode, StatusText);
end;

end.
