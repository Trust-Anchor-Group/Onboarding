if !Request.Encrypted then Forbidden("HTTPS access required.");
if !exists(Posted) then BadRequest("POST expected.");
if !exists(Posted.RemoteEndPoint) then BadRequest("Remote Endpoint code missing.");

CallerEndpoint:=Posted.RemoteEndPoint;
k:=CallerEndpoint.LastIndexOf(':');
if k>0 then CallerEndpoint:=CallerEndpoint.Substring(0,k);
PhoneCode:="";

if !exists(Global.VerifiedNumbers) then
	false
else if exists(Posted.Nr) and !Global.VerifiedNumbers.ContainsKey(CallerEndpoint+"|"+Posted.Nr) then
	false
else if exists(Posted.EMail) and !Global.VerifiedNumbers.ContainsKey(CallerEndpoint+"|"+Posted.EMail) then
	false
else if exists(Posted.Nr) and exists(Posted.Country) and
	(!Waher.Service.IoTBroker.Legal.Identity.PhoneCountryCodes.TryGetShortestCode(Posted.Country,PhoneCode) or
	!Posted.Nr.StartsWith("+"+PhoneCode)) then
	false
else
	true;