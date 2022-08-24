unit TFLima.Paginate;

interface

uses
  Horse,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Option, System.JSON;

type
  TCustomPaginate = class
  private class var
    FActive: Boolean;
    FLimit, FPage: string;
    FTotal, FPages: Integer;
    FDQuery: TFDQuery;
    //class procedure AdjustValues;
    class procedure Middleware(Req: THorseRequest; Res: THorseResponse;
      Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});
  public
    class procedure DataSet(ADataSet: TDataSet);
  end;

function CustomPaginate: THorseCallback;

implementation

uses
  System.SysUtils,
  Horse.Paginate,
  Web.HTTPApp;

function CustomPaginate: THorseCallback;
begin
  Result := TCustomPaginate.Middleware;
end;

{ TCustomPaginate }

///<sumary> A Query que sofrerá a paginação deve ser passada aqui </sumary>
///<remarks>A propriedade Active só estará igual a True se a requisição tiver
///  sido feita com paginação</remarks>
class procedure TCustomPaginate.DataSet(ADataSet: TDataSet);
begin
  if not FActive then
    Exit;

  if (FPage.ToInteger <= 0) or (FLimit.ToInteger <= 0) then
    Exit;

  FDQuery := ADataSet as TFDQuery;
  FDQuery.Close;
  FDQuery.FetchOptions.RecsMax  := FLimit.ToInteger;
  FDQuery.FetchOptions.RecsSkip := (FPage.ToInteger-1) * FLimit.ToInteger;

  {$REGION ''}
//  begin
//    FDQuery.Close;
//    Exit;
//  end;
//
//  FDQuery.FetchOptions.RecordCountMode := TFDRecordCountMode.cmTotal;
//  FTotal := FDQuery.RecordCount;
//  FPages := Trunc(FTotal / FLimit.ToInteger) +
//            Byte((FTotal mod FLimit.ToInteger) <> 0);
//
//  FDQuery.Close;
//  FDQuery.FetchOptions.RecsMax  := FLimit.ToInteger;
//  FDQuery.FetchOptions.RecsSkip := (FPage.ToInteger-1) * FLimit.ToInteger;
//  FDQuery.Open;
  {$ENDREGION}
end;

{$REGION ''}
///<sumary>Após a execução da consulta, pega a real totalização de registros
///  e páginas no modo X-Paginate</sumary>
//class procedure TCustomPaginate.AdjustValues;
//begin
//  FDQuery.FetchOptions.RecordCountMode := TFDRecordCountMode.cmTotal;
//  FTotal := FDQuery.RecordCount;
//  FPages := Trunc(FTotal / FLimit.ToInteger) +
//            Byte((FTotal mod FLimit.ToInteger) <> 0);
//end;
{$ENDREGION}

///<sumary>Permite paginar desde a consulta ao banco de dados,
/// melhorando a performance.</sumary>
class procedure TCustomPaginate.Middleware(Req: THorseRequest;
  Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});
var
  LJsonObjectResponse: TJSONObject;
begin
{$REGION ''}
  //Dá a opção de paginar com ou sem X-Paginate
//  if Req.Headers['X-Paginate'] = 'true' then
//  begin
//    FActive := True;
//    if not Req.Query.TryGetValue('limit', FLimit) then
//      FLimit := '25';
//    if not Req.Query.TryGetValue('page', FPage) then
//      FPage := '1';
//
//    Req.Query.Dictionary.AddOrSetValue('page', '1');
//    if FLimit.ToInteger <= 0 then
//      Req.Query.Dictionary.AddOrSetValue('limit', '1');
//  end
//  else
{$ENDREGION}
  if Req.Headers['X-Paginate'] = 'true' then
  begin
    FActive := True;
    if not Req.Query.TryGetValue('page', FPage) then
      FPage := '1';
    if not Req.Query.TryGetValue('limit', FLimit) then
      FLimit := '25';
  end;

  try
{$REGION ''}
//    if Req.Headers['X-Paginate'] = 'true' then
//      Horse.Paginate.Middleware(Req, Res, Next) //Usa o Paginate do Thulio
//    else
{$ENDREGION}
      Next;
  finally
{$REGION ''}
//    if Req.Headers['X-Paginate'] = 'true' then
//    try
//      AdjustValues;
//
//      LJsonObjectResponse := Res.Content as TJSONObject;
//      LJsonObjectResponse.RemovePair('total');
//      LJsonObjectResponse.RemovePair('limit');
//      LJsonObjectResponse.RemovePair('page');
//      LJsonObjectResponse.RemovePair('pages');
//
//      LJsonObjectResponse
//        .{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('total', {$IF DEFINED(FPC)}FTotal{$ELSE}TJSONNumber.Create(FTotal){$ENDIF})
//        .{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('limit', {$IF DEFINED(FPC)}FLimit.ToInteger{$ELSE}TJSONNumber.Create(FLimit.ToInteger){$ENDIF})
//        .{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('page' , {$IF DEFINED(FPC)}FPage.ToInteger{$ELSE}TJSONNumber.Create(FPage.ToInteger){$ENDIF})
//        .{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('pages', {$IF DEFINED(FPC)}FPages{$ELSE}TJSONNumber.Create(FPages){$ENDIF});
//    except
//    end;
{$ENDREGION}
    FActive := False;
  end;
end;

initialization
  TCustomPaginate.FActive := False;

end.
