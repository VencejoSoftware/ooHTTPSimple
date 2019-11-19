unit DatasetToJSON;

interface

uses
  Variants,
  DB,
  JSON;

function GetDataSetAsJSON(const DataSet: TDataSet): TJSONObject;

implementation

function GetDataSetAsJSON(const DataSet: TDataSet): TJSONObject;
var
  f: TField;
  o: TJSONObject;
  a: TJSONArray;
begin
  a := TJSONArray.Create;
  DataSet.Active := True;
  DataSet.First;
  while not DataSet.EOF do
  begin
    o := TJSONObject.Create;
    for f in DataSet.Fields do
      o.AddPair(f.FieldName, VarToStr(f.Value));
    a.AddElement(o);
    DataSet.Next;
  end;
  DataSet.Active := False;
  Result := TJSONObject.Create;
  Result.AddPair(DataSet.Name, a);
end;

end.
